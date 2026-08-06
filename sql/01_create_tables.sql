-- Dimensão: empresas seguradoras
CREATE TABLE IF NOT EXISTS dim_empresa (
    id_empresa      SERIAL PRIMARY KEY,
    codigo_susep    VARCHAR(5) UNIQUE NOT NULL,
    nome_empresa    VARCHAR(100) NOT NULL
);

-- Fato: prêmios e sinistros mensais de Seguro Auto, por empresa
CREATE TABLE IF NOT EXISTS fato_premios_sinistros_auto (
    id                                      SERIAL PRIMARY KEY,
    id_empresa                              INTEGER NOT NULL REFERENCES dim_empresa(id_empresa),
    competencia                             DATE NOT NULL,
    premio_direto                           NUMERIC(18,2),
    premio_emitido_reg_capitalizacao        NUMERIC(18,2),
    premio_seguros                          NUMERIC(18,2),
    premio_retido                           NUMERIC(18,2),
    premio_emitido                          NUMERIC(18,2),
    premio_ganho                            NUMERIC(18,2),
    despesa_resseguro                       NUMERIC(18,2),
    sinistro_seguros                        NUMERIC(18,2),
    sinistro_retido                         NUMERIC(18,2),
    sinistro_ocorrido                       NUMERIC(18,2),
    receita_resseguro                       NUMERIC(18,2),
    sinistro_ocorridos_cap                  NUMERIC(18,2),
    recuperacao_sinistros_ocorridos_cap     NUMERIC(18,2),
    despesa_comercial                       NUMERIC(18,2),
    sinistralidade                          NUMERIC(6,2),
    rvne                                    NUMERIC(18,2),
    convenio_dpvat                          NUMERIC(18,2),
    consorcios_fundos                       NUMERIC(18,2),
    CONSTRAINT uq_empresa_competencia UNIQUE (id_empresa, competencia)
);

CREATE INDEX IF NOT EXISTS idx_fato_competencia ON fato_premios_sinistros_auto(competencia);
CREATE INDEX IF NOT EXISTS idx_fato_empresa ON fato_premios_sinistros_auto(id_empresa);