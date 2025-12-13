CREATE OR REPLACE FUNCTION fn_fact_response()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO dw.fact_response (
            respondent_id, question_id, option_id, film_id, seen, ranking, character_id, action
        )
        VALUES (
            NEW.respondent_id, NEW.question_id, NEW.option_id,
            NEW.film_id, NEW.seen, NEW.ranking, NEW.character_id, 'I'
        )
        ON CONFLICT (respondent_id, question_id, film_id, character_id)
            DO UPDATE SET
                option_id    = COALESCE(EXCLUDED.option_id, dw.fact_response.option_id),
                seen         = COALESCE(EXCLUDED.seen, dw.fact_response.seen),
                ranking      = COALESCE(EXCLUDED.ranking, dw.fact_response.ranking),
                character_id = COALESCE(EXCLUDED.character_id, dw.fact_response.character_id),
                action       = 'U';
        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
        UPDATE dw.fact_response
        SET option_id    = COALESCE(NEW.option_id, option_id),
            seen         = COALESCE(NEW.seen, seen),
            ranking      = COALESCE(NEW.ranking, ranking),
            character_id = COALESCE(NEW.character_id, character_id),
            action       = 'U'
        WHERE respondent_id = OLD.respondent_id
          AND COALESCE(question_id, -1) = COALESCE(OLD.question_id, -1)
          AND COALESCE(film_id, -1)     = COALESCE(OLD.film_id, -1)
          AND COALESCE(character_id, -1)= COALESCE(OLD.character_id, -1);
        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        UPDATE dw.fact_response
        SET action = 'D'
        WHERE respondent_id = OLD.respondent_id
          AND COALESCE(question_id, -1) = COALESCE(OLD.question_id, -1)
          AND COALESCE(film_id, -1)     = COALESCE(OLD.film_id, -1)
          AND COALESCE(character_id, -1)= COALESCE(OLD.character_id, -1);
        RETURN OLD;
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_fact_response_answer
AFTER INSERT OR UPDATE OR DELETE ON public.answer
FOR EACH ROW EXECUTE FUNCTION fn_fact_response();

CREATE TRIGGER trg_fact_response_seen
AFTER INSERT OR UPDATE OR DELETE ON public.film_seen
FOR EACH ROW EXECUTE FUNCTION fn_fact_response();

CREATE TRIGGER trg_fact_response_ranking
AFTER INSERT OR UPDATE OR DELETE ON public.film_ranking
FOR EACH ROW EXECUTE FUNCTION fn_fact_response();

CREATE TRIGGER trg_fact_response_opinion
AFTER INSERT OR UPDATE OR DELETE ON public.character_opinion
FOR EACH ROW EXECUTE FUNCTION fn_fact_response();