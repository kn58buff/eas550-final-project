with category_revenue as (
    select
        dp.category_id,
        sum(fo.line_item_sales_total) as revenue
    from fact_orders   fo
    join dim_products  dp using (product_id)
    group by 1
),

with_totals as (
    select
        category_id,
        revenue,
        sum(revenue) over ()                            as total_revenue,
        sum(revenue) over (
            order by revenue desc
            rows between unbounded preceding and current row
        )                                               as cumulative_revenue,
        round(
            revenue / sum(revenue) over () * 100, 2
        )                                               as pct_of_total,
        round(
            sum(revenue) over (
                order by revenue desc
                rows between unbounded preceding and current row
            ) / sum(revenue) over () * 100, 2
        )                                               as cumulative_pct
    from category_revenue
)

select
    category_id,
    round(revenue, 2)           as revenue,
    pct_of_total,
    cumulative_pct,
    -- Pareto flag: categories that make up the first 80% of revenue
    case
        when cumulative_pct - pct_of_total < 80 then 'Top 80%'
        else 'Tail 20%'
    end                         as pareto_band
from with_totals
order by revenue desc