EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
with fact_orders as (
    select * from fact_orders
),

dim_customers as (
    select * from dim_customers
),

monthly_orders as (
    select
        customer_id,
        date_trunc('month', order_date)::date   as order_month,
        order_id,
        sum(line_item_sales_total)              as order_revenue,
        sum(profit)                             as order_profit,
        count(*)                                as line_items
    from fact_orders
    where order_date is not null
    group by 1, 2, 3
),

customer_monthly as (
    select
        customer_id,
        order_month,
        count(order_id)         as orders_placed,
        sum(order_revenue)      as monthly_revenue,
        sum(order_profit)       as monthly_profit,
        sum(line_items)         as total_line_items
    from monthly_orders
    group by 1, 2
),

customer_running_totals as (
    select
        cm.customer_id,
        cm.order_month,
        cm.orders_placed,
        cm.monthly_revenue,
        cm.monthly_profit,
        cm.total_line_items,
        dc.segment,
        dc.city,
        dc.state,
        sum(cm.monthly_revenue) over (
            partition by cm.customer_id
            order by     cm.order_month
            rows between unbounded preceding and current row
        )                       as lifetime_revenue,
        lag(cm.monthly_revenue) over (
            partition by cm.customer_id
            order by     cm.order_month
        )                       as prev_month_revenue,
        row_number() over (
            partition by cm.customer_id
            order by     cm.order_month
        )                       as active_month_number
    from customer_monthly cm
    left join dim_customers dc
        on cm.customer_id = dc.customer_id
),

final as (
    select
        *,
        case
            when prev_month_revenue > 0 then
                round(
                    (monthly_revenue - prev_month_revenue)
                    / prev_month_revenue * 100,
                    2
                )
        end                     as mom_revenue_pct_change,
        rank() over (
            partition by order_month, segment
            order by     monthly_revenue desc
        )                       as segment_rank_this_month
    from customer_running_totals
)

select *
from final
order by customer_id, order_month;