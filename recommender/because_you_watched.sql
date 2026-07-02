/*
Because You Watched

Recommend unseen movies that share genres
with movies the user rated highly.
*/

WITH liked_movies AS (

    SELECT movie_id
    FROM ratings
    WHERE user_id = 1
      AND rating >= 4

),

candidate_movies AS (

    SELECT
        mg2.movie_id,
        COUNT(*) AS similarity_score

    FROM liked_movies lm

    JOIN movie_genres mg1
        ON lm.movie_id = mg1.movie_id

    JOIN movie_genres mg2
        ON mg1.genre_id = mg2.genre_id

    WHERE mg2.movie_id NOT IN (

        SELECT movie_id
        FROM ratings
        WHERE user_id = 1

    )

    GROUP BY mg2.movie_id

),

movie_stats AS (

    SELECT
        cm.movie_id,
        cm.similarity_score,
        AVG(r.rating) AS avg_rating,
        COUNT(r.rating) AS rating_count

    FROM candidate_movies cm

    JOIN ratings r
        ON cm.movie_id = r.movie_id

    GROUP BY
        cm.movie_id,
        cm.similarity_score

    HAVING COUNT(r.rating) >= 20

)

SELECT
    m.title,

    ROUND(
        (
            ms.similarity_score * 0.7
            +
            ms.avg_rating * 20 * 0.3
        )::numeric,
        2
    ) AS recommendation_score,

    ROUND(ms.avg_rating::numeric,2) AS average_rating,

    'Recommended because you highly rate ' ||
    STRING_AGG(DISTINCT g.genre_name, ', ')
    AS explanation

FROM movie_stats ms

JOIN movies m
    ON ms.movie_id = m.movie_id

JOIN movie_genres mg
    ON m.movie_id = mg.movie_id

JOIN genres g
    ON mg.genre_id = g.genre_id

GROUP BY
    m.movie_id,
    m.title,
    ms.similarity_score,
    ms.avg_rating

ORDER BY recommendation_score DESC

LIMIT 10;
