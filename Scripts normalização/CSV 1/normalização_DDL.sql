CREATE TABLE film (
    filmID INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    film_name VARCHAR(100) NOT NULL
);

CREATE TYPE idade AS ENUM (
    '18-29',
    '30-44',
    '45-60',
    '>60'
);

CREATE TABLE RespondentID (
    respondent_id BIGINT PRIMARY KEY
);

CREATE TABLE respostas (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    respondent_id BIGINT NOT NULL REFERENCES RespondentID(respondent_id),
    gender VARCHAR(50),
    age idade,
    household_income VARCHAR(50),
    education VARCHAR(50),
    region VARCHAR(50),
    seen_any_star_wars VARCHAR(50),
    fan_of_star_wars VARCHAR(50),
    fan_of_startrek VARCHAR(50),
    fan_of_expanded_universe VARCHAR(50),
    familiar_with_expanded_universe VARCHAR(50),
    who_shot_first VARCHAR(50)
);

CREATE TABLE film_seen (
    film_seen_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    respondent_id BIGINT NOT NULL REFERENCES respostas(id),
    film_id INT NOT NULL REFERENCES film(filmID),
    seen VARCHAR(50)
);

CREATE TABLE film_ranking (
    film_ranking_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    respondent_id BIGINT NOT NULL REFERENCES respostas(id),
    film_id INT NOT NULL REFERENCES film(filmID),
    ranking INT
);

CREATE TABLE character_film (
    character_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    character_name VARCHAR(100) NOT NULL
);

CREATE TABLE character_opinion (
    character_opinion_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    respondent_id BIGINT NOT NULL REFERENCES respostas(id),
    character_id INT NOT NULL REFERENCES character_film(character_id),
    opinion VARCHAR(20) 
);



