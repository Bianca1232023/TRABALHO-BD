CREATE OR REPLACE FUNCTION fn_fato_respostas()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO dw.fato_respostas (respondent_id, film_id, character_id, opinion, seen, ranking, fan_star_wars, fan_star_trek, action)
        VALUES (NEW.respondent_id, NEW.film_id, NEW.character_id, NEW.opinion, NEW.seen, NEW.ranking,
            NEW.fan_star_wars, NEW.fan_star_trek, 'I')
        ON CONFLICT (respondent_id, film_id, character_id)
            DO UPDATE SET opinion = EXCLUDED.opinion,
                          seen = EXCLUDED.seen,
                          ranking = EXCLUDED.ranking,
                          fan_star_wars = EXCLUDED.fan_star_wars,
                          fan_star_trek = EXCLUDED.fan_star_trek,
                          action = 'U';
        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
        UPDATE dw.fato_respostas
        SET opinion = NEW.opinion,
            seen = NEW.seen,
            ranking = NEW.ranking,
            fan_star_wars = NEW.fan_star_wars,
            fan_star_trek = NEW.fan_star_trek,
            action = 'U'
        WHERE respondent_id = OLD.respondent_id
          AND film_id = OLD.film_id
          AND character_id = OLD.character_id;
        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        UPDATE dw.fato_respostas
        SET action = 'D'
        WHERE respondent_id = OLD.respondent_id
          AND film_id = OLD.film_id
          AND character_id = OLD.character_id;
        RETURN OLD;
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trg_fato_respostas
AFTER INSERT OR UPDATE OR DELETE ON public.respostas
FOR EACH ROW
EXECUTE FUNCTION fn_fato_respostas();