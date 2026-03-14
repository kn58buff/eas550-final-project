import sys
import os

sys.path.append(os.path.abspath("."))

from sqlalchemy import text
from src.utils.db_connection import get_engine

engine = get_engine()

with open("sql/security/security.sql", "r") as f:
    schema_sql = f.read()

with engine.connect() as conn:
    conn.execute(text(schema_sql))
    conn.commit()

print("Schema executed successfully.")