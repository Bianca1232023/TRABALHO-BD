create table region (
    id int generated always as identity primary key,
    name varchar(100) not null unique
);

create table gender (
    id int generated always as identity primary key,
    description varchar(50) not null unique
);

create table age_group (
    id int generated always as identity primary key,
    age_range_start int not null,
    age_range_end int not null
);

create table household_income (
    id int generated always as identity primary key,
    income_range_start int not null,
    income_range_end int not null
);

create table education_level (
    id int generated always as identity primary key,
    name varchar(100) not null unique
);



create table respondent (
    id bigint primary key,
    gender_id int references gender(id),
    age_group_id int references age_group(id),
    household_income_id int references household_income(id),
    education_level_id int references education_level(id),
    region_id int references region(id)
);



create table question (
    id bigint generated always as identity primary key,
    statement varchar(255) not null
);

create table answer_option (
    id bigint generated always as identity primary key,
    question_id bigint not null references question(id),
    code varchar(30) not null,
    label varchar(255) not null,
    unique (question_id, code)
);

create table answer (
    respondent_id bigint not null references respondent(id),
    question_id bigint not null references question(id),
    option_id bigint not null references answer_option(id),
    primary key (respondent_id, question_id)
);



create table film (
    id int generated always as identity primary key,
    name varchar(100) not null unique
);

create table film_seen (
    respondent_id bigint not null references respondent(id),
    film_id int not null references film(id),
    primary key (respondent_id, film_id)
);

create table film_ranking (
    respondent_id bigint not null references respondent(id),
    film_id int not null references film(id),
    ranking int not null,
    primary key (respondent_id, film_id)
);



create table character(
    id int generated always as identity primary key,
    name varchar(100) not null unique
);

create table character_opinion (
    respondent_id bigint not null references respondent(id),
    character_id int not null references character(id),
    option_id bigint not null references answer_option(id),
    primary key (respondent_id, character_id)
);
