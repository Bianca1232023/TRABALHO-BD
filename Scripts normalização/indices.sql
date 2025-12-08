--indice da tabela filme
CREATE UNIQUE INDEX idx_film_filmid ON film(filmID);
CREATE INDEX idx_film_film_name ON film(film_name);

--indice da tabela RespondentID
CREATE UNIQUE INDEX idx_respondentid_pk ON RespondentID(respondent_id);

--indice da tabela respostas
CREATE UNIQUE INDEX idx_respostas_id ON respostas(id);
CREATE INDEX idx_respostas_respondent_id ON respostas(respondent_id);
CREATE INDEX idx_respostas_age ON respostas(age);
CREATE INDEX idx_respostas_gender ON respostas(gender);
CREATE INDEX idx_respostas_region ON respostas(region);

--indice da tabela filme_seeen
CREATE UNIQUE INDEX idx_film_seen_id ON film_seen(film_seen_id);
CREATE INDEX idx_film_seen_respondent_id ON film_seen(respondent_id);
CREATE INDEX idx_film_seen_film_id ON film_seen(film_id);
CREATE INDEX idx_film_seen_respondent_film ON film_seen(respondent_id, film_id);

--indice da tabela film_ranking
CREATE UNIQUE INDEX idx_film_ranking_id ON film_ranking(film_ranking_id);
CREATE INDEX idx_film_ranking_respondent_id ON film_ranking(respondent_id);
CREATE INDEX idx_film_ranking_film_id ON film_ranking(film_id);
CREATE INDEX idx_film_ranking_respondent_film ON film_ranking(respondent_id, film_id);

--indice da tabela character_film
CREATE UNIQUE INDEX idx_character_film_id ON character_film(character_id);
CREATE INDEX idx_character_film_name ON character_film(character_name);

--indice da tabela character_opnion
CREATE UNIQUE INDEX idx_character_opinion_id ON character_opinion(character_opinion_id);
CREATE INDEX idx_character_opinion_respondent_id ON character_opinion(respondent_id);
CREATE INDEX idx_character_opinion_character_id ON character_opinion(character_id);
CREATE INDEX idx_character_opinion_resp_char ON character_opinion(respondent_id, character_id);
