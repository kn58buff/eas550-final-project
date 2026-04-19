with products as (
    select * from {{ ref('stg_products') }}
),

categories as (
    select * from {{ ref('stg_categories') }}
),

departments as (
    select * from {{ ref('stg_departments') }}
),

final as (
    select
        p.product_id,
        p.product_name,
        p.price,
        c.category_name,
        d.department_name
    from products p
    left join categories c on p.category_id = c.category_id
    left join departments d on c.department_id = d.department_id
)

select * from final