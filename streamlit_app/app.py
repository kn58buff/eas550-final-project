"""Streamlit dashboard for the EAS 550 supply chain project."""

from __future__ import annotations

from datetime import date

import pandas as pd
import plotly.express as px
import streamlit as st

from db import run_query

st.set_page_config(
    page_title="EAS 550 — Supply Chain Analytics Final Project",
    page_icon="📦",
    layout="wide",
)

st.title("Supply Chain Analytics")
st.caption(
    "Live data from the Neon Postgres warehouse, modeled with dbt. "
    "All charts query the warehouse on each filter change."
)


@st.cache_data(ttl=600, show_spinner="Loading daily revenue…")
def load_daily_revenue(
    start: date, end: date, segment: str | None
) -> pd.DataFrame:
    if not segment or segment == "All":
        sql = """
            select order_date, total_orders, gross_revenue, net_profit
            from public.report_daily_revenue
            where order_date between %s and %s
            order by order_date
        """
        return run_query(sql, params=(start, end))

    sql = """
        select fo.order_date,
               count(distinct fo.order_id)         as total_orders,
               sum(fo.line_item_sales_total)       as gross_revenue,
               sum(fo.profit)                      as net_profit
        from public.fact_orders fo
        join public.dim_customers dc
          on fo.customer_id = dc.customer_id
        where fo.order_date between %s and %s
          and dc.segment = %s
        group by fo.order_date
        order by fo.order_date
    """
    return run_query(sql, params=(start, end, segment))


@st.cache_data(ttl=600, show_spinner="Loading revenue contribution…")
def load_revenue_contribution(band: str | None) -> pd.DataFrame:
    if band and band != "All":
        sql = """
            select category_name, revenue, pct_of_total,
                   cumulative_pct, pareto_band
            from public.report_revenue_contribution
            where pareto_band = %s
            order by revenue desc
        """
        return run_query(sql, params=(band,))

    sql = """
        select category_name, revenue, pct_of_total,
               cumulative_pct, pareto_band
        from public.report_revenue_contribution
        order by revenue desc
    """
    return run_query(sql)


@st.cache_data(ttl=600, show_spinner="Loading customer metrics…")
def load_top_customers(segment: str | None, n: int) -> pd.DataFrame:
    if segment and segment != "All":
        sql = """
            select customer_id, segment, city, state,
                   max(lifetime_revenue) as lifetime_revenue
            from public.report_customer_monthly_metrics
            where segment = %s
            group by customer_id, segment, city, state
            order by lifetime_revenue desc
            limit %s
        """
        return run_query(sql, params=(segment, n))

    sql = """
        select customer_id, segment, city, state,
               max(lifetime_revenue) as lifetime_revenue
        from public.report_customer_monthly_metrics
        group by customer_id, segment, city, state
        order by lifetime_revenue desc
        limit %s
    """
    return run_query(sql, params=(n,))


@st.cache_data(ttl=3600, show_spinner=False)
def load_date_bounds() -> tuple[date, date]:
    df = run_query(
        """
        select min(order_date) as min_d, max(order_date) as max_d
        from public.report_daily_revenue
        """
    )
    return df["min_d"].iloc[0], df["max_d"].iloc[0]


@st.cache_data(ttl=3600, show_spinner=False)
def load_segments() -> list[str]:
    df = run_query(
        """
        select distinct segment
        from public.report_customer_monthly_metrics
        where segment is not null
        order by 1
        """
    )
    return df["segment"].tolist()


min_d, max_d = load_date_bounds()

with st.sidebar:
    st.header("Filters")

    date_range = st.slider(
        "Order date range",
        min_value=min_d,
        max_value=max_d,
        value=(min_d, max_d),
        format="YYYY-MM-DD",
    )

    pareto_band = st.selectbox(
        "Pareto band (revenue contribution)",
        options=["All", "Top 80%", "Tail 20%"],
        index=0,
    )

    segment = st.selectbox(
        "Customer segment",
        options=["All", *load_segments()],
        index=0,
    )
    top_n = st.slider("Top N customers", min_value=5, max_value=50, value=10)


daily = load_daily_revenue(date_range[0], date_range[1], segment)

k1, k2, k3 = st.columns(3)
k1.metric("Gross revenue", f"${daily['gross_revenue'].sum():,.0f}")
k2.metric("Net profit", f"${daily['net_profit'].sum():,.0f}")
k3.metric("Orders", f"{daily['total_orders'].sum():,.0f}")


st.subheader("Gross revenue & net profit over time")

if daily.empty:
    st.info("No orders in the selected window.")
else:
    long_df = daily.melt(
        id_vars="order_date",
        value_vars=["gross_revenue", "net_profit"],
        var_name="metric",
        value_name="usd",
    )
    fig1 = px.line(
        long_df,
        x="order_date",
        y="usd",
        color="metric",
        labels={"order_date": "Date", "usd": "USD", "metric": "Metric"},
    )
    fig1.update_layout(height=400, legend_title_text="")
    st.plotly_chart(fig1, width="stretch")


st.subheader("Revenue contribution by category (Pareto)")

contrib = load_revenue_contribution(pareto_band)
if contrib.empty:
    st.info("No data for that band.")
else:
    fig2 = px.bar(
        contrib,
        x="category_name",
        y="revenue",
        color="pareto_band",
        hover_data=["pct_of_total", "cumulative_pct"],
        labels={
            "category_name": "Category",
            "revenue": "Revenue (USD)",
            "pareto_band": "Band",
        },
    )
    fig2.update_layout(height=420, xaxis_tickangle=-35)
    st.plotly_chart(fig2, width="stretch")


st.subheader(f"Top {top_n} customers by lifetime revenue")

top_customers = load_top_customers(segment, top_n)
if top_customers.empty:
    st.info("No customers match that filter.")
else:
    fig3 = px.bar(
        top_customers.sort_values("lifetime_revenue"),
        x="lifetime_revenue",
        y=top_customers["customer_id"].astype(str),
        color="segment",
        orientation="h",
        labels={
            "lifetime_revenue": "Lifetime revenue (USD)",
            "y": "Customer ID",
            "segment": "Segment",
        },
    )
    fig3.update_layout(height=max(320, 28 * len(top_customers)))
    st.plotly_chart(fig3, width="stretch")
    with st.expander("Show data"):
        st.dataframe(top_customers, width="stretch")


st.caption(
    "Connected via psycopg2 ThreadedConnectionPool to Neon Postgres. "
    "Credentials are read from environment variables on the Render host."
)
