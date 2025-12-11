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
FROM dw.fato_respostas f
JOIN dw.dim_character c ON c.character_id = f.character_id
WHERE f.opinion IN ('VF','SF')
GROUP BY c.character_name
ORDER BY total_positivas DESC;

/* 2. Personagens mais rejeitados (SU + VU) */
SELECT c.character_name, COUNT(*) AS total_negativas
FROM dw.fato_respostas f
JOIN dw.dim_character c ON c.character_id = f.character_id
WHERE f.opinion IN ('SU','VU')
GROUP BY c.character_name
ORDER BY total_negativas DESC;

/* 3. Personagens mais desconhecidos (U) */
SELECT c.character_name, COUNT(*) AS desconhecimento
FROM dw.fato_respostas f
JOIN dw.dim_character c ON c.character_id = f.character_id
WHERE f.opinion = 'U'
GROUP BY c.character_name
ORDER BY desconhecimento DESC;

/* 4. Personagem mais amado por faixa etária */
SELECT r.age_group, c.character_name, COUNT(*) AS total_likes
FROM dw.fato_respostas f
JOIN dw.dim_character c ON c.character_id = f.character_id
JOIN dw.dim_respondent r ON r.respondent_id = f.respondent_id
WHERE f.opinion IN ('VF','SF')
GROUP BY r.age_group, c.character_name
ORDER BY r.age_group, total_likes DESC;

/* 5. Personagem mais rejeitado entre fãs de Star Wars */
SELECT c.character_name, COUNT(*) AS rejeicoes
FROM dw.fato_respostas f
JOIN dw.dim_character c ON c.character_id = f.character_id
WHERE f.opinion IN ('SU','VU')
  AND f.fan_star_wars = TRUE
GROUP BY c.character_name
ORDER BY rejeicoes DESC;

/* 6. Diferença de opinião por gênero */
SELECT c.character_name, r.gender, COUNT(*) AS total
FROM dw.fato_respostas f
JOIN dw.dim_character c USING (character_id)
JOIN dw.dim_respondent r USING (respondent_id)
WHERE f.opinion IN ('VF','SF')
GROUP BY c.character_name, r.gender
ORDER BY c.character_name, total DESC;

/* 7. Escolaridade influencia opinião sobre Darth Vader? */
SELECT r.education,
       COUNT(*) FILTER (WHERE f.opinion IN ('VF','SF')) AS positivas,
       COUNT(*) FILTER (WHERE f.opinion IN ('SU','VU')) AS negativas
FROM dw.fato_respostas f
JOIN dw.dim_respondent r USING (respondent_id)
WHERE f.character_id = 7
GROUP BY r.education
ORDER BY r.education;

/* 8. Filme mais assistido */
SELECT d.film_name, COUNT(*) AS total_seen
FROM dw.fato_respostas f
JOIN dw.dim_film d USING (film_id)
WHERE f.seen = TRUE
GROUP BY d.film_name
ORDER BY total_seen DESC;

/* 9. Ranking médio dos filmes */
SELECT d.film_name, AVG(f.ranking) AS ranking_medio
FROM dw.fato_respostas f
JOIN dw.dim_film d USING (film_id)
WHERE f.ranking IS NOT NULL
GROUP BY d.film_name
ORDER BY ranking_medio ASC;

/* 10. Ranking mediano */
SELECT d.film_name,
       PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY f.ranking) AS mediana_ranking
FROM dw.fato_respostas f
JOIN dw.dim_film d USING (film_id)
WHERE f.ranking IS NOT NULL
GROUP BY d.film_name
ORDER BY mediana_ranking;

/* 11. Filme favorito por faixa etária */
SELECT r.age_group, d.film_name, COUNT(*) AS total
FROM dw.fato_respostas f
JOIN dw.dim_film d USING (film_id)
JOIN dw.dim_respondent r USING (respondent_id)
WHERE f.ranking = 1
GROUP BY r.age_group, d.film_name
ORDER BY r.age_group, total DESC;

/* 12. Popularidade dos filmes por região */
SELECT r.region, d.film_name, COUNT(*) AS total
FROM dw.fato_respostas f
JOIN dw.dim_film d USING (film_id)
JOIN dw.dim_respondent r USING (respondent_id)
WHERE f.seen = TRUE
GROUP BY r.region, d.film_name
ORDER BY r.region, total DESC;

/* 13. Correlação aproximada entre opinião de personagens e ranking dos filmes */
SELECT f.film_id,
       AVG(f2.opinion_score) AS media_opiniao,
       AVG(f.ranking) AS media_ranking
FROM dw.fato_respostas f
JOIN (
    SELECT respondent_id,
           CASE opinion
                WHEN 'VF' THEN 2
                WHEN 'SF' THEN 1
                WHEN 'N'  THEN 0
                WHEN 'SU' THEN -1
                WHEN 'VU' THEN -2
                ELSE NULL
           END AS opinion_score
    FROM dw.fato_respostas
) f2 USING (respondent_id)
GROUP BY f.film_id
ORDER BY f.film_id;

/* 14. Filme mais popular entre nível BACHELOR */
SELECT d.film_name, COUNT(*) AS total_seen
FROM dw.fato_respostas f
JOIN dw.dim_film d USING (film_id)
JOIN dw.dim_respondent r USING (respondent_id)
WHERE f.seen = TRUE
  AND r.education = 'BA'
GROUP BY d.film_name
ORDER BY total_seen DESC;

/* 15. Distribuição por renda */
SELECT household_income, COUNT(*)
FROM dw.dim_respondent
GROUP BY household_income
ORDER BY household_income;

/* 16. Fãs de Star Wars têm maior escolaridade? */
SELECT r.education,
       COUNT(*) FILTER (WHERE f.fan_star_wars = TRUE) AS fans,
       COUNT(*) AS total
FROM dw.dim_respondent r
JOIN (SELECT DISTINCT respondent_id, fan_star_wars FROM dw.fato_respostas) f USING (respondent_id)
GROUP BY r.education
ORDER BY r.education;

/* 17. Renda influencia ser fã de Star Trek? */
SELECT r.household_income,
       COUNT(*) FILTER (WHERE f.fan_star_trek = TRUE) AS fans,
       COUNT(*) AS total
FROM dw.dim_respondent r
JOIN (SELECT DISTINCT respondent_id, fan_star_trek FROM dw.fato_respostas) f USING (respondent_id)
GROUP BY r.household_income
ORDER BY r.household_income;

/* 18. Grupo com mais desconhecimento de personagens */


/* 19. Quem vê mais filmes por renda */
SELECT r.household_income, COUNT(*) AS total_seen
FROM dw.fato_respostas f
JOIN dw.dim_respondent r USING (respondent_id)
WHERE f.seen = TRUE
GROUP BY r.household_income
ORDER BY total_seen DESC;

/* 20. Respondentes que viram todos os filmes */
SELECT respondent_id
FROM dw.fato_respostas
WHERE seen = TRUE
GROUP BY respondent_id
HAVING COUNT(*) = 6;

/* 21. Personagem mais amado entre fãs de Star Trek */
SELECT c.character_name, COUNT(*) AS total
FROM dw.fato_respostas f
JOIN dw.dim_character c USING (character_id)
WHERE f.opinion IN ('VF','SF')
  AND f.fan_star_trek = TRUE
GROUP BY c.character_name
ORDER BY total DESC;

/* 22. Personagens mais amados por quem viu todos os filmes */
WITH completos AS (
    SELECT respondent_id
    FROM dw.fato_respostas
    WHERE seen = TRUE
    GROUP BY respondent_id
    HAVING COUNT(DISTINCT film_id) = 6
)
SELECT c.character_name, COUNT(*) AS total
FROM dw.fato_respostas f
JOIN completos USING (respondent_id)
JOIN dw.dim_character c USING (character_id)
WHERE f.opinion IN ('VF','SF')
GROUP BY c.character_name
ORDER BY total DESC;

/* 23. Filme mais assistido por região */
SELECT r.region, d.film_name, COUNT(*) AS total
FROM dw.fato_respostas f
JOIN dw.dim_film d USING (film_id)
JOIN dw.dim_respondent r USING (respondent_id)
WHERE f.seen = TRUE
GROUP BY r.region, d.film_name
ORDER BY r.region, total DESC;

/* 24. Personagem mais controverso (VF + VU) */
SELECT c.character_name,
       COUNT(*) FILTER (WHERE f.opinion = 'VF') AS loves,
       COUNT(*) FILTER (WHERE f.opinion = 'VU') AS hates,
       (COUNT(*) FILTER (WHERE f.opinion = 'VF')
      + COUNT(*) FILTER (WHERE f.opinion = 'VU')) AS controversia
FROM dw.fato_respostas f
JOIN dw.dim_character c USING (character_id)
GROUP BY c.character_name
ORDER BY controversia DESC;

/* 25. Personagens mais amados entre renda alta */
SELECT c.character_name, COUNT(*) AS total_likes
FROM dw.fato_respostas f
JOIN dw.dim_respondent r USING (respondent_id)
JOIN dw.dim_character c USING (character_id)
WHERE r.household_income = 'H'
  AND f.opinion IN ('VF','SF')
GROUP BY c.character_name
ORDER BY total_likes DESC;

/* 26. Proporção de fãs de Star Wars */
SELECT COUNT(*) FILTER (WHERE f.fan_star_wars = TRUE) * 1.0 /
       COUNT(DISTINCT f.respondent_id) AS proporcao
FROM dw.fato_respostas f;

/* 27. Proporção de fãs de Star Trek */
SELECT COUNT(*) FILTER (WHERE f.fan_star_trek = TRUE) * 1.0 /
       COUNT(DISTINCT f.respondent_id) AS proporcao
FROM dw.fato_respostas f;

/* 28. Personagem mais amado entre não-fãs de Star Wars */
SELECT c.character_name, COUNT(*) AS total
FROM dw.fato_respostas f
JOIN dw.dim_character c USING (character_id)
WHERE f.opinion IN ('VF','SF')
  AND f.fan_star_wars = FALSE
GROUP BY c.character_name
ORDER BY total DESC;

/* 29. Personagem mais rejeitado entre fãs de Star Wars */
SELECT c.character_name, COUNT(*) AS total
FROM dw.fato_respostas f
JOIN dw.dim_character c USING (character_id)
WHERE f.opinion IN ('SU','VU')
  AND f.fan_star_wars = TRUE
GROUP BY c.character_name
ORDER BY total DESC;

/* 30. Correlação entre ranking do filme e opinião do protagonista */
SELECT f.film_id,
       AVG(f.ranking) AS ranking_medio,
       AVG(CASE p.opinion
            WHEN 'VF' THEN 2
            WHEN 'SF' THEN 1
            WHEN 'N'  THEN 0
            WHEN 'SU' THEN -1
            WHEN 'VU' THEN -2
            ELSE NULL END) AS media_opiniao
FROM dw.fato_respostas f
JOIN dw.fato_respostas p
  ON p.respondent_id = f.respondent_id
 AND p.character_id = 2   -- protagonista (Luke Skywalker)
WHERE f.ranking IS NOT NULL
GROUP BY f.film_id
ORDER BY f.film_id;