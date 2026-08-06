-- ============================================================
-- View 1: Série mensal (base para gráficos de linha / Power BI)
-- ============================================================
CREATE OR REPLACE VIEW vw_evolucao_mensal AS
SELECT
    e.nome_empresa,
    f.competencia,
    f.premio_direto,
    f.sinistralidade
FROM fato_premios_sinistros_auto f
JOIN dim_empresa e ON e.id_empresa = f.id_empresa;


-- ============================================================
-- View 2: Ranking anual por Prêmio Direto
-- ============================================================
CREATE OR REPLACE VIEW vw_ranking_anual AS
WITH premio_anual AS (
    SELECT
        e.nome_empresa,
        EXTRACT(YEAR FROM f.competencia)::INT AS ano,
        SUM(f.premio_direto) AS premio_direto_total
    FROM fato_premios_sinistros_auto f
    JOIN dim_empresa e ON e.id_empresa = f.id_empresa
    GROUP BY e.nome_empresa, EXTRACT(YEAR FROM f.competencia)
)
SELECT
    ano,
    nome_empresa,
    premio_direto_total,
    RANK() OVER (PARTITION BY ano ORDER BY premio_direto_total DESC) AS ranking
FROM premio_anual;


-- ============================================================
-- View 3: Market share anual
-- ============================================================
CREATE OR REPLACE VIEW vw_market_share_anual AS
WITH premio_anual AS (
    SELECT
        e.nome_empresa,
        EXTRACT(YEAR FROM f.competencia)::INT AS ano,
        SUM(f.premio_direto) AS premio_direto_total
    FROM fato_premios_sinistros_auto f
    JOIN dim_empresa e ON e.id_empresa = f.id_empresa
    GROUP BY e.nome_empresa, EXTRACT(YEAR FROM f.competencia)
)
SELECT
    ano,
    nome_empresa,
    premio_direto_total,
    ROUND(
        100.0 * premio_direto_total / SUM(premio_direto_total) OVER (PARTITION BY ano),
        2
    ) AS market_share_pct
FROM premio_anual;


-- ============================================================
-- View 4: Crescimento ano a ano (exclui 2026, ano parcial)
-- ============================================================
CREATE OR REPLACE VIEW vw_crescimento_anual AS
WITH premio_anual AS (
    SELECT
        e.nome_empresa,
        EXTRACT(YEAR FROM f.competencia)::INT AS ano,
        SUM(f.premio_direto) AS premio_direto_total
    FROM fato_premios_sinistros_auto f
    JOIN dim_empresa e ON e.id_empresa = f.id_empresa
    GROUP BY e.nome_empresa, EXTRACT(YEAR FROM f.competencia)
)
SELECT
    nome_empresa,
    ano,
    premio_direto_total,
    LAG(premio_direto_total) OVER (PARTITION BY nome_empresa ORDER BY ano) AS premio_ano_anterior,
    ROUND(
        100.0 * (premio_direto_total - LAG(premio_direto_total) OVER (PARTITION BY nome_empresa ORDER BY ano))
        / NULLIF(LAG(premio_direto_total) OVER (PARTITION BY nome_empresa ORDER BY ano), 0),
        2
    ) AS crescimento_pct
FROM premio_anual
WHERE ano < 2026;


-- ============================================================
-- View 5: Sinistralidade média anual
-- ============================================================
CREATE OR REPLACE VIEW vw_sinistralidade_anual AS
SELECT
    e.nome_empresa,
    EXTRACT(YEAR FROM f.competencia)::INT AS ano,
    ROUND(AVG(f.sinistralidade), 2) AS sinistralidade_media_pct
FROM fato_premios_sinistros_auto f
JOIN dim_empresa e ON e.id_empresa = f.id_empresa
WHERE EXTRACT(YEAR FROM f.competencia) < 2026
GROUP BY e.nome_empresa, EXTRACT(YEAR FROM f.competencia);