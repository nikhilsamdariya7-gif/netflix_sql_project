-- Netflix Data Analysis using SQL
-- Solutions of 15 business problems

-- 1. Count the number of Movies vs TV Shows 
SELECT type, COUNT(*) as total_content 
FROM netflix 
GROUP BY type;

--2 Find the most common rating for movies and tv shows 

SELECT 
type,
rating
FROM
(
SELECT 
type,
rating,
COUNT(*),
RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC ) AS ranking
FROM netflix
GROUP BY 1,2) as t1
WHERE ranking=1

-- 3. List all movies released in a specific year(e.g. 2020)

SELECT show_id,title, release_year from netflix where release_year=2020 and type='Movie';

--4 find the top 5 countries having most content on netflix

SELECT 
UNNEST(STRING_TO_ARRAY(country,',')) as new_country,
COUNT(show_id) as total_content
FROM netflix 
GROUP BY new_country
ORDER BY 2 DESC
LIMIT 5
;


--5 IDENTIFY THE LONGEST MOVIE ? 

SELECT show_id,type,duration FROM netflix where 
type='Movie'
and 
duration=(SELECT MAX(duration) from netflix);

-- 6 find content added in the last 5 yrs	
SELECT *
from netflix 
WHERE 
TO_DATE(date_added,'Month DD, YYYY') >= CURRENT_DATE -iNTERVAL '5 YEARS';

--7 FIND ALL MOVIE/tv sHOWS DIRECTED BY 'RAJIV CHILAKA'

SELECT * FROM netflix WHERE director ILIKE '%Rajiv Chilaka%';
-- ILIKE will help in cases where name starts with r and c in director name;

--8 List all TV shows with more than 5 seasons 

SELECT show_id,type,duration
FROM netflix WHERE type='TV Show' AND CAST(SPLIT_PART(duration,' ',1) AS INT) >=5
ORDER BY CAST(SPLIT_PART(duration,' ',1) AS INT) DESC 
;

--9 cOUNT THE NUMBER OF CONTENT ITEMS IN EACH GENRE 

SELECT
UNNEST(STRING_TO_ARRAY(listed_in,',')) as new_listed,
COUNT(show_id) as total_content
FROM netflix 
GROUP BY new_listed
ORDER BY 2 DESC
;

--10 find each year and the average number of content realesed by india on netflix. eturn top 5 yr with highest content release 

SELECT 
	EXTRACT(YEAR FROM TO_DATE(date_added,'Month DD, YYYY')) as year,
	Count(*) as total_content,
	Count(*):: numeric / (SELECT COUNT(*) FROM netflix WHERE country='India') *100 as avg_content 
	FROM netflix 
WHERE country ILIKE '%India%'
GROUP BY year
ORDER BY total_content DESC;

--11 List all the movies which are documentries 
SELECT * FROM netflix WHERE type='Movie' and listed_in ILIKE '%Documentaries%';

--12 Find all the content without a director.
SELECT * FROM netflix WHERE director is null;

--13 Find how many movie actor 'Salman Khan' appeard in last 15 years
SELECT * FROM netflix WHERE 
casts ILIKE '%Salman Khan%'
AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) -15 ;

--14 Find the top 10 actors who have appeard in the highest number of moovies Produced in India .
SELECT 
COUNT(*),
UNNEST(STRING_TO_ARRAY(casts,','))as actor
FROM NETFLIX WHERE type='Movie'and country ILIKE '%India%'
GROUP BY actor
ORDER BY 1 DESC 
limit 10;

--15 Categorixe the content based on the presence of keywords 'kill' and 'violence' in the description field.
-- Label content containing these keywords as 'Bad' and all other content as 'Good'.Count hwo many items fall in each category.

WITH new_table
as 
(
SELECT *,
	CASE
	WHEN
	description ILIKE '%kill%' or description ILIKE '%violence%'
	THEN 'Bad_content'
	ELSE 'Good_content'
	END category
from netflix
)
SELECT category,
COUNT(*) as total_content
FROM new_table 
GROUP BY 1;

;


