-- Custom singular test: every fact_orders row should represent a
-- real sale, i.e. quantity > 0 and line_item_sales_total >= 0.
-- Returns offending rows; dbt fails the test if any row comes back.
select
    order_item_id,
    order_id,
    quantity,
    line_item_sales_total
from {{ ref('fact_orders') }}
where quantity is null
   or quantity <= 0
   or line_item_sales_total < 0
