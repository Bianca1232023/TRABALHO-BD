CREATE OR REPLACE FUNCTION fn_dim_respondent()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO dw.dim_respondent (respondent_id, gender, age_group, household_income, education, region, action)
        VALUES (NEW.respondent_id, NEW.gender, NEW.age_group, NEW.household_income, NEW.education, NEW.region, 'I')
        ON CONFLICT (respondent_id)
            DO UPDATE SET gender = EXCLUDED.gender,
                          age_group = EXCLUDED.age_group,
                          household_income = EXCLUDED.household_income,
                          education = EXCLUDED.education,
                          region = EXCLUDED.region,
                          action = 'U';
        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
        UPDATE dw.dim_respondent
        SET gender = NEW.gender,
            age_group = NEW.age_group,
            household_income = NEW.household_income,
            education = NEW.education,
            region = NEW.region,
            action = 'U'
        WHERE respondent_id = OLD.respondent_id;
        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        UPDATE dw.dim_respondent
        SET action = 'D'
        WHERE respondent_id = OLD.respondent_id;
        RETURN OLD;
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_dim_respondent
AFTER INSERT OR UPDATE OR DELETE ON public.respostas
FOR EACH ROW
EXECUTE FUNCTION fn_dim_respondent();