with source as (
    select * from {{ source('raw_supply_chain', 'orders') }}
)

select
    order_id,
    order_customer_id as customer_id,
    order_date,
    order_status as status,
    shipping_date,
    shipping_mode
from source
