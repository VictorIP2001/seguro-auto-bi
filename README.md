# Inteligência Competitiva do Mercado Brasileiro de Seguro Auto



> ⚠️ Projeto em desenvolvimento. Este README é atualizado conforme o projeto avança.



## Sobre o projeto



Estudo de caso de Business Intelligence que analisa o mercado brasileiro de Seguro Auto,

utilizando dados públicos da SUSEP, com o objetivo de comparar o desempenho de grandes

seguradoras e responder perguntas estratégicas de negócio.



Este é um projeto de portfólio pessoal, desenvolvido com dados públicos, sem qualquer

vínculo com as empresas analisadas.

**Pergunta central do projeto:** Como está evoluindo a posição competitiva das principais
seguradoras no mercado brasileiro de Seguro Auto — em termos de participação de mercado,
crescimento e sinistralidade — e quais tendências recentes sinalizam oportunidades ou
riscos estratégicos?


## Contexto e problema de negócio



As informações do mercado de Seguro Auto no Brasil estão distribuídas em bases públicas

da SUSEP, o que dificulta análises comparativas e o acompanhamento da evolução das

principais seguradoras ao longo do tempo. Este projeto consolida esses dados em um

ambiente analítico único, permitindo acompanhar indicadores estratégicos do setor.



## Escopo



Análise exclusiva do ramo de **Seguro Auto**, cobrindo as linhas:

- 0531 — Automóvel (Casco)

- 0553 — R.C. Facultativa de Veículos (RCFV)

- 0524 — Garantia Estendida Auto

- 0526 — Seguro Popular de Auto Usado (RUN OFF)

- 0542 — Assistência e Outras Coberturas Auto



**Seguradoras analisadas:** Bradesco Seguros Auto/RE, Porto, Tokio Marine, Allianz e Mapfre.



**Período:** janeiro/2021 a maio/2026 (65 meses). Junho/2026 não está disponível — a

SUSEP publica os dados com uma defasagem de 1–2 meses.



## Fonte dos dados



[SUSEP — Sistema de Estatísticas SES](https://www2.susep.gov.br/menuestatistica/ses/principal.aspx),

consulta "Seguros: Prêmios e Sinistros", filtrada por empresa e pelos ramos de Auto

listados acima, com quebra mensal.



### Como reproduzir os dados brutos



Os arquivos originais não são versionados neste repositório (ver `.gitignore`). Para

reproduzi-los:



1. Acesse a ferramenta SES da SUSEP (link acima)

2. Em "Consultas sobre: Operações" → "Seguros: Prêmios e Sinistros"

3. Para cada seguradora, selecione **apenas o código dela** no filtro Empresa:



&#x20;  | Empresa | Código SUSEP |

&#x20;  |---|---|

&#x20;  | Bradesco Seguros Auto/RE | 05312 |

&#x20;  | Porto | 05886 |

&#x20;  | Tokio Marine | 06190 |

&#x20;  | Allianz | 05177 |

&#x20;  | Mapfre | 06238 |



4. No filtro Ramo, selecione apenas: `0524, 0526, 0531, 0542, 0553`

5. Período: `202101` a `202606` (ou período mais recente disponível)

6. Quebra por mês/competência

7. Exporte e salve em `data/raw/`



> ⚠️ Atenção: ao selecionar múltiplas empresas numa mesma consulta, a SUSEP retorna os

> valores **somados**, sem coluna de origem — não é possível separar depois. Sempre

> consultar uma empresa por vez.



## Arquitetura da solução



Dados públicos SUSEP (SES)

↓

Extração manual (.xls / HTML)

↓

Pipeline Python (pandas) — limpeza, padronização, transformação

↓

PostgreSQL (Docker) — modelo dimensional

↓

Power BI — dashboard executivo [ainda não construído]



## Modelo de dados



Modelo dimensional simples (dimensão + fato):



- **`dim_empresa`** — cadastro das seguradoras analisadas (código SUSEP, nome)

- **`fato_premios_sinistros_auto`** — métricas mensais de prêmios e sinistros de Auto por

&#x20; empresa (prêmio direto, prêmio retido, prêmio ganho, sinistros, sinistralidade, etc.)



Ver DDL completa em [`sql/01_create_tables.sql`](sql/01_create_tables.sql).



Decisões de design:

- `NUMERIC(18,2)` em vez de `FLOAT` para valores financeiros, evitando erro de

&#x20; arredondamento

- Constraint `UNIQUE (id_empresa, competencia)` protegendo contra duplicidade de carga

- Índices em `competencia` e `id_empresa`, colunas mais usadas em filtros/agrupamentos

- DDL idempotente (`CREATE TABLE IF NOT EXISTS`), permitindo reexecução segura



## Tecnologias utilizadas



- **Python** (pandas, SQLAlchemy) — extração, limpeza e carga dos dados

- **PostgreSQL 16** (via Docker) — armazenamento e modelagem

- **Jupyter Notebook** (via VS Code) — desenvolvimento exploratório do pipeline

- **Power BI** — dashboard executivo *(próxima etapa)*

- **Git/GitHub** — versionamento e portfólio



## Etapas do desenvolvimento



- [x] Definição de escopo e validação da disponibilidade dos dados

- [x] Infraestrutura: PostgreSQL via Docker + conexão via DBeaver

- [x] Extração dos dados (SUSEP, filtrados por empresa e ramo de Auto)

- [x] Pipeline de ETL em Python (limpeza, padronização, carga)

- [x] Modelagem de dados e carga no PostgreSQL (325 registros: 5 empresas × 65 meses)

- [ ] Análise Exploratória (EDA) aprofundada

- [x] Consultas SQL analíticas (market share, ranking, evolução temporal, sinistralidade)

- [ ] Dashboard executivo no Power BI

- [ ] Storytelling e insights estratégicos

- [ ] Post de divulgação no LinkedIn



## Principais desafios encontrados



Durante o desenvolvimento, alguns problemas reais de qualidade de dados precisaram ser

identificados e corrigidos:



- A ferramenta de exportação da SUSEP soma os valores quando múltiplas empresas são

&#x20; selecionadas na mesma consulta, sem manter identificação de origem — exigiu reexportar

&#x20; consultas feitas incorretamente

- Os arquivos `.xls` da SUSEP são, na verdade, tabelas HTML com extensão `.xls`,

&#x20; exigindo `pandas.read_html()` em vez de `pandas.read_excel()`

- Valores monetários vêm no formato textual brasileiro (`292.641.308`), exigindo

&#x20; conversão explícita para numérico

- Cada exportação inclui uma linha de "Totais" que precisa ser removida antes de

&#x20; qualquer conversão de tipos

- Um erro na string de conexão do SQLAlchemy usando `localhost` causava travamentos no

&#x20; Windows (resolvido usando `127.0.0.1`)



## Insights estratégicos

*Baseado em análises SQL sobre prêmio direto e sinistralidade, 2021–2025 (2026 excluído
por ser um ano parcial nos dados disponíveis).*

**Porto consolida liderança de forma acelerada.** A participação de mercado da Porto
subiu de ~30% (2021) para ~36% (2025), com um salto expressivo justamente em 2025
(+42% de crescimento no prêmio direto frente a 2024). A empresa também apresentou a
menor sinistralidade do grupo em 2021 (50,6%), sugerindo que o crescimento recente não
veio apenas de agressividade comercial, mas de uma base operacional historicamente
eficiente.

**Mapfre perde participação de forma sustentada, mas mantém disciplina de sinistralidade.**
A Mapfre caiu de ~13% para ~8% de market share entre 2021 e 2025, com crescimento negativo
em dois dos últimos três anos — e permaneceu na 5ª posição do ranking em todos os anos
analisados. Ainda assim, apresentou a menor sinistralidade do grupo em 2024 e 2025,
levantando a hipótese de uma estratégia deliberada de priorizar rentabilidade sobre
volume, em vez de simples perda de competitividade.

**Tokio Marine mudou de patamar competitivo em 2022 e não voltou atrás.** Saiu da 4ª
posição do ranking em 2021 para a 2ª já em 2022 (crescimento de +62% no prêmio direto
naquele ano) e manteve essa posição em todos os anos seguintes — a mudança de
posicionamento mais nítida identificada no período.

**Allianz opera com a maior sinistralidade do setor em todos os anos analisados**
(entre 64% e 84%), o que provavelmente restringe sua capacidade de crescer de forma tão
agressiva quanto Porto ou Tokio Marine, mesmo mantendo uma participação de mercado
relevante (18–21%).



## Aprendizados



*A ser preenchido ao final do projeto.*



## Próximos passos



1. Consultas SQL analíticas (window functions, ranking, market share)

2. Análise exploratória aprofundada

3. Dashboard executivo no Power BI

4. Post de divulgação no LinkedIn

