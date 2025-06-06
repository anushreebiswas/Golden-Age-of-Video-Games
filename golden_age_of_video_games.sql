1.The ten best-selling video games
--The database contains two tables games_sold and reviews respectively.

SELECT * FROM game_sales
ORDER BY games_sold DESC
LIMIT 10;

2. Missing review scores
One big shortcoming is that there is not any reviews data for some of the games on the game_sales table.

SELECT COUNT(g.game)
FROM game_sales AS g
LEFT JOIN reviews AS r
ON g.game = r.game
WHERE critic_score IS NULL AND user_score IS NULL;

3. Years that video game critics loved
It looks like a little less than ten percent of the games on the game_sales table don't have any reviews data.
That's a small enough percentage that we can continue our exploration.

SELECT g.year,ROUND(AVG(CAST(critic_score AS numeric)),2) AS avg_critic_score,COUNT(*) AS num_games
FROM game_sales g
INNER JOIN reviews r
ON g.game = r.game
GROUP BY g.year
ORDER BY ROUND(AVG(CAST(critic_score AS numeric)),2) DESC
LIMIT 10;

4. Was 1990 really that great?
Maybe there weren't a lot of video games in our dataset that were released in certain years.
Let's update our query and find out whether 1990 really was such a great year for video games.

SELECT year,ROUND(AVG(CAST(critic_score AS numeric)),2) AS avg_critic_score,COUNT(*) AS num_games
FROM game_sales AS g
INNER JOIN reviews AS r
ON g.game = r.game
GROUP BY year
HAVING COUNT(*)>4
ORDER BY ROUND(AVG(CAST(critic_score AS numeric)),2) DESC
LIMIT 10;

5. Years that dropped off the critics' favorites list
Which years dropped off the list due to having four or fewer reviewed games?

WITH top_critic_years(year,avg_critic_score,num_games) AS (SELECT g.year,ROUND(AVG(CAST(critic_score AS numeric)),2) AS avg_critic_score,COUNT(*) AS num_games
FROM game_sales g
INNER JOIN reviews r
ON g.game = r.game
GROUP BY g.year
ORDER BY ROUND(AVG(CAST(critic_score AS numeric)),2) DESC
LIMIT 10),
top_critic_years_more_than_four_games(year,avg_critic_score,num_games) AS (SELECT year,ROUND(AVG(CAST(critic_score AS numeric)),2) AS avg_critic_score,COUNT(*) AS num_games
FROM game_sales AS g
INNER JOIN reviews AS r
ON g.game = r.game
GROUP BY year
HAVING COUNT(*)>4
ORDER BY ROUND(AVG(CAST(critic_score AS numeric)),2) DESC
LIMIT 10)
SELECT c.year,c.avg_critic_score,c.num_games FROM top_critic_years AS c
FULL OUTER JOIN top_critic_years_more_than_four_games AS f
ON c.year=f.year
WHERE f.year IS NULL
ORDER BY c.avg_critic_score DESC;

6. Years video game players loved

SELECT year,ROUND(AVG(CAST(user_score AS numeric)),2) AS avg_user_score,
COUNT(*) AS num_games
FROM game_sales AS g
INNER JOIN reviews AS r
ON g.game = r.game
GROUP BY year
HAVING COUNT(*)>4
ORDER BY ROUND(AVG(CAST(user_score AS numeric)),2) DESC
LIMIT 10;

7.Years that both players and critics loved i.e the best video game years

WITH top_user_years_more_than_four_games(year,avg_user_score,num_games) AS (SELECT year,ROUND(AVG(CAST(user_score AS numeric)),2) AS avg_user_score,COUNT(*) AS num_games
FROM game_sales AS g
INNER JOIN reviews AS r
ON g.game = r.game
GROUP BY year
HAVING COUNT(*)>4
ORDER BY ROUND(AVG(CAST(user_score AS numeric)),2) DESC
LIMIT 10),
top_critic_years_more_than_four_games(year,avg_critic_score,num_games) AS (SELECT year,ROUND(AVG(CAST(critic_score AS numeric)),2) AS avg_critic_score,COUNT(*) AS num_games
FROM game_sales AS g
INNER JOIN reviews AS r
ON g.game = r.game
GROUP BY year
HAVING COUNT(*)>4
ORDER BY ROUND(AVG(CAST(critic_score AS numeric)),2) DESC
LIMIT 10)
SELECT t1.year FROM top_critic_years_more_than_four_games AS t1
INNER JOIN top_user_years_more_than_four_games AS t2
ON t1.year=t2.year;

8. Sales in the best video game years

WITH top_user_years_more_than_four_games(year,avg_user_score,num_games) AS (SELECT year,ROUND(AVG(CAST(user_score AS numeric)),2) AS avg_user_score,COUNT(*) AS num_games
FROM game_sales AS g
INNER JOIN reviews AS r
ON g.game = r.game
GROUP BY year
HAVING COUNT(*)>4
ORDER BY ROUND(AVG(CAST(user_score AS numeric)),2) DESC
LIMIT 10),
top_critic_years_more_than_four_games(year,avg_critic_score,num_games) AS (SELECT year,ROUND(AVG(CAST(critic_score AS numeric)),2) AS avg_critic_score,COUNT(*) AS num_games
FROM game_sales AS g
INNER JOIN reviews AS r
ON g.game = r.game
GROUP BY year
HAVING COUNT(*)>4
ORDER BY ROUND(AVG(CAST(critic_score AS numeric)),2) DESC
LIMIT 10)
SELECT t1.year,CAST(SUM(games_sold) AS integer) AS total_games_sold FROM top_critic_years_more_than_four_games AS t1
INNER JOIN top_user_years_more_than_four_games AS t2
ON t1.year=t2.year
INNER JOIN game_sales AS t3
ON t1.year=t3.year
GROUP BY t1.year
ORDER BY CAST(SUM(games_sold) AS integer) DESC;


