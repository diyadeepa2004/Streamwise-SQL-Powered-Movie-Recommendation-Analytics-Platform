/*
Similar Users Recommend

Find users with similar tastes and
recommend movies they enjoyed.
*/

WITH target_user_movies AS (

    SELECT movie_id
    FROM ratings
    WHERE user_id = 1
      AND rating >= 4

),

similar_users AS (

    SELECT
        r.user_id,
        COUNT(*) AS common_movies

    FROM ratings r

    JOIN target_user_movies tum
        ON r.movie_id = tum.movie_id

    WHERE r.user_id <> 1
      AND r.rating >= 4

    GROUP BY r.user_id

    HAVING COUNT(*) >= 5

),

candidate_movies AS (

    SELECT
        r.movie_id,
        COUNT(*) AS recommendation_strength

    FROM ratings r

    JOIN similar_users su
        ON r.user_id = su.user_id

    WHERE r.rating >= 4

      AND r.movie_id NOT IN (

            SELECT movie_id
            FROM ratings
            WHERE user_id = 1

      )

    GROUP BY r.movie_id

),

movie_stats AS (

    SELECT
        cm.movie_id,
        cm.recommendation_strength,
        AVG(r.rating) AS avg_rating,
        COUNT(r.rating) AS rating_count

    FROM candidate_movies cm

    JOIN ratings r
        ON cm.movie_id = r.movie_id

    GROUP BY
        cm.movie_id,
        cm.recommendation_strength

    HAVING COUNT(r.rating) >= 20

)

SELECT
    m.title,

    ms.recommendation_strength,

    ROUND(ms.avg_rating::numeric, 2) AS average_rating,

    ROUND(
        (
            ms.recommendation_strength * 0.7
            +
            ms.avg_rating * 20 * 0.3
        )::numeric,
        2
    ) AS recommendation_score,

    'Recommended because '
    || ms.recommendation_strength
    || ' users with similar tastes enjoyed this movie (Average Rating: '
    || ROUND(ms.avg_rating::numeric, 2)
    || '/5)'
    AS explanation

FROM movie_stats ms

JOIN movies m
    ON ms.movie_id = m.movie_id

ORDER BY recommendation_score DESC

LIMIT 10;
