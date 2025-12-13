INSERT INTO film (film_name)
SELECT DISTINCT film_name
FROM (
    SELECT film_name
    FROM (
        SELECT "Which of the following Star Wars films have you seen? Please se" AS film_name FROM star_wars
        UNION ALL SELECT "Unnamed: 4" FROM star_wars
        UNION ALL SELECT "Unnamed: 5" FROM star_wars
        UNION ALL SELECT "Unnamed: 6" FROM star_wars
        UNION ALL SELECT "Unnamed: 7" FROM star_wars
        UNION ALL SELECT "Unnamed: 8" FROM star_wars
    ) AS all_films_raw
    WHERE film_name IS NOT NULL
      AND TRIM(film_name) <> ''
    ORDER BY 
        CASE
            WHEN film_name LIKE '%Episode I The Phantom Menace%' THEN 1
            WHEN film_name LIKE '%Episode II Attack of the Clones%' THEN 2
            WHEN film_name LIKE '%Episode III Revenge of the Sith%' THEN 3
            WHEN film_name LIKE '%Episode IV A New Hope%' THEN 4
            WHEN film_name LIKE '%Episode V The Empire Strikes Back%' THEN 5
            WHEN film_name LIKE '%Episode VI Return of the Jedi%' THEN 6
            ELSE 999
        END
) AS ordered_films;

INSERT INTO respondentid 
SELECT
	distinct
	sw."respondentid"::bigint
	FROM star_wars sw
	WHERE sw."respondentid" IS NOT null;


INSERT INTO respostas(
    respondent_id,
    gender,
    age,
    household_income,
    education,
    region,
    seen_any_star_wars,
    fan_of_star_wars,
    fan_of_startrek,
    fan_of_expanded_universe,
    familiar_with_expanded_universe,
    who_shot_first)
SELECT 
    sw."respondentid"::BIGINT,
    sw."gender",
    CASE
        WHEN TRIM(sw.age) = '18-29' THEN '18-29'::idade
        WHEN TRIM(sw.age) = '30-44' THEN '30-44'::idade
        WHEN TRIM(sw.age) = '45-60' THEN '45-60'::idade
        WHEN TRIM(sw.age) = '> 60'   THEN '>60'::idade
        ELSE NULL
    END AS age,
    sw."Household Income",
    sw."education",
    sw."Location (Census Region)",
    sw."Have you seen any of the 6 films in the Star Wars franchise?",
    sw."Do you consider yourself to be a fan of the Star Wars film fran",
    sw."Do you consider yourself to be a fan of the Star Trek franchise",
    sw."Do you consider yourself to be a fan of the Expanded Universe?",
    sw."Are you familiar with the Expanded Universe?",
    sw."Which character shot first?"
FROM star_wars sw
WHERE sw."respondentid" IS NOT null;

SELECT COUNT (*) FROM respostas; 
SELECT COUNT (*) FROM star_wars sw;

INSERT INTO character_film (character_id , character_name)
VALUES
(1, 'Han Solo'),
(2, 'Luke Skywalker'),
(3, 'Princess Leia Organa'),
(4, 'Anakin Skywalker'),
(5, 'Obi Wan Kenobi'),
(6, 'Emperor Palpatine'),
(7, 'Darth Vader'),
(8, 'Lando Calrissian'),
(9, 'Boba Fett'),
(10, 'C-3P0'),
(11, 'R2 D2'),
(12, 'Jar Jar Binks'),
(13, 'Padme Amidala'),
(14, 'Yoda');

INSERT INTO film_seen (respondent_id, film_id, seen)
SELECT 
    r.id,
    f.filmID,
    CASE f.filmID
        WHEN 1 THEN sw."Which of the following Star Wars films have you seen? Please se"
        WHEN 2 THEN sw."Unnamed: 4"
        WHEN 3 THEN sw."Unnamed: 5"
        WHEN 4 THEN sw."Unnamed: 6"
        WHEN 5 THEN sw."Unnamed: 7"
        WHEN 6 THEN sw."Unnamed: 8"
    END AS seen
FROM star_wars sw
JOIN respostas r ON sw."respondentid"::BIGINT = r.respondent_id
CROSS JOIN film f
WHERE CASE f.filmID
        WHEN 1 THEN sw."Which of the following Star Wars films have you seen? Please se"
        WHEN 2 THEN sw."Unnamed: 4"
        WHEN 3 THEN sw."Unnamed: 5"
        WHEN 4 THEN sw."Unnamed: 6"
        WHEN 5 THEN sw."Unnamed: 7"
        WHEN 6 THEN sw."Unnamed: 8"
    END IS NOT NULL;



INSERT INTO film_ranking (respondent_id, film_id, ranking)
SELECT 
    r.id,
    f.filmID,
    CASE f.filmID
        WHEN 1 THEN NULLIF(TRIM(sw."Please rank the Star Wars films in order of preference with 1 b"), '')::INT
        WHEN 2 THEN NULLIF(TRIM(sw."Unnamed: 10"), '')::INT
        WHEN 3 THEN NULLIF(TRIM(sw."Unnamed: 11"), '')::INT
        WHEN 4 THEN NULLIF(TRIM(sw."Unnamed: 12"), '')::INT
        WHEN 5 THEN NULLIF(TRIM(sw."Unnamed: 13"), '')::INT
        WHEN 6 THEN NULLIF(TRIM(sw."Unnamed: 14"), '')::INT
    END AS ranking
FROM star_wars sw
JOIN respostas r ON sw."respondentid"::BIGINT = r.respondent_id
CROSS JOIN film f
WHERE CASE f.filmID
        WHEN 1 THEN NULLIF(TRIM(sw."Please rank the Star Wars films in order of preference with 1 b"), '')
        WHEN 2 THEN NULLIF(TRIM(sw."Unnamed: 10"), '')
        WHEN 3 THEN NULLIF(TRIM(sw."Unnamed: 11"), '')
        WHEN 4 THEN NULLIF(TRIM(sw."Unnamed: 12"), '')
        WHEN 5 THEN NULLIF(TRIM(sw."Unnamed: 13"), '')
        WHEN 6 THEN NULLIF(TRIM(sw."Unnamed: 14"), '')
    END IS NOT NULL;



INSERT INTO character_opinion (respondent_id, character_id, opinion)
SELECT 
    r.id,
    c.character_id,
    CASE c.character_id
        WHEN 1 THEN sw."Please state whether you view the following characters favorabl"
        WHEN 2 THEN sw."Unnamed: 16"
        WHEN 3 THEN sw."Unnamed: 17"
        WHEN 4 THEN sw."Unnamed: 18"
        WHEN 5 THEN sw."Unnamed: 19"
        WHEN 6 THEN sw."Unnamed: 20"
        WHEN 7 THEN sw."Unnamed: 21"
        WHEN 8 THEN sw."Unnamed: 22"
        WHEN 9 THEN sw."Unnamed: 23"
        WHEN 10 THEN sw."Unnamed: 24"
        WHEN 11 THEN sw."Unnamed: 25"
        WHEN 12 THEN sw."Unnamed: 26"
        WHEN 13 THEN sw."Unnamed: 27"
        WHEN 14 THEN sw."Unnamed: 28"
    END AS opinion
FROM star_wars sw
JOIN respostas r ON sw."respondentid"::BIGINT = r.respondent_id
CROSS JOIN character_film c
WHERE CASE c.character_id
        WHEN 1 THEN sw."Please state whether you view the following characters favorabl"
        WHEN 2 THEN sw."Unnamed: 16"
        WHEN 3 THEN sw."Unnamed: 17"
        WHEN 4 THEN sw."Unnamed: 18"
        WHEN 5 THEN sw."Unnamed: 19"
        WHEN 6 THEN sw."Unnamed: 20"
        WHEN 7 THEN sw."Unnamed: 21"
        WHEN 8 THEN sw."Unnamed: 22"
        WHEN 9 THEN sw."Unnamed: 23"
        WHEN 10 THEN sw."Unnamed: 24"
        WHEN 11 THEN sw."Unnamed: 25"
        WHEN 12 THEN sw."Unnamed: 26"
        WHEN 13 THEN sw."Unnamed: 27"
        WHEN 14 THEN sw."Unnamed: 28"
    END IS NOT NULL;






--insert into oi
-- select 
--  sw."RespondentID"::bigint
-- 	from star_wars sw 