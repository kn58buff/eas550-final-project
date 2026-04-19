select
    category_id,
    category_name,
    department_id
from {{ source('raw_supply_chain', 'categories') }}