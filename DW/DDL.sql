set schema 'dw';

--DROP TABLE IF EXISTS dw.dim_respondent CASCADE;
--DROP TABLE IF EXISTS dw.dim_film CASCADE;
--DROP TABLE IF EXISTS dw.dim_character CASCADE;
--DROP TABLE IF EXISTS dw.dim_question CASCADE;
--DROP TABLE IF EXISTS dw.dim_answer_option CASCADE;
--DROP TABLE IF EXISTS dw.fact_response CASCADE;
--DROP TABLE IF EXISTS dw.etl_execution CASCADE;

CREATE TYPE dw.action_type AS ENUM ('I','U','D');

-- =========================================================
-- DIMENSÕES
-- =========================================================

CREATE TABLE dw.dim_respondent (
    id SERIAL PRIMARY KEY,
    respondent_id BIGINT NOT NULL,
    gender VARCHAR(20),
    age_group VARCHAR(20),
    household_income VARCHAR(50),
    education VARCHAR(100),
    region VARCHAR(100),
    action action_type DEFAULT 'I',
    created_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE (respondent_id)
);

CREATE TABLE dw.dim_film (
    id SERIAL PRIMARY KEY,
    film_id INT NOT NULL,
    film_name VARCHAR(100) NOT NULL,
    action action_type DEFAULT 'I',
    created_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE (film_id)
);

CREATE TABLE dw.dim_character (
    id SERIAL PRIMARY KEY,
    character_id INT NOT NULL,
    character_name VARCHAR(100) NOT NULL,
    action action_type DEFAULT 'I',
    created_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE (character_id)
);

CREATE TABLE dw.dim_question (
    id SERIAL PRIMARY KEY,
    question_id BIGINT NOT NULL,
    statement VARCHAR(255) NOT NULL,
    action action_type DEFAULT 'I',
    created_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE (question_id)
);

CREATE TABLE dw.dim_answer_option (
    id SERIAL PRIMARY KEY,
    option_id BIGINT NOT NULL,
    question_id BIGINT NOT NULL,
    code VARCHAR(30),
    label VARCHAR(255),
    action action_type DEFAULT 'I',
    created_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE (option_id)
);

-- =========================================================
-- FATO
-- =========================================================

CREATE TABLE dw.fact_response (
    id SERIAL PRIMARY KEY,    
    respondent_id BIGINT NOT NULL,
    question_id BIGINT,
    option_id BIGINT,    
    film_id INT,
    seen BOOLEAN,
    ranking INT,    
    character_id INT,    
    action dw.action_type DEFAULT 'I',
    created_at TIMESTAMPTZ DEFAULT now(),

    FOREIGN KEY (respondent_id) REFERENCES dw.dim_respondent(respondent_id),
    FOREIGN KEY (question_id) REFERENCES dw.dim_question(question_id),
    FOREIGN KEY (option_id) REFERENCES dw.dim_answer_option(option_id),
    FOREIGN KEY (film_id) REFERENCES dw.dim_film(film_id),
    FOREIGN KEY (character_id) REFERENCES dw.dim_character(character_id)
);

CREATE INDEX ix_fact_response_respondent ON dw.fact_response (respondent_id);
CREATE INDEX ix_fact_response_question ON dw.fact_response (question_id);
CREATE INDEX ix_fact_response_option ON dw.fact_response (option_id);
CREATE INDEX ix_fact_response_film ON dw.fact_response (film_id);
CREATE INDEX ix_fact_response_character ON dw.fact_response (character_id);
CREATE INDEX ix_fact_response_seen ON dw.fact_response (seen);
CREATE INDEX ix_fact_response_ranking ON dw.fact_response (ranking);


CREATE TABLE dw.etl_execution (
    process VARCHAR(100) PRIMARY KEY,
    last_execution TIMESTAMP
);
