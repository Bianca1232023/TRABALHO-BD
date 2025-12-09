# ⭐ **STAR WARS – Projeto de Banco de Dados 2**

Este projeto tem como objetivo desenvolver um ambiente completo de banco de dados utilizando uma base pública da franquia **Star Wars**, composta por informações demográficas dos entrevistados, preferências de filmes, opiniões sobre personagens e rankings individuais.

Ao longo do desenvolvimento, foram realizadas etapas essenciais de engenharia de dados, incluindo:

* análise da estrutura original da base;
* criação de um dicionário de dados inicial;
* normalização e reorganização das tabelas;
* construção de índices para otimização de desempenho;
* desenvolvimento de automatizações (triggers, views, functions, procedures);
* implementação de um Data Warehouse utilizando modelagem dimensional.
---

## 📘 **Dicionário de Dados Inicial**

O dicionário inicial foi desenvolvido a partir da tabela original `star_wars`, que continha todas as respostas agregadas em uma única estrutura. Durante a análise exploratória, foram identificados diversos problemas, como:

* ausência de chaves primárias e estrangeiras;
* colunas sem nome (*Unnamed*);
* mistura de informações demográficas, opiniões e rankings;
* campos agregados de forma inadequada;
* tipos de dados pouco específicos ou genéricos.

---

## 🛠️ **Análise da Base, Normalização e Indexação**

A base foi reorganizada para resolver inconsistências, separar corretamente os domínios e possibilitar consultas mais rápidas e confiáveis.

### ✔ Normalização aplicada

Incluiu:

* criação de tabelas específicas (respondentes, filmes, personagens, respostas, rankings etc.);
* eliminação completa de redundâncias;
* definição clara de chaves primárias e estrangeiras;
* padronização de tipos e criação de ENUMs (ex.: faixas etárias);
* separação adequada de entidades e relacionamentos.

### ✔ Principais tabelas resultantes

* **respondentid** — identificador original de cada entrevistado
* **respostas** — características demográficas e respostas gerais
* **film / film_seen / film_ranking** — catálogo e interações com os filmes
* **character_film / character_opinion** — personagens e avaliações

### ✔ Indexação

Foram implementados índices para acelerar consultas, especialmente em:

* `film_seen`
* `film_ranking`
* `character_opinion`

---

## ⚙️ **Automatizações no PostgreSQL**

Para tornar o ambiente mais inteligente, estável e automatizado, foram desenvolvidas as seguintes estruturas:

### 🔹 **Triggers**

* validações automáticas
* auditoria de alterações
* preenchimento automático de campos

### 🔹 **Functions**

* cálculos padronizados
* regras de negócio reutilizáveis

### 🔹 **Views**

* consultas complexas simplificadas
* apoio direto a análises exploratórias

### 🔹 **Procedures**

* rotinas de carga
* limpeza e manutenção
* automação de processos repetitivos

---

## 📊 **Modelagem do Data Warehouse (DW)**

O DW foi projetado utilizando **modelagem dimensional**, seguindo um **Esquema Estrela** adequado para análises de preferências e comportamentos dos entrevistados.

### ❓ Perguntas de negócio atendidas

* Qual filme recebe as melhores avaliações em cada faixa etária?
* Quais personagens possuem os maiores índices de aprovação?
* Como variam as preferências entre diferentes regiões e perfis demográficos?

### 📁 Componentes principais

* **Tabela Fato:** `Fato_OpiniaoFilmes`
* **Dimensões:**

  * `Dim_Filme`
  * `Dim_Respondente`
  * `Dim_Personagem`
