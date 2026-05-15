"""Neon Postgres connection pool for the Streamlit app."""

from __future__ import annotations

import os
from contextlib import contextmanager

import pandas as pd
import streamlit as st
from psycopg2 import pool
from dotenv import load_dotenv
load_dotenv()

def _require(name: str) -> str:
    value = os.environ.get(name)
    if not value:
        raise RuntimeError(
            f"Missing required environment variable: {name}. "
            "Set it in Render → Environment (or your local .env)."
        )
    return value


@st.cache_resource(show_spinner=False)
def get_pool() -> pool.ThreadedConnectionPool:
    return pool.ThreadedConnectionPool(
        minconn=1,
        maxconn=int(os.environ.get("PG_POOL_MAX", "5")),
        host=_require("PGHOST"),
        port=int(os.environ.get("PGPORT", "5432")),
        dbname=_require("PGDATABASE"),
        user=_require("PGUSER"),
        password=_require("PGPASSWORD"),
        # Neon requires TLS.
        sslmode=os.environ.get("PGSSLMODE", "require"),
        connect_timeout=10,
        application_name="eas550-streamlit",
    )


@contextmanager
def get_conn():
    p = get_pool()
    conn = p.getconn()
    try:
        yield conn
    finally:
        p.putconn(conn)


def run_query(sql: str, params: tuple | None = None) -> pd.DataFrame:
    # Raw psycopg2 cursor avoids pandas' SQLAlchemy-only DBAPI warning.
    with get_conn() as conn, conn.cursor() as cur:
        cur.execute(sql, params)
        columns = [desc[0] for desc in cur.description]
        rows = cur.fetchall()
    return pd.DataFrame(rows, columns=columns)
