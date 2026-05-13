with orders as (
    select * from {{ ref('stg_orders') }}
),

order_items as (
    select * from {{ ref('stg_order_items') }}
),

products as (
    select * from {{ ref('stg_products') }}
)

select
    oi.order_item_id,

    o.order_id,
    o.customer_id,
    p.product_id,

    o.order_date,
    o.status as order_status,
    o.shipping_mode,

    oi.quantity,
    oi.unit_price,
    oi.discount,
    oi.line_item_sales_total,
    oi.profit
from order_items oi
left join orders o on oi.order_id = o.order_id
left join products p on oi.product_id = p.product_id
