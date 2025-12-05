-- public.star_wars definição

-- Drop table

-- DROP TABLE public.star_wars;

CREATE TABLE public.star_wars (
	"RespondentID" float4 NULL,
	"Have you seen any of the 6 films in the Star Wars franchise?" varchar(50) NULL,
	"Do you consider yourself to be a fan of the Star Wars film fran" varchar(50) NULL,
	"Which of the following Star Wars films have you seen? Please se" varchar(50) NULL,
	"Unnamed: 4" varchar(50) NULL,
	"Unnamed: 5" varchar(50) NULL,
	"Unnamed: 6" varchar(50) NULL,
	"Unnamed: 7" varchar(50) NULL,
	"Unnamed: 8" varchar(50) NULL,
	"Please rank the Star Wars films in order of preference with 1 b" varchar(50) NULL,
	"Unnamed: 10" varchar(50) NULL,
	"Unnamed: 11" varchar(50) NULL,
	"Unnamed: 12" varchar(50) NULL,
	"Unnamed: 13" varchar(50) NULL,
	"Unnamed: 14" varchar(50) NULL,
	"""Please state whether you view the following characters favorab" varchar(50) NULL,
	" unfavorably" varchar(50) NULL,
	" or are unfamiliar with him/her.""" varchar(50) NULL,
	"Unnamed: 16" varchar(50) NULL,
	"Unnamed: 17" varchar(50) NULL,
	"Unnamed: 18" varchar(50) NULL,
	"Unnamed: 19" varchar(50) NULL,
	"Unnamed: 20" varchar(50) NULL,
	"Unnamed: 21" varchar(50) NULL,
	"Unnamed: 22" varchar(50) NULL,
	"Unnamed: 23" varchar(50) NULL,
	"Unnamed: 24" varchar(50) NULL,
	"Unnamed: 25" varchar(50) NULL,
	"Unnamed: 26" varchar(50) NULL,
	"Unnamed: 27" varchar(50) NULL,
	"Unnamed: 28" varchar(50) NULL,
	"Which character shot first?" varchar(50) NULL,
	"Are you familiar with the Expanded Universe?" varchar(50) NULL,
	"Do you consider yourself to be a fan of the Expanded Universe?" varchar(50) NULL,
	"Do you consider yourself to be a fan of the Star Trek franchise" varchar(50) NULL,
	"Gender" varchar(50) NULL,
	"Age" varchar(50) NULL,
	"Household Income" varchar(50) NULL,
	"Education" varchar(50) NULL,
	"Location (Census Region)" varchar(50) NULL
);

--insert into oi
-- select 
--  sw."RespondentID"::bigint
-- 	from star_wars sw 
	
	
-- select * from oi 
-- where test is not null

--insert into oi
-- select RespondentID::BigInt from star_wars