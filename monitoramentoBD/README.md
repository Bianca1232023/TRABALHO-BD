# Monitoramento do Banco de Dados - Bônus 2
O objetivo deste bônus é implementar o **monitoramento de performance** do banco de dados utilizando o **pgBadger**. Foram geradas consultas mal otimizadas para observar o impacto na performance e, em seguida, consultas otimizadas para demonstrar melhoria.

---

## Ferramentas

* **PostgreSQL 17**
* **pgBadger** 

---

## Configuração do PostgreSQL para monitoramento

No banco star_wars, foram aplicadas as seguintes configurações:

```sql
ALTER SYSTEM SET log_statement = 'all';
ALTER SYSTEM SET log_duration = off;
ALTER SYSTEM SET log_min_duration_statement = 0;
ALTER SYSTEM SET log_error_verbosity = default;
ALTER SYSTEM SET log_line_prefix = '%m [%p] %u@%d ';
SELECT pg_reload_conf();
```

Essas alterações garantem que todas as consultas SQL sejam registradas nos logs, permitindo análise detalhada pelo pgBadger.

---

## Geração de relatórios com pgBadger

Com os logs gerados, utilizamos o comando no ubuntun:

```bash
pgbadger -f csv postgresql-2025-12-13_*.csv.csv -o /mnt/c/pgbadger/pgbadger-star-wars.html
```

Isso produziu um **dashboard HTML** contendo estatísticas de queries, duração, eventos e conexões.

---

## Comparação de queries

### Query mal otimizada

A query abaixo é **mal otimizada**, pois faz um join completo entre todas as tabelas e seleciona todas as colunas, retornando muitos dados desnecessários:

```sql
SELECT *
FROM respostas r
JOIN film_seen fs ON fs.respondent_id = r.id
JOIN film_ranking fr ON fr.respondent_id = r.id
JOIN character_opinion co ON co.respondent_id = r.id;
```
---

### Query Otimizada

A query otimizada seleciona apenas as colunas relevantes e mantém os joins necessários, utilizando índices já criados:

```sql
SELECT r.id, r.gender, r.age, fs.film_id, fr.ranking
FROM respostas r
JOIN film_seen fs ON fs.respondent_id = r.id
JOIN film_ranking fr ON fr.respondent_id = r.id;
```
---
**Impacto observado no pgBadger:**

* Apesar da duração total ser levemente maior, o que importa é a latência média das queries e o tempo que a maioria das queries demora.
* No cenário otimizado, o **AVG duration caiu de 123ms → 103ms**, e o **Latency Percentil 90% caiu de 255ms → 206ms**, mostrando que a maioria das queries foi acelerada.
---

## Conclusão

* O **pgBadger** permitiu identificar queries mal otimizadas e medir o impacto da otimização.
* Queries otimizadas reduziram a quantidade de dados desnecessários processados e aproveitaram índices existentes.
* Esse monitoramento é essencial para manter o banco de dados eficiente, especialmente em ambientes com grande volume de consultas.