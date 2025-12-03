CREATE TABLE film (
    filmID INT PRIMARY KEY,
    film_name VARCHAR(100) NOT NULL
);

CREATE TABLE respondent (
    respondent_id INT PRIMARY KEY,
    gender VARCHAR(50),
    age INT,
    household_income VARCHAR(50),
    education VARCHAR(50),
    region VARCHAR(50),
    seen_any_star_wars VARCHAR(50),
    fan_of_star_wars VARCHAR(50),
    fan_of_startrek VARCHAR(50),
    fan_of_expanded_universe VARCHAR(50),
    who_shot_first VARCHAR(50)
);


CREATE TABLE film_seen (
    film_seen_id INT PRIMARY KEY,
    respondent_id INT NOT NULL REFERENCES respondent(respondentID),
    film_id INT NOT NULL REFERENCES film(filmID),
    seen VARCHAR(50)
);

CREATE TABLE film_ranking (
    film_ranking_id INT PRIMARY KEY,
    respondent_id INT NOT NULL REFERENCES respondent(respondentID),
    film_id INT NOT NULL REFERENCES film(filmID),
    ranking INT
);

CREATE TABLE character(
    character_id INT PRIMARY KEY,
    character_name VARCHAR(100) NOT NULL
);

CREATE TABLE character_opinion (
    id INT PRIMARY KEY,
    respondent_id INT NOT NULL REFERENCES respondent(respondent_id),
    character_id INT NOT NULL REFERENCES character(character_id),
    opinion VARCHAR(20) 
);



