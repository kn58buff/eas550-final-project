with fact_orders as (
    select * from {{ ref('fact_orders') }}
),

dim_products as (
    select * from {{ ref('dim_products') }}
),

order_products as (
    select distinct
        order_id,
        product_id
    from fact_orders
),

product_pairs as (
    select
        a.product_id    as product_a,
        b.product_id    as product_b,
        count(*)        as times_bought_together
    from order_products a
    join order_products b
        on  a.order_id    = b.order_id
        and a.product_id  < b.product_id
    group by 1, 2
),

ranked as (
    select
        pp.*,
        dp_a.product_name   as product_a_name,
        dp_b.product_name   as product_b_name,
        rank() over (
            order by times_bought_together desc
        )                   as overall_rank
    from product_pairs pp
    join dim_products dp_a on dp_a.product_id = pp.product_a
    join dim_products dp_b on dp_b.product_id = pp.product_b
)

select *
from ranked
where overall_rank <= 20
order by overall_rank