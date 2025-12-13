CREATE OR REPLACE FUNCTION fn_dim_question()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO dw.dim_question (question_id, statement, action)
        VALUES (NEW.id, NEW.statement, 'I')
        ON CONFLICT (question_id)
            DO UPDATE SET statement = EXCLUDED.statement,
                          action = 'U';
        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
        UPDATE dw.dim_question
        SET statement = NEW.statement,
            action = 'U'
        WHERE question_id = OLD.id;
        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        UPDATE dw.dim_question
        SET action = 'D'
        WHERE question_id = OLD.id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_dim_question
AFTER INSERT OR UPDATE OR DELETE ON public.question
FOR EACH ROW EXECUTE FUNCTION fn_dim_question();