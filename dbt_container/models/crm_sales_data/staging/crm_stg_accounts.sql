SELECT
    SUBSTRING(MD5(CONCAT(account, sector, year_established, office_location)), 1, 16) AS account_id,
    account AS account_name,
    sector AS industry,
    CAST(year_established AS UNSIGNED) AS year_established,
    revenue AS annual_revenue_mm,
    employees AS num_employees,
    office_location AS headquarters,
    subsidiary_of AS parent_company
FROM
    {{ source('company_dw', 'accounts') }}
