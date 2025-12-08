-- Perguntas
--1.Quais personagens têm as opiniões mais positivas?
SELECT
    c.character_name,
    COUNT(*) AS total_opinioes
FROM dw.fato_respostas f
JOIN dw.dim_character c ON c.character_id = f.character_id
WHERE f.opinion IN ('Very favorably', 'Somewhat favorably')
GROUP BY c.character_name
ORDER BY total_opinioes DESC;

--2. Filmes mais vistos por faixa etária - verificar se está retornando certo
SELECT
    r.age_group,
    f2.film_name,
    COUNT(*) AS total_seen
FROM dw.fato_respostas f
JOIN dw.dim_film f2 ON f2.film_id = f.film_id
JOIN dw.dim_respondent r ON r.respondent_id = f.respondent_id
WHERE f.seen = TRUE
GROUP BY r.age_group, f2.film_name
ORDER BY r.age_group, total_seen DESC;

--3. Quantos fãs de Star Wars também são fãs de Star Trek?

WITH por_respondente AS (
    SELECT
        f.respondent_id,
        BOOL_OR(fan_star_wars) AS fan_star_wars,
        BOOL_OR(fan_star_trek) AS fan_star_trek
    FROM dw.fato_respostas f
    GROUP BY f.respondent_id
)
SELECT
    CASE
        WHEN fan_star_wars = TRUE AND fan_star_trek = TRUE THEN 'Ambas'
        WHEN fan_star_wars = TRUE AND fan_star_trek = FALSE THEN 'Apenas Star Wars'
        WHEN fan_star_wars = FALSE AND fan_star_trek = TRUE THEN 'Apenas Star Trek'
        ELSE 'Nenhum'
    END AS categoria,
    COUNT(*) AS total_respondentes
FROM por_respondente
GROUP BY categoria
ORDER BY categoria;