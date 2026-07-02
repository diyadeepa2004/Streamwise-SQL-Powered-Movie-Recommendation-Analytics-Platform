/*
Question:
What do we recommend based on the user's favourite genres?

Input:
User ID

Output:
Top 10 unseen movies from genres the user rates highly.
*/

WITH favourite_genres AS (

    SELECT
        mg.genre_id,
        AVG(r.rating) AS avg_rating
    FROM ratings r
    JOIN movie_genres mg
        ON r.movie_id = mg.movie_id
    WHERE r.user_id = 1
    GROUP BY mg.genre_id
    HAVING AVG(r.rating) >= 4

),

unseen_movies AS (

    SELECT
        m.movie_id,
        m.title,
        fg.avg_rating
    FROM movies m
    JOIN movie_genres mg
        ON m.movie_id = mg.movie_id
    JOIN favourite_genres fg
        ON mg.genre_id = fg.genre_id
    WHERE m.movie_id NOT IN (

        SELECT movie_id
        FROM ratings
        WHERE user_id = 1

    )

)

SELECT
    um.title,

    ROUND(
        (
            MAX(um.avg_rating) * 0.6
            +
            AVG(r.rating) * 0.4
        )::numeric,
        2
    ) AS recommendation_score,

    ROUND(AVG(r.rating)::numeric, 2) AS movie_average_rating,

    COUNT(r.rating) AS rating_count

FROM unseen_movies um

JOIN ratings r
    ON um.movie_id = r.movie_id

GROUP BY
    um.movie_id,
    um.title

HAVING COUNT(r.rating) >= 20

ORDER BY recommendation_score DESC,
         rating_count DESC

LIMIT 10;
