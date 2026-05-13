with source as (
    select * from {{ source('raw_supply_chain', 'customers') }}
)

select
    customer_id,
    first_name,
    last_name,
    segment,
    street,
    city,
    state
from source
