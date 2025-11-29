CREATE TABLE respondent(
    respondentID SERIAL PRIMARY KEY,
    gender VARCHAR(50),
    age VARCHAR(50),
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
    id SERIAL PRIMARY KEY,
    respondent_id INT REFERENCES respondent(respondent_id),
    film_name VARCHAR(100),
    seen VARCHAR(50) 
);

CREATE TABLE film_ranking (
    id SERIAL PRIMARY KEY,
    respondent_id INT REFERENCES respondent(respondent_id),
    film_name VARCHAR(100),
    ranking INT
);

CREATE TABLE character_opinion (
    id SERIAL PRIMARY KEY,
    respondent_id INT REFERENCES respondent(respondent_id),
    character_name VARCHAR(100),
    opinion VARCHAR(50)  
);


