with source as (
    select * from {{ source('raw_supply_chain', 'order_items') }}
)

select
    order_item_id,
    order_id,
    product_id,
    quantity,
    order_item_product_price as unit_price,
    discount,
    sales as line_item_sales_total,
    benefit_per_order as profit
from source
