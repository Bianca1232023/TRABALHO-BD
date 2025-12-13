CREATE OR REPLACE FUNCTION fn_dim_answer_option()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO dw.dim_answer_option (option_id, question_id, code, label, action)
        VALUES (NEW.id, NEW.question_id, NEW.code, NEW.label, 'I')
        ON CONFLICT (option_id)
            DO UPDATE SET question_id = EXCLUDED.question_id,
                          code = EXCLUDED.code,
                          label = EXCLUDED.label,
                          action = 'U';
        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
        UPDATE dw.dim_answer_option
        SET question_id = NEW.question_id,
            code = NEW.code,
            label = NEW.label,
            action = 'U'
        WHERE option_id = OLD.id;
        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        UPDATE dw.dim_answer_option
        SET action = 'D'
        WHERE option_id = OLD.id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_dim_answer_option
AFTER INSERT OR UPDATE OR DELETE ON public.answer_option
FOR EACH ROW EXECUTE FUNCTION fn_dim_answer_option();