with fact_orders as (
    select * from {{ ref('fact_orders') }}
)

select
    order_date,
    count(distinct order_id) as total_orders,
    sum(line_item_sales_total) as gross_revenue,
    sum(profit) as net_profit
from fact_orders
group by 1
order by 1 desc
