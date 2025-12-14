# ⭐ **STAR WARS – Projeto de Banco de Dados 2**

Este projeto tem como objetivo desenvolver um ambiente completo de banco de dados a partir de uma base pública da franquia Star Wars, contendo informações demográficas de entrevistados, preferências de filmes, opiniões sobre personagens e rankings individuais.

O desenvolvimento contemplou todas as etapas da engenharia de dados: análise da base original, normalização, criação de um modelo relacional otimizado, implementação de automatizações no PostgreSQL e construção de um Data Warehouse (DW) para análises multidimensionais.

---

## 📘 **Dicionário de Dados Inicial**

A base original `star_wars` apresentava diversas inconsistências:

* Ausência de chaves primárias e estrangeiras
* Colunas sem nome (Unnamed)
* Mistura de informações demográficas, opiniões e rankings
* Campos agregados de forma inadequada
* Tipos de dados genéricos

O dicionário de dados inicial foi criado para compreender a estrutura original e orientar o processo de normalização.

**Exemplo de colunas da base original:**

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

## 🛠️ **Normalização, Ajustes e Indexação**

A base foi reorganizada para corrigir inconsistências, melhorar a integridade e possibilitar consultas rápidas e confiáveis.

### ✔ **Normalização aplicada**

* Criação de tabelas específicas
* Eliminação de redundâncias
* Definição de chaves primárias e estrangeiras
* Padronização de tipos
* Separação de entidades e relacionamentos

### ✔ **Principais tabelas criadas**

| Tabela            | Descrição                                   |
| ----------------- | ------------------------------------------- |
| respondent        | Dados demográficos dos respondentes         |
| question          | Perguntas da pesquisa                       |
| answer_option     | Opções de resposta para cada pergunta       |
| answer            | Respostas dos respondentes                  |
| film              | Catálogo de filmes                          |
| film_seen         | Filmes assistidos por respondente           |
| film_ranking      | Ranking de filmes por respondente           |
| character         | Catálogo de personagens avaliados           |
| character_opinion | Opiniões dos respondentes sobre personagens |

### ✔ **Indexação**

Exemplos de índices criados para otimização:

* `idx_respondent_gender`, `idx_respondent_age_group`, `idx_respondent_region` – agilizam consultas demográficas
* `idx_film_seen_respondent`, `idx_film_seen_film` – consultas sobre hábitos de visualização
* `idx_film_ranking_respondent`, `idx_film_ranking_film` – análises de rankings individuais e agregados
* `idx_character_opinion_respondent`, `idx_character_opinion_character` – consultas sobre opiniões de personagens

---

## ⚙️ **Automatizações no PostgreSQL**

### 🔹 **Functions**

* `contar_filmes_vistos(p_respondent_id BIGINT)` – total de filmes vistos por respondente
* `obter_ranking_medio_filme(p_film_id INT)` – ranking médio de cada filme
* `eh_fan_star_wars(p_respondent_id BIGINT)` – identifica fãs da franquia

### 🔹 **Procedures**

* `inserir_respondente_com_validacao()` – cadastro seguro de respondentes
* `atualizar_opiniao_personagem_lote()` – atualização massiva de opiniões
* `limpar_respondente()` – exclusão completa de respostas

### 🔹 **Triggers**

* `trg_validar_ranking` – impede rankings inválidos (1–6)
* `trg_validar_answer_option` – valida consistência entre respostas e opções
* `trg_validar_character_opinion` – garante integridade das opiniões sobre personagens

### 🔹 **Views**

* `v_respondentes_por_regiao` – estatísticas de respondentes por região
* `v_ranking_medio_filmes` – ranking médio de filmes
* `v_fans_vs_nao_fans` – comparativo entre fãs e não-fãs

---

## 📊 **Data Warehouse (DW)**

O DW foi modelado dimensionalmente, permitindo análises robustas de comportamento e preferências.

### ✅ **Tabela Fato**

* `Fato_OpiniaoFilmes` – consolida opiniões, rankings e hábitos de consumo de mídia

### ✅ **Dimensões**

* `Dim_Respondente` – gênero, idade, renda, escolaridade, região
* `Dim_Filme` – catálogo de filmes
* `Dim_Personagem` – personagens avaliados

### ✅ **Principais análises suportadas**

* Filmes mais assistidos por faixa etária
* Personagens com maior aprovação
* Relação entre fãs de Star Wars e fãs de Star Trek

### ✅ **Triggers no DW**

* `trigger_fato`, `trigger_filme`, `trigger_respondent`, `trigger_caracter` – atualização automática de fatos e dimensões, garantindo histórico e integridade