

WITH win_counts AS (
    SELECT product_name AS product_name,
        sum(case
                when deal_stage = 'Won' then 1
                else 0
            end) AS won_deals,
        sum(case
                when (deal_stage != 'NaN'
                        and deal_stage is not null) then 1
                else 0
            end) AS all_deals
    FROM
    (SELECT *
    FROM {{ ref('crm_int_kpi') }} a
    LEFT JOIN warehouse.dim_date b ON DATE_FORMAT(COALESCE(a.ts_close_date, '1970-01-01'), '%Y-%m-01') = b.date_actual 
    WHERE a.ts_close_date IS NOT NULL
        AND a.ts_close_date != '' AND b.date_actual != '' AND b.date_actual IS NOT NULL AND a.ts_close_date != '0000-00-00') AS virtual_table
    GROUP BY product_name
    ORDER BY won_deals DESC )
select product_name,
        sum(won_deals) as won_deals,
        sum(all_deals) as all_deals,
    sum(won_deals) / sum(all_deals) as product_win_rate
from win_counts
group by product_name