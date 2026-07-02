import sys
from pathlib import Path

ROOT_DIR = Path(__file__).resolve().parent.parent
sys.path.append(str(ROOT_DIR))

import streamlit as st
from utils.database import run_query

st.set_page_config(
    page_title="StreamWise",
    page_icon="🎬",
    layout="wide"
)

st.title("🎬 StreamWise")

st.subheader("SQL-Powered Movie Recommendation Analytics Platform")

st.markdown("""
Generate movie recommendations directly from SQL queries
using the MovieLens dataset and PostgreSQL.
""")

# -------------------------
# DATABASE METRICS
# -------------------------

try:

    total_users = run_query(
        "SELECT COUNT(*) AS total FROM users"
    ).iloc[0]["total"]

    total_movies = run_query(
        "SELECT COUNT(*) AS total FROM movies"
    ).iloc[0]["total"]

    total_ratings = run_query(
        "SELECT COUNT(*) AS total FROM ratings"
    ).iloc[0]["total"]

    col1, col2, col3 = st.columns(3)

    with col1:
        st.metric(
            "👥 Users",
            f"{total_users:,}"
        )

    with col2:
        st.metric(
            "🎬 Movies",
            f"{total_movies:,}"
        )

    with col3:
        st.metric(
            "⭐ Ratings",
            f"{total_ratings:,}"
        )

except Exception as e:

    st.error(
        f"Database connection error: {e}"
    )

# -------------------------
# FEATURES
# -------------------------

st.markdown("---")

st.subheader("Features")

col1, col2 = st.columns(2)

with col1:

    st.info("""
    🎯 Genre-Based Recommendations

    Recommend movies based on a user's
    highest-rated genres.
    """)

    st.info("""
    👥 Similar Users

    Recommend movies liked by users
    with similar rating behaviour.
    """)

with col2:

    st.info("""
    📈 Trending Movies

    Recommend movies that are currently
    popular across all users.
    """)

    st.info("""
    📊 Analytics Dashboard

    Explore genres, ratings and
    movie popularity using SQL.
    """)

# -------------------------
# DATASET INFORMATION
# -------------------------

st.markdown("---")

st.subheader("Dataset")

st.write("""
Dataset: MovieLens 100K

• 943 Users
• 1,682 Movies
• 100,000 Ratings

Used to demonstrate SQL-powered recommendation systems.
""")

st.markdown("---")

st.success(
    "Use the sidebar to explore users, generate recommendations and analyse movie trends."
)
