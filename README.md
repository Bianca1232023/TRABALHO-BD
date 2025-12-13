# ⭐ **STAR WARS – Projeto de Banco de Dados 2**

Este projeto tem como objetivo construir um ambiente completo de banco de dados utilizando uma base pública da franquia Star Wars, contendo informações demográficas dos entrevistados, preferências de filmes, opiniões sobre personagens e rankings individuais.

O desenvolvimento envolveu todas as etapas da engenharia de dados, desde a análise da base original até a criação de um Data Warehouse (DW) para análises multidimensionais.

---

## 📘 **Dicionário de Dados Inicial**

A base original star_wars apresentava diversos problemas:

* Ausência de chaves primárias e estrangeiras
* Colunas sem nome (Unnamed)
* Mistura de informações demográficas, opiniões e rankings
* Campos agregados de forma inadequada;
* Tipos de dados genéricos

O dicionário de dados inicial foi criado para compreender a estrutura original e orientar a normalização*.

**Exemplo de algumas colunas originais:**

| Coluna                                     | Tipo    | Descrição                                   | Observações                                 |
| ------------------------------------------ | ------- | ------------------------------------------- | ------------------------------------------- |
| RespondentID                               | float   | Identificador do respondente                | Não era chave primária                      |
| Have you seen any of the 6 films...?       | varchar | Indica se o participante já viu algum filme | Renomeada na normalização                   |
| Which of the following Star Wars films...? | varchar | Filmes assistidos                           | Distribuídos em múltiplas colunas (Unnamed) |
| Please rank the Star Wars films...         | varchar | Ranking de filmes                           | Distribuído em várias colunas               |
| Character opinions                         | varchar | Avaliação de personagens                    | Distribuída em várias colunas Unnamed:16–28 |
| Gender                                     | varchar | Gênero do participante                      | “Male”, “Female”                            |
| Age                                        | varchar | Faixa etária                                | “18–29”, “30–44”, “45–60”                   |
| Household Income                           | varchar | Faixa de renda                              | Ex.: “$0–24,999”                            |
| Education                                  | varchar | Escolaridade                                | Ex.: “High school degree”                   |
| Location                                   | varchar | Região censitária                           | Ex.: “South Atlantic”                       |

---

## 🛠️ **Análise da Base, Normalização e Indexação**

A base foi reorganizada para corrigir inconsistências e possibilitar consultas rápidas e confiáveis.

### ✔ **Normalização aplicada**

* Criação de tabelas específicas
* Eliminação de redundâncias
* Definição de chaves primárias e estrangeiras
* Padronização de tipos
* Separação de entidades e relacionamentos.

### ✔ **Principais tabelas criadas**

| Tabela            | Descrição                                   |
| ----------------- | ------------------------------------------- |
| respondentid      | Identificador original do respondente       |
| respostas         | respostas gerais       |
| film              | Catálogo de filmes                          |
| film_seen         | Filmes assistidos por cada respondente      |
| film_ranking      | Ranking de filmes dado por cada respondente |
| character_film    | Catálogo de personagens avaliados           |
| character_opinion | Avaliações de personagens por respondente   |

### ✔ **Indexação**

Foram criados índices para otimizar consultas, alguns exemplos:

* `film_seen`
* `film_ranking`
* `character_opinion`

---

## ⚙️ **Automatizações no PostgreSQL**

### 🔹 **Triggers**

* Validações automáticas (`trigger_validar_ranking`, `trigger_validar_opinion_nao_vazia`)
* Auditoria de alterações (`trigger_caracter`, `trigger_respondent`)
* Atualização de contadores (`trigger_contar_filme_visto`)

### 🔹 **Functions**

* `contar_filmes_vistos()` – total de filmes vistos por respondente
* `obter_ranking_medio_filme()` – ranking médio de filmes
* `eh_fan_star_wars()` – identifica fãs da franquia

### 🔹 **Views**

* `v_respondentes_por_regiao` – estatísticas por região
* `v_ranking_medio_filmes` – ranking médio de filmes
* `v_fans_vs_nao_fans` – comparativo entre fãs e não-fãs

### 🔹 **Procedures**

* `inserir_respondente_com_validacao()` – cadastro seguro de respondentes
* `atualizar_opiniao_personagem_lote()` – atualização massiva de opiniões
* `limpar_respondente()` – exclusão completa de respostas 

---

## 📊 **Modelagem do Data Warehouse (DW)**

O DW utiliza modelagem dimensional permitindo análises de comportamento e preferências.

### ✅ **Tabela Fato**

* `Fato_OpiniaoFilmes` – consolida opiniões, rankings e hábitos de consumo de mídia.

### ✅ **Dimensões**

* `Dim_Respondente` – gênero, faixa etária, renda, escolaridade, região
* `Dim_Filme` – catálogo de filmes
* `Dim_Personagem` – personagens avaliados.

### ✅ **Perguntas de negócio atendidas**

* Quais filmes são mais assistidos por faixa etária?
* Quais personagens têm maior aprovação?
* Quantos fãs de Star Wars também são fãs de Star Trek?

### ✅ **Triggers no DW**

* `trigger_fato`, `trigger_filme`, `trigger_respondent`, `trigger_caracter` – garantem atualização automática de dimensões e fatos, mantendo histórico e integridade.
