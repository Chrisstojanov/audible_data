create database Portfolio_projects;

create table Audible(
	title varchar(250),
	author varchar(250),
	narrator varchar(250),
	time varchar(100),
	releasedate DATE,
	language varchar(50),
	stars varchar(100),
	price integer
);


copy audible
from 'C:\Users\chris\Downloads\audible.csv'
with (format csv, header);


--REMOVE "Writtenby:" from Author Column; 

alter table audible add column new_author varchar(250)

UPDATE Audible
SET new_author = substring(author, 11)
where author like 'Writtenby:%'

--Remove "Narratedby:" from Narrator column;

alter table audible add column new_narrator varchar(250)

UPDATE Audible
SET new_narrator = substring(narrator, 12)
where narrator like 'Narratedby%'


--Change price from Indian Rupees to USD
UPDATE audible
SET price = price / 82.665946;  (current exchange rate 1/5/2023)


--Change time from hours and min to minutes
alter table audible
add column minutes varchar
alter table audible
add column hours VARCHAR

UPDATE audible
SET hours = split_part(time, 'and', 1)
    minutes = split_part(time, 'and', 2);
--Remove 'min' string from hours column
alter table audible
add column minutes2

UPDATE audible
SET minutes2 = hours
WHERE hours LIKE '%m%';

UPDATE audible 
SET hours = NULL 
WHERE hours LIKE '%mins%';


	
----truncate last 5 characters of minutes2, and minutes COLUMN
UPDATE audible
SET minutes = left(minutes, length(minutes) - 5);

----truncate last 4 characters of hours column
UPDATE audible
SET hours = left(hours, length(hours) - 4);

----truncate last 4 characters of minutes2 column
UPDATE audible
SET minutes2 = left(hours, length(hours) - 4);

--Create new column "Length"
Query to change hours to min (hours*min) and add to data in minutes column and put into new column called "Length"
Have to change datatypes in hours and minutes first



--change min data from hours column to 0
UPDATE audible SET hours = replace(hours,'min','0') WHERE hours LIKE '%min%';

--Changing datatypes 
ALTER TABLE temptable ALTER COLUMN totalratings TYPE numeric using rating::numeric;

ALTER TABLE temptable ALTER COLUMN rating TYPE double precision USING rating::double precision;

ALTER TABLE temptable ALTER COLUMN hours TYPE numeric using hours::numeric;

alter table temptable alter column minutes type numeric using minutes::numeric;


--Splitting Stars column with delimiter 'stars'
ALTER TABLE audible
  ADD COLUMN Rating VARCHAR(255),
ADD COLUMN TotalRatings VARCHAR(255)

UPDATE audible
SET rating = split_part(stars, 'stars', 1),
    totalratings = split_part(stars, 'stars', 2);
	
--Cleaning totalratings to just integer

update audible
set totalratings = split_part(totalratings, 'rating', 1)


UPDATE audible 
SET totalratings = 0 WHERE totalratings = '';

--Cleaning rating to just integer

UPDATE audible 
SET rating = '' WHERE rating = 'Not rated yet';

UPDATE audible 
SET rating = replace(rating, ' out of 5', '');


--Remove all data with no totalratings
DELETE FROM audible WHERE totalratings = '0';

--Remove all languages except english
DELETE FROM audible WHERE language NOT LIKE 'English';


--Clean dataset to remove multiple entries 
--Create serial COLUMN
Alter table audible1 add column id serial primary key

WITH cte AS (
  SELECT MIN(id) as id, title, time, releasedate, language, price, author, narrator, rating, totalratings, length
  FROM audible1
  GROUP BY title, time, releasedate, language, price, author, narrator, rating, totalratings, length
  HAVING COUNT(*) > 1
)
DELETE FROM audible1
WHERE (title, time, releasedate, language, price, author, narrator, rating, totalratings, length) IN (
  SELECT title, time, releasedate, language, price, author, narrator, rating, totalratings, length
  FROM cte
) AND id NOT IN (
  SELECT id
  FROM cte
);

