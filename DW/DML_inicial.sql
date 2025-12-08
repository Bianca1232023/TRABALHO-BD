--DML
INSERT INTO dw.dim_respondent (respondent_id, gender, age_group, household_income, education, region)
SELECT DISTINCT respondent_id, gender, age::text, household_income, education, region
FROM public.respostas
ON CONFLICT (respondent_id) DO NOTHING;

INSERT INTO dw.dim_film (film_id, film_name)
SELECT filmid, film_name
FROM public.film
ON CONFLICT (film_id) DO NOTHING;

INSERT INTO dw.dim_character (character_id, character_name)
SELECT character_id, character_name
FROM public.character_film
ON CONFLICT (character_id) DO NOTHING;

INSERT INTO dw.fato_respostas (
    respondent_id, film_id, character_id, opinion, seen, ranking, fan_star_wars, fan_star_trek
)
SELECT 
    r.respondent_id,
    fs.film_id,
    co.character_id,
    co.opinion,
    CASE WHEN fs.seen IS NOT NULL THEN TRUE ELSE FALSE END,
    fr.ranking,
    CASE WHEN r.fan_of_star_wars = 'Yes' THEN TRUE ELSE FALSE END,
    CASE WHEN r.fan_of_startrek = 'Yes' THEN TRUE ELSE FALSE END
FROM public.respostas r
LEFT JOIN public.film_seen fs ON fs.respondent_id = r.id
LEFT JOIN public.film_ranking fr ON fr.respondent_id = r.id
LEFT JOIN public.character_opinion co ON co.respondent_id = r.id;