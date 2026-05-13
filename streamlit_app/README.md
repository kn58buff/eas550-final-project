# Supply Chain Streamlit Dashboard

Live dashboard backed by the dbt-built warehouse on Neon Postgres.

## What's inside

- `app.py` — Streamlit app with 3 dynamic Plotly visualizations (daily revenue
  time-series, Pareto revenue contribution, top-customer leaderboard) and
  4 interactive widgets (date-range slider, Pareto-band selectbox, segment
  selectbox, Top-N slider).
- `db.py` — Neon connection via `psycopg2.pool.ThreadedConnectionPool`,
  cached process-wide with `st.cache_resource`. Every query function uses
  `@st.cache_data` with a TTL so re-renders don't re-query.
- `requirements.txt` — pinned dependencies for the Render build.
- `.streamlit/config.toml` — server defaults for headless Render.

## Run locally

```bash
cd streamlit_app
cp .env.example .env        # fill in real Neon credentials
pip install -r requirements.txt
set -a && source .env && set +a   # export vars into the shell
streamlit run app.py
```

## Deploy to Render (continuous deployment)

The repo root contains a [`render.yaml`](../render.yaml) blueprint. To wire it up:

1. Push the repo to GitHub.
2. In Render, click **New → Blueprint** and pick the repo. Render detects
   `render.yaml`, creates the `eas550-supply-chain-dashboard` web service,
   and prompts for the secret env vars marked `sync: false`
   (`PGHOST`, `PGDATABASE`, `PGUSER`, `PGPASSWORD`). Enter the Neon values.
3. After the first build, Render watches the `main` branch and redeploys
   automatically on every push (`autoDeploy: true`).

The service start command points Streamlit at `$PORT` (Render assigns one
at runtime), binds `0.0.0.0`, and runs headless. The health-check path
`/_stcore/health` matches Streamlit's built-in endpoint, so Render can
gate traffic on readiness.

## Why no `pd.read_csv`?

Every chart queries the warehouse through `db.run_query()`. The data
shown is whatever dbt last built into `public.report_*` on Neon — no
static files in the image.

## Credentials policy

- Nothing is hardcoded in code or YAML.
- Local: `.env` (gitignored). Template lives at `.env.example`.
- Render: set as environment variables on the service. `render.yaml`
  uses `sync: false` so values are entered in the dashboard, not committed.
- DB connection forces `sslmode=require` (Neon enforces TLS anyway).
