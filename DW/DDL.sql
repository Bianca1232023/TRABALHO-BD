DROP TABLE IF EXISTS dw.fact_opinion CASCADE;
DROP TABLE IF EXISTS dw.dim_respondent CASCADE;
DROP TABLE IF EXISTS dw.dim_film CASCADE;
DROP TABLE IF EXISTS dw.dim_character CASCADE;
DROP TABLE IF EXISTS dw.fato_respostas CASCADE;
DROP TABLE IF EXISTS dw.etl_execution CASCADE;
DROP TABLE IF EXISTS dw.action_type CASCADE;

CREATE TYPE dw.action_type AS ENUM ('I','U','D');

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


CREATE TABLE dw.fato_respostas (
    id SERIAL PRIMARY KEY,
    respondent_id BIGINT NOT NULL,
    film_id INT,
    character_id INT,
    opinion VARCHAR(50),
    seen BOOLEAN,  
    ranking INT,    
    fan_star_wars BOOLEAN,
    fan_star_trek BOOLEAN,
    action action_type DEFAULT 'I',
    created_at TIMESTAMPTZ DEFAULT now(),
    FOREIGN KEY (respondent_id) REFERENCES dw.dim_respondent(respondent_id),
    FOREIGN KEY (film_id) REFERENCES dw.dim_film(film_id),
    FOREIGN KEY (character_id) REFERENCES dw.dim_character(character_id)
);

CREATE INDEX ix_fato_respostas_respondent ON dw.fato_respostas (respondent_id);
CREATE INDEX ix_fato_respostas_character ON dw.fato_respostas (character_id);
CREATE INDEX ix_fato_respostas_opinion ON dw.fato_respostas (opinion);
CREATE INDEX ix_fato_respostas_seen ON dw.fato_respostas (seen);
CREATE INDEX ix_fato_respostas_fanwars ON dw.fato_respostas (fan_star_wars);
CREATE INDEX ix_fato_respostas_fantrek ON dw.fato_respostas (fan_star_trek);

CREATE TABLE dw.etl_execution (
    process VARCHAR(100) PRIMARY KEY,
    last_execution TIMESTAMP
);