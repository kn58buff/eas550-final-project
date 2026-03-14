import sys
import os

sys.path.append(os.path.abspath("."))

from sqlalchemy import text
from src.utils.db_connection import get_engine

engine = get_engine()

with engine.connect() as conn:
    result = conn.execute(text("""SELECT table_name
                                FROM information_schema.tables
                                WHERE table_schema = 'public';"""))
    
    print("Connection successful:", result.fetchall())