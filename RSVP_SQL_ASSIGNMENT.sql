USE imdb;

/* Now that you have imported the data sets, let’s explore some of the tables. 
 To begin with, it is beneficial to know the shape of the tables and whether any column has null values.
 Further in this segment, you will take a look at 'movies' and 'genre' tables.*/

-- Segment 1:

-- Q1. Find the total number of rows in each table of the schema?
-- Type your code below:

SELECT table_name,
       table_rows
FROM   information_schema.tables
WHERE  table_schema = 'imdb';

/* Answer-
director_mapping - 3867
genre - 14662
movie - 8390
names - 25905
ratings - 8230
role_mapping - 14302
*/

-- Q2. Which columns in the movie table have null values?
-- Type your code below:
SELECT Sum(CASE
             WHEN t.id IS NULL THEN 1
             ELSE 0
           END) AS id,
       Sum(CASE
             WHEN t.title IS NULL THEN 1
             ELSE 0
           END) AS title,
       Sum(CASE
             WHEN t.year IS NULL THEN 1
             ELSE 0
           END) AS year,
       Sum(CASE
             WHEN t.date_published IS NULL THEN 1
             ELSE 0
           END) AS date_published,
       Sum(CASE
             WHEN t.duration IS NULL THEN 1
             ELSE 0
           END) AS duration,
       Sum(CASE
             WHEN t.country IS NULL THEN 1
             ELSE 0
           END) AS country,
       Sum(CASE
             WHEN t.worlwide_gross_income IS NULL THEN 1
             ELSE 0
           END) AS worlwide_gross_income,
       Sum(CASE
             WHEN t.languages IS NULL THEN 1
             ELSE 0
           END) AS languages,
       Sum(CASE
             WHEN t.production_company IS NULL THEN 1
             ELSE 0
           END) AS production_company
FROM   movie AS t;

/* Answer-
    country, worlwide_gross_income, languages, production_company
*/

-- Now as you can see four columns of the movie table has null values. Let's look at the at the movies released each year. 
-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)

/* Output format for the first part:

+---------------+-------------------+
| Year			|	number_of_movies|
+-------------------+----------------
|	2017		|	2134			|
|	2018		|		.			|
|	2019		|		.			|
+---------------+-------------------+


Output format for the second part of the question:
+---------------+-------------------+
|	month_num	|	number_of_movies|
+---------------+----------------
|	1			|	 134			|
|	2			|	 231			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

-- Code for Count every year

SELECT year,
       Count(*) AS number_of_movies
FROM   movie
GROUP  BY year; 

-- Code for Count monthwise

SELECT Month(date_published) AS month_num,
       Count(*)              AS number_of_movies
FROM   movie
GROUP  BY Month(date_published)
ORDER  BY month_num; 


/*The highest number of movies is produced in the month of March.
So, now that you have understood the month-wise trend of movies, let’s take a look at the other details in the movies table. 
We know USA and India produces huge number of movies each year. Lets find the number of movies produced by USA or India for the last year.*/
  
-- Q4. How many movies were produced in the USA or India in the year 2019??
-- Type your code below:

SELECT Count(*) AS number_of_movies
FROM   movie
WHERE  ( country LIKE '%USA%'
          OR country LIKE '%India%' )
       AND year = '2019'; 


/* USA and India produced more than a thousand movies(you know the exact number!) in the year 2019.
Exploring table Genre would be fun!! 
Let’s find out the different genres in the dataset.*/

-- Q5. Find the unique list of the genres present in the data set?
-- Type your code below:

SELECT DISTINCT( genre )
FROM   genre; 

/* So, RSVP Movies plans to make a movie of one of these genres.
Now, wouldn’t you want to know which genre had the highest number of movies produced in the last year?
Combining both the movie and genres table can give more interesting insights. */

-- Q6.Which genre had the highest number of movies produced overall?
-- Type your code below:

WITH highest_genre
     AS (SELECT g.genre,
                Count(*)                    AS number_of_movies,
                Rank()
                  OVER(
                    ORDER BY Count(*) DESC) AS RankOfGenre
         FROM   movie AS m
                INNER JOIN genre AS g
                        ON m.id = g.movie_id
         GROUP  BY g.genre)
SELECT highest_genre.genre,
       highest_genre.number_of_movies
FROM   highest_genre
WHERE  rankofgenre = 1; 
/* So, based on the insight that you just drew, RSVP Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/

-- Q7. How many movies belong to only one genre?
-- Type your code below:

WITH genre_one
     AS (SELECT m.id,
                Count(g.genre) AS numof_genre
         FROM   movie m
                JOIN genre g
                  ON m.id = g.movie_id
         GROUP  BY m.id
         HAVING numof_genre = 1)
SELECT Count(*) AS one_genre_movies
FROM   genre_one; 


/* There are more than three thousand movies which has only one genre associated with them.
So, this figure appears significant. 
Now, let's find out the possible duration of RSVP Movies’ next project.*/

-- Q8.What is the average duration of movies in each genre? 
-- (Note: The same movie can belong to multiple genres.)


/* Output format:

+---------------+-------------------+
| genre			|	avg_duration	|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
SELECT g.genre,
       Round(Avg(m.duration), 2) AS avg_duration
FROM   movie m
       JOIN genre g
         ON m.id = g.movie_id
GROUP  BY g.genre; 


/* Now you know, movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.
Lets find where the movies of genre 'thriller' on the basis of number of movies.*/

-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 
-- (Hint: Use the Rank function)


/* Output format:
+---------------+-------------------+---------------------+
| genre			|		movie_count	|		genre_rank    |	
+---------------+-------------------+---------------------+
|drama			|	2312			|			2		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:

-- Code to find the rank of Thriller genre
WITH rank_thriller
     AS (SELECT g.genre,
                Count(m.id)                    AS movie_count,
                Rank()
                  OVER (
                    ORDER BY Count(m.id) DESC) AS genre_rank
         FROM   movie m
                JOIN genre g
                  ON m.id = g.movie_id
         GROUP  BY g.genre)
SELECT *
FROM   rank_thriller
WHERE  genre = 'Thriller'; 

/*Thriller movies is in top 3 among all genres in terms of number of movies
 In the previous segment, you analysed the movies and genres tables. 
 In this segment, you will analyse the ratings table as well.
To start with lets get the min and max values of different columns in the table*/




-- Segment 2:




-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
| min_avg_rating|	max_avg_rating	|	min_total_votes   |	max_total_votes 	 |min_median_rating|min_median_rating|
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
|		0		|			5		|	       177		  |	   2000	    		 |		0	       |	8			 |
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+*/
-- Type your code below:

SELECT Min(avg_rating)    AS min_avg_rating,
       Max(avg_rating)    AS max_avg_rating,
       Min(total_votes)   AS min_total_votes,
       Max(total_votes)   AS max_total_votes,
       Min(median_rating) AS min_median_rating,
       Max(median_rating) AS max_median_rating
FROM   ratings;


/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 
Now, let’s find out the top 10 movies based on average rating.*/

-- Q11. Which are the top 10 movies based on average rating?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		movie_rank    |
+---------------+-------------------+---------------------+
| Fan			|		9.6			|			5	  	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
-- It's ok if RANK() or DENSE_RANK() is used too

WITH 10_top
     AS (SELECT m.title,
                r.avg_rating,
                Rank()
                  OVER(
                    ORDER BY r.avg_rating DESC) AS movie_rank
         FROM   movie m
                JOIN ratings r
                  ON m.id = r.movie_id)
SELECT *
FROM   10_top
WHERE  movie_rank <= 10; 


/* Do you find you favourite movie FAN in the top 10 movies with an average rating of 9.6? If not, please check your code again!!
So, now that you know the top 10 movies, do you think character actors and filler actors can be from these movies?
Summarising the ratings table based on the movie counts by median rating can give an excellent insight.*/

-- Q12. Summarise the ratings table based on the movie counts by median ratings.
/* Output format:

+---------------+-------------------+
| median_rating	|	movie_count		|
+-------------------+----------------
|	1			|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
-- Order by is good to have

SELECT r.median_rating,
       Count(m.id) AS movie_count
FROM   movie m
       JOIN ratings r
         ON m.id = r.movie_id
GROUP  BY r.median_rating
ORDER  BY movie_count DESC; 


/* Movies with a median rating of 7 is highest in number. 
Now, let's find out the production house with which RSVP Movies can partner for its next project.*/

-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??
/* Output format:
+------------------+-------------------+---------------------+
|production_company|movie_count	       |	prod_company_rank|
+------------------+-------------------+---------------------+
| The Archers	   |		1		   |			1	  	 |
+------------------+-------------------+---------------------+*/
-- Type your code below:

WITH production_rank AS
(
SELECT m.production_company,COUNT(m.id) AS movie_count,
		RANK() OVER (ORDER BY COUNT(m.id) DESC) AS prod_company_rank
         FROM   movie m
                JOIN ratings r
                  ON m.id = r.movie_id
                  WHERE r.avg_rating>8 AND m.production_company IS NOT NULL
	GROUP BY m.production_company
    )
    SELECT *
    FROM production_rank
    WHERE prod_company_rank=1;


-- It's ok if RANK() or DENSE_RANK() is used too
-- Answer can be Dream Warrior Pictures or National Theatre Live or both

-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?
/* Output format:

+---------------+-------------------+
| genre			|	movie_count		|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

SELECT g.genre,
       Count(*) AS movie_count
FROM   genre AS g
       LEFT JOIN movie AS m
              ON g.movie_id = m.id
       LEFT JOIN ratings AS r
              ON g.movie_id = r.movie_id
WHERE  r.total_votes > 1000
       AND m.country LIKE '%USA%'
       AND Month(m.date_published) = 3
       AND Year(m.date_published) = 2017
GROUP  BY g.genre; 


-- Lets try to analyse with a unique problem statement.
-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		genre	      |
+---------------+-------------------+---------------------+
| Theeran		|		8.3			|		Thriller	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:

SELECT m.title,
       r.avg_rating,
       g.genre
FROM   genre g
       LEFT JOIN movie m
              ON m.id = g.movie_id
       LEFT JOIN ratings r
              ON m.id = r.movie_id
WHERE  r.avg_rating > 8
       AND m.title LIKE 'The%';


-- You should also try your hand at median rating and check whether the ‘median rating’ column gives any significant insights.
-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
-- Type your code below:

SELECT Count(*) AS median_rating_count
FROM   movie m
       JOIN ratings r
         ON r.movie_id = m.id
WHERE  ( m.date_published BETWEEN '2018-04-01' AND '2019-04-01' )
       AND r.median_rating = 8; 


-- Once again, try to solve the problem given below.
-- Q17. Do German movies get more votes than Italian movies? 
-- Hint: Here you have to find the total number of votes for both German and Italian movies.
-- Type your code below:

-- CODE FOR GERMAN- answer - 4421525
SELECT 
    SUM(r.total_votes) AS Count_German
FROM
    movie AS m
        INNER JOIN
    ratings AS r ON m.id = r.movie_id
WHERE
    m.languages LIKE '%German%';

-- CODE FOR ITALIAN- answer - 2559540
SELECT 
    SUM(r.total_votes) AS Count_Italian
FROM
    movie AS m
        INNER JOIN
    ratings AS r ON m.id = r.movie_id
WHERE
    m.languages LIKE '%Italian%';


-- Answer is Yes

/* Now that you have analysed the movies, genres and ratings tables, let us now analyse another table, the names table. 
Let’s begin by searching for null values in the tables.*/




-- Segment 3:



-- Q18. Which columns in the names table have null values??
/*Hint: You can find null values for individual columns or follow below output format
+---------------+-------------------+---------------------+----------------------+
| name_nulls	|	height_nulls	|date_of_birth_nulls  |known_for_movies_nulls|
+---------------+-------------------+---------------------+----------------------+
|		0		|			123		|	       1234		  |	   12345	    	 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:
SELECT Sum(CASE
             WHEN t.name IS NULL THEN 1
             ELSE 0
           END) AS name_nulls,
       Sum(CASE
             WHEN t.height IS NULL THEN 1
             ELSE 0
           END) AS height_nulls,
       Sum(CASE
             WHEN t.date_of_birth IS NULL THEN 1
             ELSE 0
           END) AS date_of_birth_nulls,
       Sum(CASE
             WHEN t.known_for_movies IS NULL THEN 1
             ELSE 0
           END) AS known_for_movies_nulls
FROM   names AS t;


/* There are no Null value in the column 'name'.
The director is the most important person in a movie crew. 
Let’s find out the top three directors in the top three genres who can be hired by RSVP Movies.*/

-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?
-- (Hint: The top three genres would have the most number of movies with an average rating > 8.)
/* Output format:

+---------------+-------------------+
| director_name	|	movie_count		|
+---------------+-------------------|
|James Mangold	|		4			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

WITH genre_list AS
(
           SELECT     g.genre
           FROM       movie AS m
           INNER JOIN genre AS g
           ON         m.id = g.movie_id
           INNER JOIN ratings AS r
           ON         m.id = r.movie_id
           WHERE      r.avg_rating > 8
           GROUP BY   g.genre
           ORDER BY   Count(*) DESC limit 3 ) , director_list AS
(
           SELECT     n.NAME                                     AS director,
                      Count(*)                                   AS movie_count,
                      Row_number() OVER (ORDER BY Count(*) DESC) AS rankno
           FROM       movie                                      AS m
           INNER JOIN director_mapping                           AS d
           ON         m.id = d.movie_id
           INNER JOIN names AS n
           ON         d.name_id = n.id
           LEFT JOIN  genre AS gg
           ON         m.id = gg.movie_id
           INNER JOIN genre_list AS gl
           ON         gg.genre = gl.genre
           INNER JOIN ratings AS rt
           ON         m.id = rt.movie_id
           WHERE      rt.avg_rating > 8
           GROUP BY   n.NAME
           ORDER BY   Count(*) DESC)
SELECT *
FROM   director_list
WHERE  rankno <=3;


/* James Mangold can be hired as the director for RSVP's next project. Do you remeber his movies, 'Logan' and 'The Wolverine'. 
Now, let’s find out the top two actors.*/

-- Q20. Who are the top two actors whose movies have a median rating >= 8?
/* Output format:

+---------------+-------------------+
| actor_name	|	movie_count		|
+-------------------+----------------
|Christain Bale	|		10			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

SELECT n.name      AS actor_name,
       Count(m.id) AS movie_count
FROM   movie m
       JOIN role_mapping ro
         ON m.id = ro.movie_id
       JOIN names n
         ON n.id = ro.name_id
       JOIN ratings r
         ON m.id = r.movie_id
WHERE  ro.category = 'actor'
       AND r.median_rating >= 8
GROUP  BY n.name
ORDER  BY Count(m.id) DESC
LIMIT  2; 



/* Have you find your favourite actor 'Mohanlal' in the list. If no, please check your code again. 
RSVP Movies plans to partner with other global production houses. 
Let’s find out the top three production houses in the world.*/

-- Q21. Which are the top three production houses based on the number of votes received by their movies?
/* Output format:
+------------------+--------------------+---------------------+
|production_company|vote_count			|		prod_comp_rank|
+------------------+--------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:

SELECT   m.production_company,
         Sum(r.total_votes)                            AS vote_count,
         Rank() OVER(ORDER BY Sum(r.total_votes) DESC) AS prod_comp_rank
FROM     movie m
JOIN     ratings r
ON       m.id=r.movie_id
GROUP BY m.production_company
ORDER BY vote_count DESC limit 3;



/*Yes Marvel Studios rules the movie world.
So, these are the top three production houses based on the number of votes received by the movies they have produced.

Since RSVP Movies is based out of Mumbai, India also wants to woo its local audience. 
RSVP Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel. 
Let’s find who these actors could be.*/

-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actor_name	|	total_votes		|	movie_count		  |	actor_avg_rating 	 |actor_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Yogi Babu	|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

SELECT   n.NAME                                                                                       AS actor_name,
         Sum(r.total_votes)                                                                           AS total_votes,
         Count(m.id)                                                                                  AS movie_count,
         Round(Sum(r.avg_rating * r.total_votes) / Sum(r.total_votes), 2)                             AS actor_avg_rating,
         Rank() OVER (ORDER BY Round(Sum(r.avg_rating * r.total_votes) / Sum(r.total_votes), 2) DESC) AS actor_rank
FROM     movie m
JOIN     role_mapping rm
ON       rm.movie_id=m.id
JOIN     names n
ON       n.id=rm.name_id
JOIN     ratings r
ON       r.movie_id=m.id
WHERE    m.country LIKE 'India'
AND      rm.category='actor'
GROUP BY n.NAME
HAVING   Count(m.id)>=5 limit 1;



-- Top actor is Vijay Sethupathi

-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
-- Note: The actresses should have acted in at least three Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	actress_avg_rating 	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Tabu		|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:
SELECT   n.NAME                                                                                       AS actress_name,
         Sum(r.total_votes)                                                                           AS total_votes,
         Count(m.id)                                                                                  AS movie_count,
         Round(Sum(r.avg_rating * r.total_votes) / Sum(r.total_votes), 2)                             AS actor_avg_rating,
         Rank() OVER (ORDER BY Round(Sum(r.avg_rating * r.total_votes) / Sum(r.total_votes), 2) DESC) AS actor_rank
FROM     movie m
JOIN     role_mapping rm
ON       rm.movie_id=m.id
JOIN     names n
ON       n.id=rm.name_id
JOIN     ratings r
ON       r.movie_id=m.id
WHERE    m.country LIKE '%India%' AND m.languages LIKE '%Hindi%'
AND      rm.category='actress'
GROUP BY n.NAME
HAVING   Count(m.id)>=3 LIMIT 5;


/* Taapsee Pannu tops with average rating 7.74. 
Now let us divide all the thriller movies in the following categories and find out their numbers.*/


/* Q24. Select thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/
-- Type your code below:

SELECT m.title,
       r.avg_rating,
       CASE
         WHEN r.avg_rating > 8 THEN 'Superhit movies'
         WHEN r.avg_rating > 7
              AND r.avg_rating <= 8 THEN 'Hit movies'
         WHEN r.avg_rating > 5
              AND r.avg_rating <= 7 THEN 'One-time-watch movies'
         ELSE 'Flop movies'
       END AS movie_category
FROM   movie m
       JOIN genre g
              ON g.movie_id = m.id
       JOIN ratings r
         ON m.id = r.movie_id
WHERE  g.genre = 'Thriller';


/* Until now, you have analysed various tables of the data set. 
Now, you will perform some tasks that will give you a broader understanding of the data in this segment.*/

-- Segment 4:

-- Q25. What is the genre-wise running total and moving average of the average movie duration? 
-- (Note: You need to show the output table in the question.) 
/* Output format:
+---------------+-------------------+---------------------+----------------------+
| genre			|	avg_duration	|running_total_duration|moving_avg_duration  |
+---------------+-------------------+---------------------+----------------------+
|	comdy		|			145		|	       106.2	  |	   128.42	    	 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:

	WITH genresum AS
	(
	SELECT g.genre,
			ROUND(avg(m.duration),2) AS avg_duration
	FROM
	movie AS m
	INNER JOIN
	genre AS g
	ON m.id=g.movie_id
	GROUP BY g.genre
	)
	SELECT *,
			ROUND(SUM(avg_duration) OVER w1,2) AS running_total,
			ROUND(AVG(avg_duration) OVER w2,2) AS moving_avg
	FROM genresum
	WINDOW w1 as (ORDER BY avg_duration ROWS UNBOUNDED PRECEDING),
	w2 AS (ORDER BY avg_duration ROWS UNBOUNDED PRECEDING);


-- Round is good to have and not a must have; Same thing applies to sorting


-- Let us find top 5 movies of each year with top 3 genres.

-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 
-- (Note: The top 3 genres would have the most number of movies.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| genre			|	year			|	movie_name		  |worldwide_gross_income|movie_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	comedy		|			2017	|	       indian	  |	   $103244842	     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

-- Top 3 Genres based on most number of movies
with top_genre as 
(
select genre as top_g , count(movie_id)
from genre
group by genre
order by count(movie_id) desc
limit 3
),
 group_genre as
(
select movie_id,group_concat(genre) as g_genre
from genre
group by movie_id
),
c_wgi as
(
select id,title,worlwide_gross_income,year,
case when worlwide_gross_income like '$%' then convert(substring(worlwide_gross_income,3),signed int)
 when worlwide_gross_income like 'INR%' then convert(substring(worlwide_gross_income,5),signed int) 
end as c_worldwide_gross_income
from movie
order by c_worldwide_gross_income desc
),
final as
(
select distinct gg.movie_id,gg.g_genre,m.year,m.title,cwgi.c_worldwide_gross_income,
dense_rank() over (partition BY m.year ORDER BY cwgi.c_worldwide_gross_income DESC) AS movie_rank
from group_genre gg
left join movie m on gg.movie_id=m.id
inner join c_wgi cwgi on m.id=cwgi.id
inner join genre g on m.id = g.movie_id
where g.genre in (select top_g from top_genre)
)
select g_genre as 'Genre',year,title,c_worldwide_gross_income,movie_rank 
from final
where movie_rank<=5;

-- Finally, let’s find out the names of the top two production houses that have produced the highest number of hits among multilingual movies.
-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?
/* Output format:
+-------------------+-------------------+---------------------+
|production_company |movie_count		|		prod_comp_rank|
+-------------------+-------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:

WITH production_rank
     AS (SELECT m.production_company,
                Count(m.id)                    AS movie_count,
                Row_number()
                  OVER (
                    ORDER BY Count(m.id) DESC) AS prod_comp_rank
         FROM   movie m
                JOIN ratings r
                  ON r.movie_id = m.id
         WHERE  r.median_rating >= 8
                AND m.production_company IS NOT NULL
                AND m.languages LIKE '%,%'
         GROUP  BY m.production_company)
SELECT *
FROM   production_rank
WHERE  prod_comp_rank <= 2; 

-- Multilingual is the important piece in the above question. It was created using POSITION(',' IN languages)>0 logic
-- If there is a comma, that means the movie is of more than one language


-- Q28. Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |actress_avg_rating	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Laura Dern	|			1016	|	       1		  |	   9.60			     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

WITH actressrank_tbl
     AS (SELECT n.NAME
                AS
                actress_name
                   ,
                Sum(total_votes)
                   AS total_votes,
                Count(m.id)
                AS
                   movie_count,
                Round(Sum(r.avg_rating * r.total_votes) / Sum(r.total_votes), 2)
                AS
                actress_avg_rating,
                Rank()
                  OVER (
                    ORDER BY Count(m.id) DESC, Round(Sum(r.avg_rating *
                  r.total_votes) /
                  Sum(r.total_votes), 2) DESC)
                AS
                   actress_rank
         FROM   movie m
                JOIN role_mapping rm
                  ON m.id = rm.movie_id
                JOIN names n
                  ON n.id = rm.name_id
                JOIN ratings r
                  ON m.id = r.movie_id
                JOIN genre g
                  ON m.id = g.movie_id
         WHERE  rm.category = 'actress'
                AND g.genre = 'drama'
                AND r.avg_rating > 8
         GROUP  BY n.NAME)
SELECT *
FROM   actressrank_tbl
WHERE  actress_rank <= 3;

/* Q29. Get the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations

Format:
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
| director_id	|	director_name	|	number_of_movies  |	avg_inter_movie_days |	avg_rating	| total_votes  | min_rating	| max_rating | total_duration |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
|nm1777967		|	A.L. Vijay		|			5		  |	       177			 |	   5.65	    |	1754	   |	3.7		|	6.9		 |		613		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+

--------------------------------------------------------------------------------------------*/
-- Type you code below:

WITH nextrelease_date AS (
SELECT 
	n.NAME,
	m.title, 
    m.date_published,
	Lead(m.date_published,1) OVER ( partition BY n.NAME ORDER BY m.date_published) AS next_release_date
 FROM movie AS m
 INNER JOIN director_mapping AS dm
 ON m.id= dm.movie_id
 INNER JOIN names AS n
 ON dm.name_id = n.id
 ORDER BY n.NAME
),
diff AS(
SELECT * ,
	Datediff(next_release_date, date_published) AS days_diff
    FROM nextrelease_date
),
avginterd AS (
SELECT  Avg(days_diff) AS AvgInter , NAME
FROM diff
GROUP BY NAME
),
 director AS (
SELECT
	dm.name_id AS Director_id,
	n.NAME AS director_name,
	Count(*) AS number_of_movies,
    Row_number() OVER (ORDER BY Count(*) DESC) AS DirectorRank,
	Avg(r.avg_rating) AS avg_rating,
	Sum(r.total_votes) AS total_votes,
	Min(r.avg_rating) AS MinRating,
    Max(r.avg_rating) AS MaxRating,
	Sum(m.duration) AS total_duration
FROM
	movie AS m
    INNER JOIN ratings AS r
    ON m.id = r.movie_id
    INNER JOIN director_mapping AS dm
    ON m.id= dm.movie_id
    INNER JOIN names AS n
    ON dm.name_id = n.id
    GROUP BY dm.name_id
)
SELECT  d.Director_id,
		d.director_name,
        d.number_of_movies,
        a.AvgInter as avg_inter_movie_days,
        d.avg_rating,
        d.total_votes,
        d.MinRating,
        d.MaxRating,
        d.total_duration,
        d.DirectorRank
	FROM director AS d
INNER JOIN avginterd AS a
ON d.director_name = a.NAME
WHERE DirectorRank<=9;

/*nm2096009	Andrew Jones	5	190.7500	3.02000	1989	2.7	3.2	432	1
nm1777967	A.L. Vijay	5	176.7500	5.42000	1754	3.7	6.9	613	2
nm6356309	Özgür Bakar	4	112.0000	3.75000	1092	3.1	4.9	374	3
nm2691863	Justin Price	4	315.0000	4.50000	5343	3.0	5.8	346	4
nm0814469	Sion Sono	4	331.0000	6.02500	2972	5.4	6.4	502	5
nm0831321	Chris Stokes	4	198.3333	4.32500	3664	4.0	4.6	352	6
nm0425364	Jesse V. Johnson	4	299.0000	5.45000	14778	4.2	6.5	383	7
nm0001752	Steven Soderbergh	4	254.3333	6.47500	171684	6.2	7.0	401	8
nm0515005	Sam Liu	4	260.3333	6.22500	28557	5.8	6.7	312	9 /*
