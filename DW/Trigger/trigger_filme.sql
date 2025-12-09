CREATE OR REPLACE FUNCTION fn_dim_film()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO dw.dim_film (film_id, film_name, action)
        VALUES (NEW.film_id, NEW.film_name, 'I')
        ON CONFLICT (film_id)
            DO UPDATE SET film_name = EXCLUDED.film_name,
                          action = 'U';
        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
        UPDATE dw.dim_film
        SET film_name = NEW.film_name,
            action = 'U'
        WHERE film_id = OLD.film_id;
        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        UPDATE dw.dim_film
        SET action = 'D'
        WHERE film_id = OLD.film_id;
        RETURN OLD;
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_dim_film
AFTER INSERT OR UPDATE OR DELETE ON public.film
FOR EACH ROW
EXECUTE FUNCTION fn_dim_film();