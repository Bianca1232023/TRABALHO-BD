CREATE OR REPLACE FUNCTION fn_dim_character()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO dw.dim_character (character_id, character_name, action)
        VALUES (NEW.id, NEW.name, 'I')
        ON CONFLICT (character_id)
            DO UPDATE SET character_name = EXCLUDED.character_name,
                          action = 'U';
        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
        UPDATE dw.dim_character
        SET character_name = NEW.name,
            action = 'U'
        WHERE character_id = OLD.id;
        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        UPDATE dw.dim_character
        SET action = 'D'
        WHERE character_id = OLD.id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_dim_character
AFTER INSERT OR UPDATE OR DELETE ON public.character
FOR EACH ROW EXECUTE FUNCTION fn_dim_character();