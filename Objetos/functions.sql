-- FUNCTION 1: Contar filmes vistos por um respondente
CREATE OR REPLACE FUNCTION contar_filmes_vistos(p_respondent_id BIGINT)
RETURNS INT AS $$
DECLARE
    v_count INT;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM film_seen
    WHERE respondent_id = p_respondent_id
    AND seen IS NOT NULL
    AND TRIM(seen) <> '';
    
    RETURN v_count;
END;
$$ LANGUAGE plpgsql;


-- FUNCTION 2: Obter ranking médio de um filme
CREATE OR REPLACE FUNCTION obter_ranking_medio_filme(p_film_id INT)
RETURNS NUMERIC AS $$
DECLARE
    v_media NUMERIC;
BEGIN
    SELECT AVG(ranking::NUMERIC) INTO v_media
    FROM film_ranking
    WHERE film_id = p_film_id
    AND ranking IS NOT NULL;
    
    RETURN COALESCE(v_media, 0);
END;
$$ LANGUAGE plpgsql;


-- FUNCTION 3: Verificar se respondente é fan de Star Wars
CREATE OR REPLACE FUNCTION eh_fan_star_wars(p_respondent_id BIGINT)
RETURNS BOOLEAN AS $$
DECLARE
    v_eh_fan VARCHAR;
BEGIN
    SELECT fan_of_star_wars INTO v_eh_fan
    FROM respostas
    WHERE respondent_id = p_respondent_id
    LIMIT 1;
    
    RETURN COALESCE(v_eh_fan = 'Yes', FALSE);
END;
$$ LANGUAGE plpgsql;
