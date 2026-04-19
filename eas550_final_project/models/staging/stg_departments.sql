select
    department_id,
    department_name
from {{ source('raw_supply_chain', 'departments') }}