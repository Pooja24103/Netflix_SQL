DROP TABLE IF EXISTS netflix;



CREATE TABLE netflix
(
show_id VARCHAR(6),
type VARCHAR(10),
title VARCHAR(150),
director VARCHAR(208),
casts VARCHAR(1000),
country VARCHAR(150),
date_added VARCHAR(50),
release_year INT,
rating VARCHAR(10),
duration VARCHAR(15),
listed_in VARCHAR(100),
description VARCHAR(250)
);

SELECT*FROM netflix;

SELECT COUNT(*) AS total_content FROM netflix;

SELECT DISTINCT(country) FROM netflix;


-- 1.Count the number of Movies and tv shows
SELECT type,count(type)
FROM netflix
GROUP BY type


--2.Find the most common rating from movies and tv shows
SELECT 
	type,
	rating
	FROM 
	(SELECT 
		type,
		rating,
		count(*),
		RANK ()OVER(PARTITION BY type ORDER BY COUNT(*)DESC) as ranking
		FROM netflix
		GROUP BY type,rating
	)AS t1
WHERE ranking =1
		

--3.List all the movies released in a specific year(eg:2020)
SELECT * 
FROM netflix
WHERE type='Movie' AND release_year=2020;


--4.Find the top 5 countries with the most content on netflix 
SELECT 
	TRIM(UNNEST(STRING_TO_ARRAY(country,','))) AS new_country,
	COUNT(show_id) AS total_content
FROM netflix
GROUP BY new_country
ORDER BY total_content DESC
LIMIT 5


--5.Indentify the longest movie
SELECT * FROM netflix
WHERE
type='Movie' AND duration=(SELECT MAX(duration) FROM netflix)


--6.Find the content added in the last 5 years
SELECT * FROM netflix
WHERE 
TO_DATE(date_added,'Month DD,YYYY')>=CURRENT_DATE-INTERVAL '5 years';


--7. Find all the movies/TV shows directed by 'Rajiv chilaka'
SELECT * FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%';


--8.List all the tv shows having more than 5 seasons
SELECT * FROM netflix
WHERE type='TV Show'
      AND 
	  SPLIT_PART(duration,' ',1)::numeric > 5; 

	  
--9. Count the number of content items in each genre	  
SELECT TRIM(genre)AS genre,
	count(*) AS total_content
	FROM netflix,
	     UNNEST(STRING_TO_ARRAY(listed_in,','))AS genre
GROUP BY genre
ORDER BY 2 DESC;


--10.Find each year and the avg number of content release by India on netflix.Return top 5 year with highest avg content release
SELECT 
	EXTRACT (YEAR FROM TO_DATE(date_added,'Month DD,YYY'))AS year,
	COUNT(*),
	ROUND(COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country='India')::numeric*100,2) AS avg_content_per_year
FROM netflix
WHERE country='India'
GROUP BY 1
ORDER BY 1 DESC


--11.List all movies that are documentries
SELECT * FROM netflix
WHERE type='Movie' AND listed_in LIKE '%Documentaries%'


--12.Find all content without a director
SELECT * FROM netflix
WHERE director IS NULL


--13.Find in how many movies the actor 'Salman Khan' appeared in last 10 years
SELECT * FROM netflix
WHERE casts ILIKE '%Salman Khan%' AND release_year > EXTRACT(YEAR FROM CURRENT_DATE)-10


--14. Find the top 10 actors who have appeared in the highest number of movies providuced in India.
SELECT UNNEST(STRING_TO_ARRAY(casts,',')) AS new_casts,COUNT(*) AS total_content
FROM netflix
WHERE country ILIKE '%India%'
GROUP BY new_casts
ORDER BY total_content DESC
LIMIT 10


--15.Categorise the content based on the presence of the keyword 'kill' and 'voilance' in the description field.
--Label content containing these keywords as 'bad' and all the othercontent as 'good'.
--count how many items into each category

WITH new_table AS
(
SELECT *,
CASE 
    WHEN description ILIKE '%Kill%' OR description ILIKE '%Voilance%' THEN 'Bad'
	ELSE 'Good'
END category
FROM netflix
) 
SELECT category ,count(*) AS total_content
FROM new_table
GROUP BY category













