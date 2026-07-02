-- ==========================================
-- STREAMWISE DATABASE SCHEMA
-- ==========================================

-- USERS
CREATE TABLE users (
    user_id INTEGER PRIMARY KEY,
    age INTEGER,
    gender CHAR(1),
    occupation VARCHAR(100),
    zip_code VARCHAR(20)
);

-- MOVIES
CREATE TABLE movies (
    movie_id INTEGER PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    release_year INTEGER
);

-- GENRES
CREATE TABLE genres (
    genre_id SERIAL PRIMARY KEY,
    genre_name VARCHAR(50) UNIQUE NOT NULL
);

-- MOVIE-GENRE RELATIONSHIP
CREATE TABLE movie_genres (
    movie_id INTEGER,
    genre_id INTEGER,

    PRIMARY KEY (movie_id, genre_id),

    FOREIGN KEY (movie_id)
        REFERENCES movies(movie_id),

    FOREIGN KEY (genre_id)
        REFERENCES genres(genre_id)
);

-- RATINGS
CREATE TABLE ratings (
    user_id INTEGER,
    movie_id INTEGER,
    rating INTEGER CHECK (rating BETWEEN 1 AND 5),
    rated_at TIMESTAMPTZ,

    PRIMARY KEY (user_id, movie_id),

    FOREIGN KEY (user_id)
        REFERENCES users(user_id),

    FOREIGN KEY (movie_id)
        REFERENCES movies(movie_id)
);

-- PERFORMANCE INDEXES
CREATE INDEX idx_ratings_user
ON ratings(user_id);

CREATE INDEX idx_ratings_movie
ON ratings(movie_id);

CREATE INDEX idx_movie_genres_movie
ON movie_genres(movie_id);

CREATE INDEX idx_movie_genres_genre
ON movie_genres(genre_id);
