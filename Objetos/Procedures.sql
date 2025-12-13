CREATE OR REPLACE PROCEDURE inserir_respondente_com_validacao(
    p_respondent_id BIGINT,
    p_gender VARCHAR,
    p_age VARCHAR,
    p_household_income VARCHAR,
    p_education VARCHAR,
    p_region VARCHAR,
    p_seen_any_star_wars VARCHAR,
    p_fan_of_star_wars VARCHAR,
    p_fan_of_startrek VARCHAR,
    p_fan_of_expanded_universe VARCHAR,
    p_familiar_with_expanded_universe VARCHAR,
    p_who_shot_first VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_gender_id INT;
    v_age_group_id INT;
    v_household_income_id INT;
    v_education_level_id INT;
    v_region_id INT;
    v_age_start INT;
    v_age_end INT;
    v_income_start INT;
    v_income_end INT;

    v_seen_label TEXT;
    v_fan_sw_label TEXT;
    v_fan_st_label TEXT;
    v_fan_eu_label TEXT;
    v_familiar_label TEXT;
    v_shot_label TEXT;
BEGIN
    IF EXISTS (SELECT 1 FROM respondent WHERE id = p_respondent_id) THEN
        RAISE EXCEPTION 'Respondente % já existe.', p_respondent_id;
    END IF;

    IF p_gender IS NOT NULL THEN
        INSERT INTO gender (description) VALUES (TRIM(p_gender))
        ON CONFLICT (description) DO NOTHING;
        SELECT id INTO v_gender_id FROM gender WHERE description = TRIM(p_gender);
    END IF;

    IF p_education IS NOT NULL THEN
        INSERT INTO education_level (name) VALUES (TRIM(p_education))
        ON CONFLICT (name) DO NOTHING;
        SELECT id INTO v_education_level_id FROM education_level WHERE name = TRIM(p_education);
    END IF;

    IF p_region IS NOT NULL THEN
        INSERT INTO region (name) VALUES (TRIM(p_region))
        ON CONFLICT (name) DO NOTHING;
        SELECT id INTO v_region_id FROM region WHERE name = TRIM(p_region);
    END IF;

    IF p_age IS NOT NULL THEN
        SELECT 
            CASE REPLACE(TRIM(p_age),' ', '')
                WHEN '18-29' THEN 18
                WHEN '30-44' THEN 30
                WHEN '45-60' THEN 45
                WHEN '>60' THEN 61
            END,
            CASE REPLACE(TRIM(p_age),' ', '')
                WHEN '18-29' THEN 29
                WHEN '30-44' THEN 44
                WHEN '45-60' THEN 60
                WHEN '>60' THEN 200
            END
        INTO v_age_start, v_age_end;

        IF v_age_start IS NULL OR v_age_end IS NULL THEN
            RAISE EXCEPTION 'Faixa etária % não suportada.', p_age;
        END IF;

        SELECT id INTO v_age_group_id
        FROM age_group
        WHERE age_range_start = v_age_start
          AND age_range_end = v_age_end;
    END IF;

    IF p_household_income IS NOT NULL THEN
        SELECT 
            CASE TRIM(p_household_income)
                WHEN '$0 - $24,999' THEN 0
                WHEN '$25,000 - $49,999' THEN 25000
                WHEN '$50,000 - $99,999' THEN 50000
                WHEN '$100,000 - $149,999' THEN 100000
                WHEN '$150,000+' THEN 150000
            END,
            CASE TRIM(p_household_income)
                WHEN '$0 - $24,999' THEN 24999
                WHEN '$25,000 - $49,999' THEN 49999
                WHEN '$50,000 - $99,999' THEN 99999
                WHEN '$100,000 - $149,999' THEN 149999
                WHEN '$150,000+' THEN 9999999
            END
        INTO v_income_start, v_income_end;

        IF v_income_start IS NULL OR v_income_end IS NULL THEN
            RAISE EXCEPTION 'Faixa de renda % não suportada.', p_household_income;
        END IF;

        SELECT id INTO v_household_income_id
        FROM household_income
        WHERE income_range_start = v_income_start
          AND income_range_end = v_income_end;
    END IF;

    INSERT INTO respondent (
        id,
        gender_id,
        age_group_id,
        household_income_id,
        education_level_id,
        region_id
    ) VALUES (
        p_respondent_id,
        v_gender_id,
        v_age_group_id,
        v_household_income_id,
        v_education_level_id,
        v_region_id
    );

    v_seen_label := CASE UPPER(TRIM(p_seen_any_star_wars))
        WHEN 'YES' THEN 'Yes'
        WHEN 'NO' THEN 'No'
    END;
    v_fan_sw_label := CASE UPPER(TRIM(p_fan_of_star_wars))
        WHEN 'YES' THEN 'Yes'
        WHEN 'NO' THEN 'No'
    END;
    v_fan_st_label := CASE UPPER(TRIM(p_fan_of_startrek))
        WHEN 'YES' THEN 'Yes'
        WHEN 'NO' THEN 'No'
    END;
    v_fan_eu_label := CASE UPPER(TRIM(p_fan_of_expanded_universe))
        WHEN 'YES' THEN 'Yes'
        WHEN 'NO' THEN 'No'
    END;
    v_familiar_label := CASE UPPER(TRIM(p_familiar_with_expanded_universe))
        WHEN 'YES' THEN 'Yes'
        WHEN 'NO' THEN 'No'
    END;

    IF p_who_shot_first IS NOT NULL THEN
        CASE UPPER(TRIM(p_who_shot_first))
            WHEN 'HAN' THEN v_shot_label := 'Han';
            WHEN 'HAN SOLO' THEN v_shot_label := 'Han';
            WHEN 'GREEDO' THEN v_shot_label := 'Greedo';
            WHEN 'I DON''T UNDERSTAND THIS QUESTION' THEN v_shot_label := 'I don''t understand this question';
        END CASE;
    END IF;

        IF v_seen_label IS NOT NULL THEN
                INSERT INTO answer (respondent_id, question_id, option_id)
                SELECT p_respondent_id, q.id, ao.id
                FROM question q
                JOIN answer_option ao ON ao.question_id = q.id
                WHERE q.statement = 'Have you seen any of the 6 films in the Star Wars franchise?'
                    AND ao.label = v_seen_label
                ON CONFLICT (respondent_id, question_id)
                DO UPDATE SET option_id = EXCLUDED.option_id;
        END IF;

        IF v_fan_sw_label IS NOT NULL THEN
                INSERT INTO answer (respondent_id, question_id, option_id)
                SELECT p_respondent_id, q.id, ao.id
                FROM question q
                JOIN answer_option ao ON ao.question_id = q.id
                WHERE q.statement = 'Do you consider yourself to be a fan of the Star Wars film franchise?'
                    AND ao.label = v_fan_sw_label
                ON CONFLICT (respondent_id, question_id)
                DO UPDATE SET option_id = EXCLUDED.option_id;
        END IF;

        IF v_fan_st_label IS NOT NULL THEN
                INSERT INTO answer (respondent_id, question_id, option_id)
                SELECT p_respondent_id, q.id, ao.id
                FROM question q
                JOIN answer_option ao ON ao.question_id = q.id
                WHERE q.statement = 'Do you consider yourself to be a fan of the Star Trek franchise?'
                    AND ao.label = v_fan_st_label
                ON CONFLICT (respondent_id, question_id)
                DO UPDATE SET option_id = EXCLUDED.option_id;
        END IF;

        IF v_fan_eu_label IS NOT NULL THEN
                INSERT INTO answer (respondent_id, question_id, option_id)
                SELECT p_respondent_id, q.id, ao.id
                FROM question q
                JOIN answer_option ao ON ao.question_id = q.id
                WHERE q.statement = 'Do you consider yourself to be a fan of the Expanded Universe?'
                    AND ao.label = v_fan_eu_label
                ON CONFLICT (respondent_id, question_id)
                DO UPDATE SET option_id = EXCLUDED.option_id;
        END IF;

        IF v_familiar_label IS NOT NULL THEN
                INSERT INTO answer (respondent_id, question_id, option_id)
                SELECT p_respondent_id, q.id, ao.id
                FROM question q
                JOIN answer_option ao ON ao.question_id = q.id
                WHERE q.statement = 'Are you familiar with the Expanded Universe?'
                    AND ao.label = v_familiar_label
                ON CONFLICT (respondent_id, question_id)
                DO UPDATE SET option_id = EXCLUDED.option_id;
        END IF;

        IF v_shot_label IS NOT NULL THEN
                INSERT INTO answer (respondent_id, question_id, option_id)
                SELECT p_respondent_id, q.id, ao.id
                FROM question q
                JOIN answer_option ao ON ao.question_id = q.id
                WHERE q.statement = 'Which character shot first?'
                    AND ao.label = v_shot_label
                ON CONFLICT (respondent_id, question_id)
                DO UPDATE SET option_id = EXCLUDED.option_id;
        END IF;
END;
$$;


CREATE OR REPLACE PROCEDURE limpar_respondente(
    p_respondent_id BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_removed INT := 0;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM respondent WHERE id = p_respondent_id) THEN
        RAISE NOTICE 'Respondente % não encontrado.', p_respondent_id;
        RETURN;
    END IF;

    DELETE FROM answer WHERE respondent_id = p_respondent_id;
    DELETE FROM film_seen WHERE respondent_id = p_respondent_id;
    DELETE FROM film_ranking WHERE respondent_id = p_respondent_id;
    DELETE FROM character_opinion WHERE respondent_id = p_respondent_id;

    DELETE FROM respondent WHERE id = p_respondent_id;
    GET DIAGNOSTICS v_removed = ROW_COUNT;

    RAISE NOTICE 'Removidos % registros do respondente %', v_removed, p_respondent_id;
END;
$$;


CREATE OR REPLACE PROCEDURE listar_respostas_completas(INOUT p_cursor REFCURSOR DEFAULT 'respostas_cursor')
LANGUAGE plpgsql
AS $$
BEGIN
    OPEN p_cursor FOR
        SELECT 
            r.id AS respondent_id,
            g.description AS gender,
            CONCAT(ag.age_range_start, '-', ag.age_range_end) AS age_group,
            CONCAT('$', hi.income_range_start, ' - ', hi.income_range_end) AS household_income,
            el.name AS education_level,
            rg.name AS region,
            MAX(CASE WHEN q.statement = 'Have you seen any of the 6 films in the Star Wars franchise?' THEN ao.label END) AS seen_any_star_wars,
            MAX(CASE WHEN q.statement = 'Do you consider yourself to be a fan of the Star Wars film franchise?' THEN ao.label END) AS fan_of_star_wars,
            MAX(CASE WHEN q.statement = 'Do you consider yourself to be a fan of the Star Trek franchise?' THEN ao.label END) AS fan_of_star_trek,
            MAX(CASE WHEN q.statement = 'Do you consider yourself to be a fan of the Expanded Universe?' THEN ao.label END) AS fan_of_expanded_universe,
            MAX(CASE WHEN q.statement = 'Are you familiar with the Expanded Universe?' THEN ao.label END) AS familiar_with_expanded_universe,
            MAX(CASE WHEN q.statement = 'Which character shot first?' THEN ao.label END) AS who_shot_first
        FROM respondent r
        LEFT JOIN gender g ON g.id = r.gender_id
        LEFT JOIN age_group ag ON ag.id = r.age_group_id
        LEFT JOIN household_income hi ON hi.id = r.household_income_id
        LEFT JOIN education_level el ON el.id = r.education_level_id
        LEFT JOIN region rg ON rg.id = r.region_id
        LEFT JOIN answer a ON a.respondent_id = r.id
        LEFT JOIN question q ON q.id = a.question_id
        LEFT JOIN answer_option ao ON ao.id = a.option_id
        GROUP BY r.id, g.description, ag.age_range_start, ag.age_range_end, hi.income_range_start, hi.income_range_end, el.name, rg.name
        ORDER BY r.id;
END;
$$;
