DROP TABLE IF EXISTS NETFLIX;

CREATE TABLE NETFLIX
(
    show_id      VARCHAR(7),
    type         VARCHAR(10),  -- USE MAX(LEN(C2:C8088)) TO FIND MAX LENGTH
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);

SELECT * FROM NETFLIX

SELECT COUNT(*) AS TOTAL_CONTENT
FROM NETFLIX


-- 15 Business Problems & Solutions

-- 1. Count the number of Movies vs TV Shows

SELECT TYPE, count(*)
from NETFLIX
GROUP BY TYPE

-- 2. Find the most common rating for movies and TV shows
SELECT type, rating, count
from
(
	SELECT type, rating, count(*), RANK() OVER(PARTITION BY type ORDER BY count(*) DESC) as ranking
	from NETFLIX
	GROUP BY type, rating
) as T1
WHERE ranking = 1

-- 3. List all movies released in a specific year (e.g., 2020)

SELECT *
FROM NETFLIX 
WHERE type = 'Movie' AND release_year=2020

-- 4. Find the top 5 countries with the most content on Netflix

SELECT TRIM(country_name) AS new_country, COUNT(show_id) AS total_content
FROM (
	SELECT show_id, UNNEST(STRING_TO_ARRAY(country, ',')) AS country_name
	FROM NETFLIX) AS T4
GROUP BY new_country
ORDER BY total_content DESC
LIMIT 5

-- 5. Identify the longest movie

select title,  substring(duration, 1,position ('m' in duration)-1)::int duration
from Netflix
where type = 'Movie' and duration is not null
order by 2 desc
limit 1

-- 6. Find content added in the last 5 years

SELECT title, date_added
FROM NETFLIX 
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years'

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT title, director
FROM NETFLIX
WHERE director ILIKE '%Rajiv Chilaka%' -- ILIKE makes it case insensitive

-- 8. List all TV shows with more than 5 seasons

SELECT type, title, SUBSTRING(duration, 1, POSITION('S' IN duration) - 1)::int AS seasons
FROM NETFLIX
WHERE type = 'TV Show' AND SUBSTRING(duration, 1, POSITION('S' IN duration) - 1)::int > 5
order by seasons desc

-- 9. Count the number of content items in each genre

SELECT TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) AS genre, COUNT(*)
FROM NETFLIX
GROUP BY genre

-- 10.Find each year and the average numbers of content release in India on netflix, return top 5 year with highest avg content release!

SELECT EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS added_year, COUNT(*) AS yearly_content
FROM netflix
WHERE country ILIKE '%INDIA%' AND date_added IS NOT NULL
GROUP BY EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY'))
ORDER BY added_year;

-- 11. List all movies that are documentaries

Select title, listed_in
FROM NETFLIX
WHERE type = 'Movie' AND listed_in ILIKE '%DOCUMENT%'

-- 12. Find all content without a director

SELECT * FROM netflix
WHERE director IS NULL

-- 13. Find how many movies actor 'Salman Khan' appeared in last 25 years!

SELECT * FROM netflix
WHERE casts ILIKE '%Salman Khan%' AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 25

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

SELECT TRIM(UNNEST(STRING_TO_ARRAY(casts, ','))) as actor, COUNT(*)
FROM NETFLIX
WHERE country = 'India'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10


-- 15.
-- Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
-- the description field. Label content containing these keywords as 'Bad' and all other 
-- content as 'Good'. Count how many items fall into each category.

WITH new_table AS (
	    SELECT *,
	        CASE 
	            WHEN description ILIKE '%kill%' OR description ILIKE '%violen%' THEN 'Bad'
	            ELSE 'Good'
	        END AS category
	    FROM netflix
)

SELECT category, count(*) as total_content
FROM new_table
GROUP BY category

	














