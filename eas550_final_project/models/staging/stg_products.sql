with source as (
    select * from {{ source('raw_supply_chain', 'products') }}
)

select
    product_id,
    product_name,
    product_price as price,
    category_id
from source
