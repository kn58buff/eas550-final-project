import os
from dotenv import load_dotenv
from sqlalchemy import create_engine

# Load environment variables from .env
load_dotenv()

PGHOST = os.getenv("PGHOST")
PGDATABASE = os.getenv("PGDATABASE")
PGUSER = os.getenv("PGUSER")
PGPASSWORD = os.getenv("PGPASSWORD")
PGPORT = os.getenv("PGPORT")


# Validate environment variables
if not all([PGHOST, PGDATABASE, PGUSER, PGPASSWORD, PGPORT]):
    raise ValueError("Missing one or more database environment variables.")


# Build database URL
DATABASE_URL = (
    f"postgresql+psycopg2://{PGUSER}:{PGPASSWORD}"
    f"@{PGHOST}:{PGPORT}/{PGDATABASE}"
)


engine = create_engine(DATABASE_URL, pool_pre_ping=True)


def get_engine():
    """
    Returns a SQLAlchemy engine instance for database operations.
    """
    return engine