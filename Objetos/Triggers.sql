-- TRIGGER 1: Validação de ranking (1 a 6)
CREATE OR REPLACE FUNCTION validar_ranking_filme()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.ranking < 1 OR NEW.ranking > 6 THEN
        RAISE EXCEPTION 'Ranking deve estar entre 1 e 6. Valor informado: %', NEW.ranking;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_ranking
BEFORE INSERT OR UPDATE ON film_ranking
FOR EACH ROW
EXECUTE FUNCTION validar_ranking_filme();


-- TRIGGER 2: Garantir que answer.option_id pertence à mesma pergunta
CREATE OR REPLACE FUNCTION validar_answer_option()
RETURNS TRIGGER AS $$
DECLARE
    v_question_id BIGINT;
BEGIN
    SELECT question_id INTO v_question_id
    FROM answer_option
    WHERE id = NEW.option_id;

    IF v_question_id IS NULL THEN
        RAISE EXCEPTION 'Option_id % não existe na tabela answer_option.', NEW.option_id;
    END IF;

    IF NEW.question_id <> v_question_id THEN
        RAISE EXCEPTION 'Option_id % pertence à pergunta %, mas question_id informado foi %.',
            NEW.option_id, v_question_id, NEW.question_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_answer_option
BEFORE INSERT OR UPDATE ON answer
FOR EACH ROW
EXECUTE FUNCTION validar_answer_option();


-- TRIGGER 3: Apenas opções da pergunta "Character opinion" em character_opinion
CREATE OR REPLACE FUNCTION validar_character_opinion_option()
RETURNS TRIGGER AS $$
DECLARE
    v_statement TEXT;
BEGIN
    SELECT q.statement INTO v_statement
    FROM answer_option ao
    JOIN question q ON q.id = ao.question_id
    WHERE ao.id = NEW.option_id;

    IF v_statement IS NULL OR v_statement <> 'Character opinion' THEN
        RAISE EXCEPTION 'Option_id % não pertence à pergunta "Character opinion".', NEW.option_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_character_opinion
BEFORE INSERT OR UPDATE ON character_opinion
FOR EACH ROW
EXECUTE FUNCTION validar_character_opinion_option();
