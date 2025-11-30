CREATE TABLE film (
    filmID INT PRIMARY KEY,
    film_name VARCHAR(100) NOT NULL
);

CREATE TABLE respondent(
    respondentID INT PRIMARY KEY,
    gender VARCHAR(50),
    age INT,
    household_income VARCHAR(50),
    education VARCHAR(50),
    region VARCHAR(50),
    seen_any_star_wars VARCHAR(50),
    fan_of_star_wars VARCHAR(50),
    fan_of_startrek VARCHAR(50),
    fan_of_expanded_universe VARCHAR(50),
    who_shot_first VARCHAR(50),
    opinion_han VARCHAR(50),
    opinion_luke VARCHAR(50),
    opinion_leia VARCHAR(50),
    opinion_anakin VARCHAR(50),
    opinion_palpatine VARCHAR(50),
    opinion_vader VARCHAR(50),
    opinion_calrissian VARCHAR(50),
    opinion_boba VARCHAR (50),
    opinion_C_3P0 VARCHAR (50),
    opinion_R2 VARCHAR(50),
    opinion_jarjar VARCHAR(50),
    opinion_padme VARCHAR (50),
    opinion_yoda VARCHAR(50)
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


