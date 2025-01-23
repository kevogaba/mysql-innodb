{{ config(
    materialized='table' 
) }}

WITH RECURSIVE DQ (datum) AS (
  SELECT DATE '1970-01-01'
  UNION ALL
  SELECT DQ.datum + INTERVAL 1 DAY
  FROM DQ
  WHERE DQ.datum < DATE '2025-01-23' -- Assuming today's date is 2025-01-23
)

SELECT
    YEAR(datum) AS date_key,
    datum AS date_actual,
    UNIX_TIMESTAMP(datum) AS epoch,
    DAYNAME(datum) AS day_name,
    DAYOFWEEK(datum) AS day_of_week,
    DAY(datum) AS day_of_month,
    DAYOFYEAR(datum) AS day_of_year,
    WEEK(datum) AS week_of_month,
    YEAR(datum) * 100 + WEEK(datum) AS week_of_year,
    YEAR(datum) AS year_actual,
    DATE_SUB(datum, INTERVAL (DAYOFWEEK(datum) - 1) DAY) AS first_day_of_week,
    DATE_SUB(datum, INTERVAL (DAYOFWEEK(datum) - 7) DAY) AS last_day_of_week,
    DATE_SUB(datum, INTERVAL (DAY(datum) - 1) DAY) AS first_day_of_month,
    LAST_DAY(datum) AS last_day_of_month,
    DATE_TRUNC(quarter, datum) AS first_day_of_quarter,
    DATE_ADD(DATE_ADD(DATE_TRUNC(quarter, datum), INTERVAL 3 MONTH), INTERVAL -1 DAY) AS last_day_of_quarter, 
    DATE(CONCAT(YEAR(datum), '-01-01')) AS first_day_of_year,
    DATE(CONCAT(YEAR(datum), '-12-31')) AS last_day_of_year,
    DATE_FORMAT(datum, '%m%Y') AS mmyyyy,
    DATE_FORMAT(datum, '%m%d%Y') AS mmddyyyy,
    CASE WHEN DAYOFWEEK(datum) IN (6, 7) THEN 1 ELSE 0 END AS weekend_indr
FROM DQ
ORDER BY date_key
