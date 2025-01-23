SELECT
    SUBSTRING(MD5(CONCAT(product, series)), 1, 16) AS product_id,
    product AS product_name,
    series AS product_series,
    sales_price AS suggested_retail_price
FROM
    {{ source('company_dw', 'products') }}
