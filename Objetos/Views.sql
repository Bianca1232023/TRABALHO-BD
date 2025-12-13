CREATE OR REPLACE VIEW v_respondentes_por_regiao AS
SELECT 
    COALESCE(rg.name, 'Não informado') AS region,
    COUNT(*) AS total_respondentes,
    ROUND(
        100.0 * COUNT(*) / NULLIF(SUM(COUNT(*)) OVER (), 0),
        2
    ) AS percentual
FROM respondent r
LEFT JOIN region rg ON rg.id = r.region_id
GROUP BY COALESCE(rg.name, 'Não informado')
ORDER BY total_respondentes DESC;


CREATE OR REPLACE VIEW v_ranking_medio_filmes AS
SELECT 
    f.id AS film_id,
    f.name AS film_name,
    COUNT(fr.ranking) AS total_rankings,
    ROUND(AVG(fr.ranking::NUMERIC), 2) AS ranking_medio,
    MIN(fr.ranking) AS melhor_ranking,
    MAX(fr.ranking) AS pior_ranking
FROM film f
LEFT JOIN film_ranking fr ON f.id = fr.film_id
GROUP BY f.id, f.name
ORDER BY ranking_medio ASC NULLS LAST;


CREATE OR REPLACE VIEW v_fans_vs_nao_fans AS
WITH fan_sw AS (
    SELECT a.respondent_id, ao.label
    FROM answer a
    JOIN question q ON q.id = a.question_id
    JOIN answer_option ao ON ao.id = a.option_id
    WHERE q.statement = 'Do you consider yourself to be a fan of the Star Wars film franchise?'
), seen_any AS (
    SELECT a.respondent_id, ao.label
    FROM answer a
    JOIN question q ON q.id = a.question_id
    JOIN answer_option ao ON ao.id = a.option_id
    WHERE q.statement = 'Have you seen any of the 6 films in the Star Wars franchise?'
), fan_st AS (
    SELECT a.respondent_id, ao.label
    FROM answer a
    JOIN question q ON q.id = a.question_id
    JOIN answer_option ao ON ao.id = a.option_id
    WHERE q.statement = 'Do you consider yourself to be a fan of the Star Trek franchise?'
)
SELECT 
    CASE WHEN UPPER(f.label) = 'YES' THEN 'Sim' ELSE 'Não' END AS fan_of_star_wars,
    COUNT(*) AS total_respondentes,
    ROUND(
        100.0 * COUNT(*) / NULLIF(SUM(COUNT(*)) OVER (), 0),
        2
    ) AS percentual,
    COUNT(CASE WHEN UPPER(sa.label) = 'YES' THEN 1 END) AS viu_algum_filme,
    COUNT(CASE WHEN UPPER(fs.label) = 'YES' THEN 1 END) AS tambem_fan_startrek
FROM fan_sw f
LEFT JOIN seen_any sa ON sa.respondent_id = f.respondent_id
LEFT JOIN fan_st fs ON fs.respondent_id = f.respondent_id
GROUP BY CASE WHEN UPPER(f.label) = 'YES' THEN 'Sim' ELSE 'Não' END
ORDER BY total_respondentes DESC;
