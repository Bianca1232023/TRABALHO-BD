-- TRIGGER 1: Audit de inserção em respostas
CREATE OR REPLACE FUNCTION audit_respostas_insert()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO audit_log (tabela, operacao, id_afetado, data_operacao)
    VALUES ('respostas', 'INSERT', NEW.id, CURRENT_TIMESTAMP);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_audit_respostas_insert
AFTER INSERT ON respostas
FOR EACH ROW
EXECUTE FUNCTION audit_respostas_insert();


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


-- TRIGGER 3: Atualizar timestamp de modificação em respostas
CREATE OR REPLACE FUNCTION atualizar_timestamp_respostas()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

ALTER TABLE respostas ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

CREATE TRIGGER trigger_atualizar_timestamp_respostas
BEFORE UPDATE ON respostas
FOR EACH ROW
EXECUTE FUNCTION atualizar_timestamp_respostas();
