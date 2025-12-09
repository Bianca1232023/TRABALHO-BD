-- VIEW 1: Resumo de respondentes por região
CREATE OR REPLACE VIEW v_respondentes_por_regiao AS
SELECT 
    region,
    COUNT(DISTINCT respondent_id) as total_respondentes,
    COUNT(*) as total_respostas,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) as percentual
FROM respostas
WHERE region IS NOT NULL
GROUP BY region
ORDER BY total_respostas DESC;


-- VIEW 2: Ranking médio dos filmes
CREATE OR REPLACE VIEW v_ranking_medio_filmes AS
SELECT 
    f.filmID,
    f.film_name,
    COUNT(fr.ranking) as total_rankings,
    ROUND(AVG(fr.ranking::NUMERIC), 2) as ranking_medio,
    MIN(fr.ranking) as melhor_ranking,
    MAX(fr.ranking) as pior_ranking
FROM film f
LEFT JOIN film_ranking fr ON f.filmID = fr.film_id
GROUP BY f.filmID, f.film_name
ORDER BY ranking_medio ASC;


-- VIEW 3: Análise de fans x não-fans
CREATE OR REPLACE VIEW v_fans_vs_nao_fans AS
SELECT 
    fan_of_star_wars,
    COUNT(DISTINCT respondent_id) as total_respondentes,
    COUNT(*) as total_respostas,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) as percentual,
    COUNT(CASE WHEN seen_any_star_wars = 'Yes' THEN 1 END) as viu_algum_filme,
    COUNT(CASE WHEN fan_of_startrek = 'Yes' THEN 1 END) as tambem_fan_startrek
FROM respostas
WHERE fan_of_star_wars IS NOT NULL
GROUP BY fan_of_star_wars
ORDER BY total_respostas DESC;
