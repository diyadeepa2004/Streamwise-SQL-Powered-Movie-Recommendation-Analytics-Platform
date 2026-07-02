from sqlalchemy import create_engine
import pandas as pd

DATABASE_URL = "postgresql://postgres:qwerty@localhost/streamwise"

engine = create_engine(DATABASE_URL)

def run_query(query):
    return pd.read_sql(query, engine)
