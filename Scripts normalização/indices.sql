create index idx_age_group_start_end on age_group(age_range_start, age_range_end);
create index idx_household_income_start_end on household_income(income_range_start, income_range_end);

create index idx_respondent_gender on respondent(gender_id);
create index idx_respondent_age_group on respondent(age_group_id);
create index idx_respondent_income on respondent(household_income_id);
create index idx_respondent_education on respondent(education_level_id);
create index idx_respondent_region on respondent(region_id);

create index idx_answer_option_question on answer_option(question_id);

create index idx_answer_option_id on answer(option_id);
create index idx_answer_question_id on answer(question_id);

create index idx_film_seen_respondent on film_seen(respondent_id);
create index idx_film_seen_film on film_seen(film_id);

create index idx_film_ranking_respondent on film_ranking(respondent_id);
create index idx_film_ranking_film on film_ranking(film_id);

create index idx_character_opinion_respondent on character_opinion(respondent_id);
create index idx_character_opinion_character on character_opinion(character_id);
create index idx_character_opinion_option on character_opinion(option_id);
