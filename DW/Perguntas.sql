/* 
------------------------------------------------------------------------------------------
1) OPINIÕES (opinion)
------------------------------------------------------------------------------------------
    VF  = Very Favorably
    SF  = Somewhat Favorably
    N   = Neutral
    SU  = Somewhat Unfavorably
    VU  = Very Unfavorably

------------------------------------------------------------------------------------------
2) CATEGORIA DE IDADE (age_group)
------------------------------------------------------------------------------------------
    YA  = 18–29 anos
    AD  = 30–44 anos
    MA  = 45–60 anos
    SR  = >60 anos

------------------------------------------------------------------------------------------
3) RENDA (household_income)
------------------------------------------------------------------------------------------
    L   = Menos de $25,000
    LM  = $25,000 – $49,999
    M   = $50,000 – $99,999
    UM  = $100,000 – $149,999
    H   = $150,000+

------------------------------------------------------------------------------------------
4) ESCOLARIDADE (education)
------------------------------------------------------------------------------------------
    LHS = Less than High School
    HS  = High School
    AS  = Associate's degree
    BA  = Bachelor's degree
    GR  = Graduate degree

------------------------------------------------------------------------------------------
5) GÊNERO (gender)
------------------------------------------------------------------------------------------
    M   = Male
    F   = Female
*/


/* 1. Quais personagens têm mais opiniões positivas? (VF + SF) */
SELECT c.character_name, COUNT(*) AS total_positivas
FROM dw.fact_response f
JOIN dw.dim_character c ON c.character_id = f.character_id
JOIN dw.dim_answer_option ao ON ao.option_id = f.option_id
WHERE ao.code IN ('VF','SF')
GROUP BY c.character_name
ORDER BY total_positivas DESC;

/* 2. Personagens mais rejeitados (SU + VU) */
SELECT c.character_name, COUNT(*) AS total_negativas
FROM dw.fact_response f
JOIN dw.dim_character c ON c.character_id = f.character_id
JOIN dw.dim_answer_option ao ON ao.option_id = f.option_id
WHERE ao.code IN ('SU','VU')
GROUP BY c.character_name
ORDER BY total_negativas DESC;


/* 3. Personagem mais amado por faixa etária */
SELECT r.age_group, c.character_name, COUNT(*) AS total_likes
FROM dw.fact_response f
JOIN dw.dim_character c ON c.character_id = f.character_id
JOIN dw.dim_answer_option ao ON ao.option_id = f.option_id
JOIN dw.dim_respondent r ON r.respondent_id = f.respondent_id
WHERE ao.code IN ('VF','SF')
GROUP BY r.age_group, c.character_name
ORDER BY r.age_group, total_likes DESC;

/* 4. Personagem mais rejeitado de Star Wars */

SELECT c.character_name, COUNT(*) AS rejeicoes
FROM dw.fact_response f
JOIN dw.dim_character c ON c.character_id = f.character_id
JOIN dw.dim_answer_option ao ON ao.option_id = f.option_id
JOIN dw.dim_respondent r ON r.respondent_id = f.respondent_id
WHERE ao.code IN ('SU','VU')  
GROUP BY c.character_name
ORDER BY rejeicoes DESC;

/* 5. Diferença de opinião dos personagens por gênero */
SELECT c.character_name, r.gender, COUNT(*) AS total
FROM dw.fact_response f
JOIN dw.dim_character c ON c.character_id = f.character_id
JOIN dw.dim_answer_option ao ON ao.option_id = f.option_id
JOIN dw.dim_respondent r ON r.respondent_id = f.respondent_id
WHERE ao.code IN ('VF','SF')
GROUP BY c.character_name, r.gender
ORDER BY c.character_name, total DESC;


/* 6. Escolaridade influencia opinião sobre Darth Vader? */
SELECT r.education,
       COUNT(*) FILTER (WHERE ao.code IN ('VF','SF')) AS positivas,
       COUNT(*) FILTER (WHERE ao.code IN ('SU','VU')) AS negativas
FROM dw.fact_response f
JOIN dw.dim_respondent r ON r.respondent_id = f.respondent_id
JOIN dw.dim_answer_option ao ON ao.option_id = f.option_id
WHERE f.character_id = 7
GROUP BY r.education
ORDER BY r.education;

/* 7. Filme mais assistido */
SELECT d.film_name, COUNT(*) AS total_seen
FROM dw.fact_response f
JOIN dw.dim_film d ON d.film_id = f.film_id
WHERE f.seen = TRUE
GROUP BY d.film_name
ORDER BY total_seen DESC;

/* 8. Ranking médio dos filmes */
SELECT d.film_name, AVG(f.ranking) AS ranking_medio
FROM dw.fact_response f
JOIN dw.dim_film d ON d.film_id = f.film_id
WHERE f.ranking IS NOT NULL
GROUP BY d.film_name
ORDER BY ranking_medio ASC;

/* 9. Ranking mediano */
SELECT d.film_name,
       PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY f.ranking) AS mediana_ranking
FROM dw.fact_response f
JOIN dw.dim_film d ON d.film_id = f.film_id
WHERE f.ranking IS NOT NULL
GROUP BY d.film_name
ORDER BY mediana_ranking;

/* 10. Filme favorito por faixa etária */
SELECT r.age_group, d.film_name, COUNT(*) AS total
FROM dw.fact_response f
JOIN dw.dim_film d ON d.film_id = f.film_id
JOIN dw.dim_respondent r ON r.respondent_id = f.respondent_id
WHERE f.ranking = 1
GROUP BY r.age_group, d.film_name
ORDER BY r.age_group, total DESC;

/* 11. Popularidade dos filmes por região */
SELECT r.region, d.film_name, COUNT(*) AS total
FROM dw.fact_response f
JOIN dw.dim_film d ON d.film_id = f.film_id
JOIN dw.dim_respondent r ON r.respondent_id = f.respondent_id
WHERE f.seen = TRUE
GROUP BY r.region, d.film_name
ORDER BY r.region, total DESC;

/* 12. Correlação aproximada entre opinião de personagens e ranking dos filmes */
SELECT f.film_id,
       AVG(f2.opinion_score) AS media_opiniao,
       AVG(f.ranking) AS media_ranking
FROM dw.fact_response f
JOIN (
    SELECT respondent_id,
           CASE ao.code
                WHEN 'VF' THEN 2
                WHEN 'SF' THEN 1
                WHEN 'N'  THEN 0
                WHEN 'SU' THEN -1
                WHEN 'VU' THEN -2
                ELSE NULL
           END AS opinion_score
    FROM dw.fact_response fr
    JOIN dw.dim_answer_option ao ON ao.option_id = fr.option_id
) f2 ON f2.respondent_id = f.respondent_id
GROUP BY f.film_id
ORDER BY f.film_id;

/* 13. Distribuição por renda */
SELECT household_income, COUNT(*)
FROM dw.dim_respondent
GROUP BY household_income
ORDER BY household_income;

/* 14. Quem vê mais filmes por renda */
SELECT r.household_income, COUNT(*) AS total_seen
FROM dw.fact_response f
JOIN dw.dim_respondent r ON r.respondent_id = f.respondent_id
WHERE f.seen = TRUE
GROUP BY r.household_income
ORDER BY total_seen DESC;

/* 15. Respondentes que viram todos os filmes */
SELECT respondent_id
FROM dw.fact_response
WHERE seen = TRUE
GROUP BY respondent_id
HAVING COUNT(DISTINCT film_id) = 6;

/* 16. Personagem mais amado entre fãs de Star Trek */
SELECT c.character_name, COUNT(*) AS total
FROM dw.fact_response f
JOIN dw.dim_character c ON c.character_id = f.character_id
JOIN dw.dim_answer_option ao ON ao.option_id = f.option_id
JOIN dw.dim_respondent r ON r.respondent_id = f.respondent_id
WHERE ao.code IN ('VF','SF')
GROUP BY c.character_name
ORDER BY total DESC;