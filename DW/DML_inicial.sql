-- respondent

INSERT INTO dw.dim_respondent (
    respondent_id, gender, age_group, household_income, education, region
)
SELECT r.id,
       g.description,
       ag.age_range_start || '-' || ag.age_range_end,
       hi.income_range_start || '-' || hi.income_range_end,
       el.name,
       reg.name
FROM public.respondent r
LEFT JOIN public.gender g ON r.gender_id = g.id
LEFT JOIN public.age_group ag ON r.age_group_id = ag.id
LEFT JOIN public.household_income hi ON r.household_income_id = hi.id
LEFT JOIN public.education_level el ON r.education_level_id = el.id
LEFT JOIN public.region reg ON r.region_id = reg.id
ON CONFLICT (respondent_id) DO NOTHING;

-- film

INSERT INTO dw.dim_film (film_id, film_name)
SELECT f.id, f.name
FROM public.film f
ON CONFLICT (film_id) DO NOTHING;

-- character

INSERT INTO dw.dim_character (character_id, character_name)
SELECT c.id, c.name
FROM public.character c
ON CONFLICT (character_id) DO NOTHING;

-- question

INSERT INTO dw.dim_question (question_id, statement)
SELECT q.id, q.statement
FROM public.question q
ON CONFLICT (question_id) DO NOTHING;

-- option

INSERT INTO dw.dim_answer_option (option_id, question_id, code, label)
SELECT ao.id, ao.question_id, ao.code, ao.label
FROM public.answer_option ao
ON CONFLICT (option_id) DO NOTHING;

-- fato respostas

INSERT INTO dw.fact_response (respondent_id, question_id, option_id)
SELECT a.respondent_id, a.question_id, a.option_id
FROM public.answer a
ON CONFLICT DO NOTHING;

INSERT INTO dw.fact_response (respondent_id, film_id, seen)
SELECT fs.respondent_id, fs.film_id, TRUE
FROM public.film_seen fs
ON CONFLICT DO NOTHING;

INSERT INTO dw.fact_response (respondent_id, film_id, ranking)
SELECT fr.respondent_id, fr.film_id, fr.ranking
FROM public.film_ranking fr
ON CONFLICT DO NOTHING;

INSERT INTO dw.fact_response (respondent_id, character_id, option_id)
SELECT co.respondent_id, co.character_id, co.option_id
FROM public.character_opinion co
ON CONFLICT DO NOTHING;

