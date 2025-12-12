-- =========================================================
-- ETL COMPLETO (DO ZERO) - STAR WARS TABELONA -> MODELO NORMALIZADO
-- =========================================================
-- Premissas:
-- - tabelona: star_wars
-- - DDL final já criado
-- - objetivo: popular todas as tabelas do modelo normalizado
-- =========================================================


-- =========================================================
-- 1) DOMÍNIOS FIXOS
-- =========================================================

insert into gender (description)
select distinct trim(sw."gender")
from star_wars sw
where sw."gender" is not null
  and trim(sw."gender") <> ''
  and trim(sw."gender") <> 'Response'
on conflict (description) do nothing;

insert into region (name)
select distinct trim(sw."Location (Census Region)")
from star_wars sw
where sw."Location (Census Region)" is not null
  and trim(sw."Location (Census Region)") <> ''
  and trim(sw."Location (Census Region)") <> 'Response'
on conflict (name) do nothing;

insert into education_level (name)
select distinct trim(sw."education")
from star_wars sw
where sw."education" is not null
  and trim(sw."education") <> ''
  and trim(sw."education") <> 'Response'
on conflict (name) do nothing;

insert into age_group (age_range_start, age_range_end)
select v.s, v.e
from (values (18,29),(30,44),(45,60),(61,200)) v(s,e)
where not exists (
    select 1
    from age_group ag
    where ag.age_range_start = v.s
      and ag.age_range_end   = v.e
);

insert into household_income (income_range_start, income_range_end)
select v.s, v.e
from (values
    (0,24999),
    (25000,49999),
    (50000,99999),
    (100000,149999),
    (150000,9999999)
) v(s,e)
where not exists (
    select 1
    from household_income hi
    where hi.income_range_start = v.s
      and hi.income_range_end   = v.e
);


-- =========================================================
-- 2) RESPONDENT
-- =========================================================

insert into respondent (
    id,
    gender_id,
    age_group_id,
    household_income_id,
    education_level_id,
    region_id
)
select distinct
    sw."respondentid"::bigint,
    g.id,
    ag.id,
    hi.id,
    el.id,
    r.id
from star_wars sw
left join gender g
    on trim(sw."gender") = g.description
left join education_level el
    on trim(sw."education") = el.name
left join region r
    on trim(sw."Location (Census Region)") = r.name
left join age_group ag
    on (
        (trim(sw.age) = '18-29' and ag.age_range_start = 18) or
        (trim(sw.age) = '30-44' and ag.age_range_start = 30) or
        (trim(sw.age) = '45-60' and ag.age_range_start = 45) or
        (trim(sw.age) in ('> 60','>60') and ag.age_range_start = 61)
    )
left join household_income hi
    on (
        (sw."Household Income" like '%25,000%' and hi.income_range_start = 0) or
        (sw."Household Income" like '%49,999%' and hi.income_range_start = 25000) or
        (sw."Household Income" like '%99,999%' and hi.income_range_start = 50000) or
        (sw."Household Income" like '%149,999%' and hi.income_range_start = 100000) or
        (sw."Household Income" like '%150,000%' and hi.income_range_start = 150000)
    )
where sw."respondentid" is not null
on conflict (id) do nothing;


-- =========================================================
-- 3) FILM (lista de filmes a partir das colunas de seleção)
-- =========================================================

insert into film (name)
select distinct film_name
from (
    select sw."Which of the following Star Wars films have you seen? Please se" as film_name from star_wars sw
    union all select sw."Unnamed: 4" from star_wars sw
    union all select sw."Unnamed: 5" from star_wars sw
    union all select sw."Unnamed: 6" from star_wars sw
    union all select sw."Unnamed: 7" from star_wars sw
    union all select sw."Unnamed: 8" from star_wars sw
) f
where film_name is not null
  and trim(film_name) <> ''
on conflict (name) do nothing;


-- =========================================================
-- 4) FILM_SEEN (existência da linha = viu)
-- =========================================================

insert into film_seen (respondent_id, film_id)
select distinct
    r.id,
    f.id
from star_wars sw
join respondent r
    on r.id = sw."respondentid"::bigint
join film f
    on f.name in (
        sw."Which of the following Star Wars films have you seen? Please se",
        sw."Unnamed: 4",
        sw."Unnamed: 5",
        sw."Unnamed: 6",
        sw."Unnamed: 7",
        sw."Unnamed: 8"
    )
on conflict do nothing;


-- =========================================================
-- 5) FILM_RANKING
-- =========================================================

insert into film_ranking (respondent_id, film_id, ranking)
select
    r.id,
    f.id,
    case f.name
        when sw."Which of the following Star Wars films have you seen? Please se"
            then nullif(trim(sw."Please rank the Star Wars films in order of preference with 1 b"), '')::int
        when sw."Unnamed: 4" then nullif(trim(sw."Unnamed: 10"), '')::int
        when sw."Unnamed: 5" then nullif(trim(sw."Unnamed: 11"), '')::int
        when sw."Unnamed: 6" then nullif(trim(sw."Unnamed: 12"), '')::int
        when sw."Unnamed: 7" then nullif(trim(sw."Unnamed: 13"), '')::int
        when sw."Unnamed: 8" then nullif(trim(sw."Unnamed: 14"), '')::int
    end
from star_wars sw
join respondent r
    on r.id = sw."respondentid"::bigint
join film f
    on f.name in (
        sw."Which of the following Star Wars films have you seen? Please se",
        sw."Unnamed: 4",
        sw."Unnamed: 5",
        sw."Unnamed: 6",
        sw."Unnamed: 7",
        sw."Unnamed: 8"
    )
where
    case f.name
        when sw."Which of the following Star Wars films have you seen? Please se"
            then nullif(trim(sw."Please rank the Star Wars films in order of preference with 1 b"), '')
        when sw."Unnamed: 4" then nullif(trim(sw."Unnamed: 10"), '')
        when sw."Unnamed: 5" then nullif(trim(sw."Unnamed: 11"), '')
        when sw."Unnamed: 6" then nullif(trim(sw."Unnamed: 12"), '')
        when sw."Unnamed: 7" then nullif(trim(sw."Unnamed: 13"), '')
        when sw."Unnamed: 8" then nullif(trim(sw."Unnamed: 14"), '')
    end is not null
on conflict do nothing;


-- =========================================================
-- 6) CHARACTER (lista fixa)
-- =========================================================

insert into character (name) values
('Han Solo'),
('Luke Skywalker'),
('Princess Leia Organa'),
('Anakin Skywalker'),
('Obi Wan Kenobi'),
('Emperor Palpatine'),
('Darth Vader'),
('Lando Calrissian'),
('Boba Fett'),
('C-3PO'),
('R2 D2'),
('Jar Jar Binks'),
('Padme Amidala'),
('Yoda')
on conflict (name) do nothing;


-- =========================================================
-- 7) QUESTIONS (EAV)
-- =========================================================

insert into question (statement)
select q
from (values
    ('Have you seen any of the 6 films in the Star Wars franchise?'),
    ('Do you consider yourself to be a fan of the Star Wars film franchise?'),
    ('Do you consider yourself to be a fan of the Star Trek franchise?'),
    ('Do you consider yourself to be a fan of the Expanded Universe?'),
    ('Are you familiar with the Expanded Universe?'),
    ('Which character shot first?'),
    ('Character opinion')
) v(q)
where not exists (
    select 1 from question qq where qq.statement = v.q
);


-- =========================================================
-- 8) ANSWER_OPTION (EAV)
-- =========================================================

-- YES / NO
insert into answer_option (question_id, code, label)
select q.id, o.code, o.label
from question q
cross join (values ('Y','Yes'),('N','No')) o(code,label)
where q.statement in (
    'Have you seen any of the 6 films in the Star Wars franchise?',
    'Do you consider yourself to be a fan of the Star Wars film franchise?',
    'Do you consider yourself to be a fan of the Star Trek franchise?',
    'Do you consider yourself to be a fan of the Expanded Universe?',
    'Are you familiar with the Expanded Universe?'
)
on conflict (question_id, code) do nothing;

-- WHO SHOT FIRST
insert into answer_option (question_id, code, label)
select q.id, o.code, o.label
from question q
cross join (values
    ('HAN','Han'),
    ('GREEDO','Greedo'),
    ('UNK','I don''t understand this question')
) o(code,label)
where q.statement = 'Which character shot first?'
on conflict (question_id, code) do nothing;

-- CHARACTER OPINION (labels exatamente como aparecem no teu print)
insert into answer_option (question_id, code, label)
select q.id, o.code, o.label
from question q
cross join (values
    ('VF','Very favorably'),
    ('SF','Somewhat favorably'),
    ('N','Neither favorably nor unfavorably (neutral)'),
    ('SU','Somewhat unfavorably'),
    ('VU','Very unfavorably'),
    ('NA','Unfamiliar (N/A)')
) o(code,label)
where q.statement = 'Character opinion'
on conflict (question_id, code) do nothing;


-- =========================================================
-- 9) ANSWER (EAV) - MIGRAR TODAS AS PERGUNTAS DO CSV
-- =========================================================

-- Have you seen any...
insert into answer (respondent_id, question_id, option_id)
select r.id, q.id, ao.id
from star_wars sw
join respondent r on r.id = sw."respondentid"::bigint
join question q on q.statement = 'Have you seen any of the 6 films in the Star Wars franchise?'
join answer_option ao on ao.question_id = q.id
                     and ao.label = trim(sw."Have you seen any of the 6 films in the Star Wars franchise?")
where sw."Have you seen any of the 6 films in the Star Wars franchise?" is not null
  and trim(sw."Have you seen any of the 6 films in the Star Wars franchise?") <> ''
  and trim(sw."Have you seen any of the 6 films in the Star Wars franchise?") <> 'Response'
on conflict do nothing;

-- Fan of Star Wars
insert into answer (respondent_id, question_id, option_id)
select r.id, q.id, ao.id
from star_wars sw
join respondent r on r.id = sw."respondentid"::bigint
join question q on q.statement = 'Do you consider yourself to be a fan of the Star Wars film franchise?'
join answer_option ao on ao.question_id = q.id
                     and ao.label = trim(sw."Do you consider yourself to be a fan of the Star Wars film fran")
where sw."Do you consider yourself to be a fan of the Star Wars film fran" is not null
  and trim(sw."Do you consider yourself to be a fan of the Star Wars film fran") <> ''
  and trim(sw."Do you consider yourself to be a fan of the Star Wars film fran") <> 'Response'
on conflict do nothing;

-- Fan of Star Trek
insert into answer (respondent_id, question_id, option_id)
select r.id, q.id, ao.id
from star_wars sw
join respondent r on r.id = sw."respondentid"::bigint
join question q on q.statement = 'Do you consider yourself to be a fan of the Star Trek franchise?'
join answer_option ao on ao.question_id = q.id
                     and ao.label = trim(sw."Do you consider yourself to be a fan of the Star Trek franchise")
where sw."Do you consider yourself to be a fan of the Star Trek franchise" is not null
  and trim(sw."Do you consider yourself to be a fan of the Star Trek franchise") <> ''
  and trim(sw."Do you consider yourself to be a fan of the Star Trek franchise") <> 'Response'
on conflict do nothing;

-- Fan of Expanded Universe
insert into answer (respondent_id, question_id, option_id)
select r.id, q.id, ao.id
from star_wars sw
join respondent r on r.id = sw."respondentid"::bigint
join question q on q.statement = 'Do you consider yourself to be a fan of the Expanded Universe?'
join answer_option ao on ao.question_id = q.id
                     and ao.label = trim(sw."Do you consider yourself to be a fan of the Expanded Universe?")
where sw."Do you consider yourself to be a fan of the Expanded Universe?" is not null
  and trim(sw."Do you consider yourself to be a fan of the Expanded Universe?") <> ''
  and trim(sw."Do you consider yourself to be a fan of the Expanded Universe?") <> 'Response'
on conflict do nothing;

-- Familiar with Expanded Universe
insert into answer (respondent_id, question_id, option_id)
select r.id, q.id, ao.id
from star_wars sw
join respondent r on r.id = sw."respondentid"::bigint
join question q on q.statement = 'Are you familiar with the Expanded Universe?'
join answer_option ao on ao.question_id = q.id
                     and ao.label = trim(sw."Are you familiar with the Expanded Universe?")
where sw."Are you familiar with the Expanded Universe?" is not null
  and trim(sw."Are you familiar with the Expanded Universe?") <> ''
  and trim(sw."Are you familiar with the Expanded Universe?") <> 'Response'
on conflict do nothing;

-- Who shot first
insert into answer (respondent_id, question_id, option_id)
select r.id, q.id, ao.id
from star_wars sw
join respondent r on r.id = sw."respondentid"::bigint
join question q on q.statement = 'Which character shot first?'
join answer_option ao on ao.question_id = q.id
                     and ao.label = trim(sw."Which character shot first?")
where sw."Which character shot first?" is not null
  and trim(sw."Which character shot first?") <> ''
  and trim(sw."Which character shot first?") <> 'Response'
on conflict do nothing;


-- =========================================================
-- 10) CHARACTER_OPINION (CORREÇÃO DEFINITIVA)
-- =========================================================
-- O dataset é sujo: nas colunas de "opinião" aparecem também nomes de personagens.
-- Este insert só insere quando a célula casar com UMA OPÇÃO VÁLIDA (answer_option),
-- ou seja: se for nome de personagem, não casa e não entra.

with q as (
    select q.id
    from question q
    join answer_option ao on ao.question_id = q.id
    where q.statement = 'Character opinion'
    group by q.id
    order by q.id
    limit 1
)
insert into character_opinion (respondent_id, character_id, option_id)
select
    r.id,
    c.id,
    ao.id
from star_wars sw
join respondent r
    on r.id = sw."respondentid"::bigint
cross join q
join lateral (
    values
        ('Han Solo', sw."Please state whether you view the following characters favorabl"),
        ('Luke Skywalker', sw."Unnamed: 16"),
        ('Princess Leia Organa', sw."Unnamed: 17"),
        ('Anakin Skywalker', sw."Unnamed: 18"),
        ('Obi Wan Kenobi', sw."Unnamed: 19"),
        ('Emperor Palpatine', sw."Unnamed: 20"),
        ('Darth Vader', sw."Unnamed: 21"),
        ('Lando Calrissian', sw."Unnamed: 22"),
        ('Boba Fett', sw."Unnamed: 23"),
        ('C-3PO', sw."Unnamed: 24"),
        ('R2 D2', sw."Unnamed: 25"),
        ('Jar Jar Binks', sw."Unnamed: 26"),
        ('Padme Amidala', sw."Unnamed: 27"),
        ('Yoda', sw."Unnamed: 28")
) v(character_name, opinion_label) on true
join character c
    on lower(c.name) = lower(v.character_name)
join answer_option ao
    on ao.question_id = q.id
   and lower(ao.label) = lower(trim(v.opinion_label))
where v.opinion_label is not null
  and trim(v.opinion_label) <> ''
  and trim(v.opinion_label) <> 'Response'
on conflict do nothing;
