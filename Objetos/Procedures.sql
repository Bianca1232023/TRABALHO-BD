-- PROCEDURE 1: Inserir respondente e suas respostas com validação
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
BEGIN

    IF NOT EXISTS (SELECT 1 FROM "respondentid" WHERE respondent_id = p_respondent_id) THEN
        INSERT INTO "respondentid" (respondent_id) VALUES (p_respondent_id);
    END IF;
    

    INSERT INTO respostas(
        respondent_id, gender, age, household_income, education, region,
        seen_any_star_wars, fan_of_star_wars, fan_of_startrek,
        fan_of_expanded_universe, familiar_with_expanded_universe, who_shot_first
    ) VALUES (
        p_respondent_id, p_gender, p_age::idade, p_household_income, p_education, p_region,
        p_seen_any_star_wars, p_fan_of_star_wars, p_fan_of_startrek,
        p_fan_of_expanded_universe, p_familiar_with_expanded_universe, p_who_shot_first
    );
    
    COMMIT;
END;
$$;


-- PROCEDURE 2: Atualizar opinião de personagem em lote
CREATE OR REPLACE PROCEDURE atualizar_opiniao_personagem_lote(
    p_character_id INT,
    p_opiniao_anterior VARCHAR,
    p_opiniao_nova VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE character_opinion
    SET opinion = p_opiniao_nova
    WHERE character_id = p_character_id
    AND opinion = p_opiniao_anterior;
    
    RAISE NOTICE 'Atualizadas % opiniões do personagem %', FOUND, p_character_id;
END;
$$;


-- PROCEDURE 3: Limpar dados de respondente (cascade)
CREATE OR REPLACE PROCEDURE limpar_respondente(
    p_respondent_id BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_count INT;
BEGIN

    SELECT COUNT(*) INTO v_count
    FROM respostas
    WHERE respondent_id = p_respondent_id;
    

    DELETE FROM respostas
    WHERE respondent_id = p_respondent_id;
    
    RAISE NOTICE 'Deletadas % respostas do respondente %', v_count, p_respondent_id;
END;
$$;
