import psycopg2 
from dotenv import load_dotenv
import psycopg2.extras; psycopg2.extensions.set_wait_callback(psycopg2.extras.wait_select)
import os
import sqlalchemy
from sqlalchemy import create_engine


# load .env file and set env vars
load_dotenv()
PGHOST = os.getenv("PGHOST")
PGDATABASE = os.getenv("PGDATABASE")
PGUSER = os.getenv("PGUSER")
PGPASSWORD = os.getenv("PGPASSWORD")
PGPORT = os.getenv("PGPORT")


conn_str = f"dbname={PGDATABASE} user={PGUSER} password={PGPASSWORD} host={PGHOST} port={PGPORT} sslmode=require&channel_binding=require"

engine = create_engine(conn_str)

