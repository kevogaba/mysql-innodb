SELECT
    sales_agent,
    manager,
    regional_office,
    CONCAT(manager, ' | ', regional_office) AS team_name
FROM
    {{ source('company_dw', 'sales_teams') }}
