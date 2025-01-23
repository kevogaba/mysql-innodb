SELECT
    opportunity_id,
    COALESCE(sales_agent, 'Unknown') AS sales_agent,
    COALESCE(product, 'Unknown') AS product_name,
    COALESCE(account, 'Unknown') AS company_name,
    COALESCE(deal_stage, 'Unknown') AS deal_stage,
    COALESCE(STR_TO_DATE(engage_date, '%Y-%m-%d %H:%i:%s'), NULL) AS ts_engage_date,
    COALESCE(STR_TO_DATE(close_date, '%Y-%m-%d %H:%i:%s'), NULL) AS ts_close_date,
    CASE
        WHEN engage_date IS NULL THEN NULL
        WHEN (close_date IS NULL OR close_date = 'NaN') AND (engage_date IS NOT NULL AND engage_date != 'NaN') THEN DATEDIFF(CURDATE(), STR_TO_DATE(engage_date, '%Y-%m-%d %H:%i:%s'))
        ELSE DATEDIFF(STR_TO_DATE(close_date, '%Y-%m-%d %H:%i:%s'), STR_TO_DATE(engage_date, '%Y-%m-%d %H:%i:%s'))
    END AS deal_age,
    COALESCE(close_value, 0) AS revenue
FROM
    {{ source('company_dw', 'sales_pipeline') }}
