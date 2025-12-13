CREATE OR REPLACE FUNCTION contar_filmes_vistos(p_respondent_id BIGINT)
RETURNS INT AS $$
DECLARE
    v_exists BOOLEAN;
BEGIN
    SELECT EXISTS(
        SELECT 1 FROM respondent WHERE id = p_respondent_id
    ) INTO v_exists;

    IF NOT v_exists THEN
        RETURN 0;
    END IF;

    RETURN (
        SELECT COUNT(*)
        FROM film_seen
        WHERE respondent_id = p_respondent_id
    );
END;
$$ LANGUAGE plpgsql STABLE;


-- FUNCTION 2: Obter ranking médio de um filme
CREATE OR REPLACE FUNCTION obter_ranking_medio_filme(p_film_id INT)
RETURNS NUMERIC AS $$
DECLARE
    v_media NUMERIC;
BEGIN
    SELECT AVG(fr.ranking::NUMERIC) INTO v_media
    FROM film_ranking fr
    WHERE fr.film_id = p_film_id;

    RETURN COALESCE(v_media, 0);
END;
$$ LANGUAGE plpgsql STABLE;


CREATE OR REPLACE FUNCTION eh_fan_star_wars(p_respondent_id BIGINT)
RETURNS BOOLEAN AS $$
DECLARE
    v_question_id BIGINT;
BEGIN
    SELECT id INTO v_question_id
    FROM question
    WHERE statement = 'Do you consider yourself to be a fan of the Star Wars film franchise?'
    LIMIT 1;

    IF v_question_id IS NULL THEN
        RETURN FALSE;
    END IF;

    RETURN EXISTS (
        SELECT 1
        FROM answer a
        JOIN answer_option ao ON ao.id = a.option_id
        WHERE a.respondent_id = p_respondent_id
          AND a.question_id = v_question_id
          AND UPPER(ao.label) = 'YES'
    );
END;
$$ LANGUAGE plpgsql STABLE;
