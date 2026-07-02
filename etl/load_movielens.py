import pandas as pd
from sqlalchemy import create_engine

# ---------------------------------
# DATABASE CONNECTION
# ---------------------------------

DB_PASSWORD = "qwerty"

engine = create_engine(
    f"postgresql+psycopg2://postgres:{DB_PASSWORD}@localhost:5432/streamwise"
)

# ---------------------------------
# LOAD USERS
# ---------------------------------

users = pd.read_csv(
    "data/u.user",
    sep="|",
    names=["user_id", "age", "gender", "occupation", "zip_code"],
    encoding="latin-1"
)

users.to_sql(
    "users",
    engine,
    if_exists="append",
    index=False
)

print("Users loaded")

# ---------------------------------
# LOAD RATINGS
# ---------------------------------

ratings = pd.read_csv(
    "data/u.data",
    sep="\t",
    names=["user_id", "movie_id", "rating", "timestamp"]
)

ratings["rated_at"] = pd.to_datetime(
    ratings["timestamp"],
    unit="s"
)

ratings = ratings[
    ["user_id", "movie_id", "rating", "rated_at"]
]

ratings.to_sql(
    "ratings",
    engine,
    if_exists="append",
    index=False
)

print("Ratings loaded")

# ---------------------------------
# LOAD GENRES
# ---------------------------------

genres = pd.read_csv(
    "data/u.genre",
    sep="|",
    names=["genre_name", "old_id"],
    encoding="latin-1"
)

# remove the final empty row
genres = genres[genres["genre_name"].notna()]

genres = genres[["genre_name"]]

genres.to_sql(
    "genres",
    engine,
    if_exists="append",
    index=False
)

print("Genres loaded")

# # ---------------------------------
# # LOAD MOVIES
# # ---------------------------------

movie_columns = [
    "movie_id",
    "title",
    "release_date",
    "video_release_date",
    "imdb_url"
]

genre_flags = [f"genre_{i}" for i in range(19)]

all_columns = movie_columns + genre_flags

movies_raw = pd.read_csv(
    "data/u.item",
    sep="|",
    names=all_columns,
    encoding="latin-1"
)

movies = movies_raw[["movie_id", "title"]]

movies["release_year"] = (
    movies_raw["release_date"]
    .str[-4:]
    .fillna("0")
)

movies["release_year"] = pd.to_numeric(
    movies["release_year"],
    errors="coerce"
)

movies.to_sql(
    "movies",
    engine,
    if_exists="append",
    index=False
)

print("Movies loaded")

# ---------------------------------
# LOAD MOVIE GENRES
# ---------------------------------

genres_df = pd.read_sql(
    "SELECT genre_id, genre_name FROM genres",
    engine
)

genre_lookup = {
    index: row["genre_id"]
    for index, row in genres_df.iterrows()
}

movie_genre_rows = []

for _, movie in movies_raw.iterrows():

    movie_id = movie["movie_id"]

    for i in range(19):

        if movie[f"genre_{i}"] == 1:

            movie_genre_rows.append(
                {
                    "movie_id": movie_id,
                    "genre_id": genre_lookup[i]
                }
            )

movie_genres = pd.DataFrame(movie_genre_rows)

movie_genres.to_sql(
    "movie_genres",
    engine,
    if_exists="append",
    index=False
)

print("Movie genres loaded")
