CREATE SCHEMA IF NOT EXISTS dw;

DROP TABLE IF EXISTS dw.fact_opinion CASCADE;
DROP TABLE IF EXISTS dw.dim_respondent CASCADE;
DROP TABLE IF EXISTS dw.dim_film CASCADE;
DROP TABLE IF EXISTS dw.dim_character CASCADE;

CREATE TYPE action_type AS ENUM ('I','U','D');

CREATE TABLE dw.dim_respondent (
    id serial4 PRIMARY KEY,
    respondent_id int4 NOT NULL,
    gender varchar(20),
    age int4,
    household_income varchar(50),
    education varchar(100),
    region varchar(100),
    action action_type DEFAULT 'I',
    created_at timestamptz DEFAULT now(),
    UNIQUE (respondent_id)
);

CREATE TABLE dw.dim_film (
    id serial4 PRIMARY KEY,
    film_id int4 NOT NULL,
    film_name varchar(255) NOT NULL,
    action action_type DEFAULT 'I',
    created_at timestamptz DEFAULT now(),
    UNIQUE (film_id, film_name)
);

CREATE TABLE dw.dim_character (
    id serial4 PRIMARY KEY,
    character_id int4 NOT NULL,
    character_name varchar(255) NOT NULL,
    action action_type DEFAULT 'I',
    created_at timestamptz DEFAULT now(),
    UNIQUE (character_id, character_name)
);

CREATE TABLE dw.fact_opinion (
    id serial4 PRIMARY KEY,
    respondent_id int4 NOT NULL,
    film_id int4,
    character_id int4,
    opinion int4,
    ranking int4,
    seen boolean,
    fan_star_wars boolean,
    fan_star_trek boolean,
    action action_type DEFAULT 'I',
    created_at timestamptz DEFAULT now(),
    FOREIGN KEY (respondent_id) REFERENCES dw.dim_respondent(id) ON DELETE CASCADE,
    FOREIGN KEY (film_id) REFERENCES dw.dim_film(id) ON DELETE CASCADE,
    FOREIGN KEY (character_id) REFERENCES dw.dim_character(id) ON DELETE CASCADE,
    UNIQUE (respondent_id, film_id, character_id)
);

CREATE INDEX ix_dw_fact_opinion_respondent ON dw.fact_opinion (respondent_id);
CREATE INDEX ix_dw_fact_opinion_film ON dw.fact_opinion (film_id);
CREATE INDEX ix_dw_fact_opinion_character ON dw.fact_opinion (character_id);

CREATE TABLE etl_execution (
    process VARCHAR(100) PRIMARY KEY,
    last_execution TIMESTAMP
);