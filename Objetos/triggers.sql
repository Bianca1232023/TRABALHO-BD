-- TRIGGER 1: Contar quantas vezes um filme foi visto
CREATE OR REPLACE FUNCTION contar_filme_visto()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE film
    SET film_name = film_name  -- Apenas para manter o timestamp
    WHERE filmID = NEW.film_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_contar_filme_visto
AFTER INSERT ON film_seen
FOR EACH ROW
EXECUTE FUNCTION contar_filme_visto();


-- TRIGGER 2: Validação de ranking (deve estar entre 1 e 6)
CREATE OR REPLACE FUNCTION validar_ranking()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.ranking < 1 OR NEW.ranking > 6 THEN
        RAISE EXCEPTION 'Ranking deve estar entre 1 e 6, valor fornecido: %', NEW.ranking;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_validar_ranking
BEFORE INSERT OR UPDATE ON film_ranking
FOR EACH ROW
EXECUTE FUNCTION validar_ranking();


-- TRIGGER 3: Garantir que character_opinion não fica com opinion vazia
CREATE OR REPLACE FUNCTION validar_opinion_nao_vazia()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.opinion IS NULL OR TRIM(NEW.opinion) = '' THEN
        RAISE EXCEPTION 'A opinião não pode estar vazia';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_validar_opinion_nao_vazia
BEFORE INSERT OR UPDATE ON character_opinion
FOR EACH ROW
EXECUTE FUNCTION validar_opinion_nao_vazia();
