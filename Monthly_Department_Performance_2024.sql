-- Goal: Following query aims to compare the monthly changes (month-over-month) in both the quantity of visits and revenue within each department for the year 2024.

-- Step 1: Monthly summary of visit quantities
SELECT 
    DATE_FORMAT(invoice_date, '%Y-%m') AS month,
    department,
    SUM(quantity) AS month_quantity,
    LAG(SUM(quantity)) OVER (PARTITION BY department ORDER BY DATE_FORMAT(invoice_date, '%Y-%m')) AS previous_month_quantity,
    ((SUM(quantity) / LAG(SUM(quantity)) OVER (PARTITION BY department ORDER BY DATE_FORMAT(invoice_date, '%Y-%m')) - 1)) AS quantity_perc_change
FROM work.visits
WHERE invoice_date >= '2024-01-01'
GROUP BY month, department
ORDER BY department, month;

-- Step 2: Monthly summary of revenue
SELECT 
    DATE_FORMAT(invoice_date, '%Y-%m') AS month,
    department,
    SUM(quantity * Net_price) AS month_revenue,
    LAG(SUM(quantity * Net_price)) OVER (PARTITION BY department ORDER BY DATE_FORMAT(invoice_date, '%Y-%m')) AS previous_month_revenue,
    ((SUM(quantity * Net_price) / LAG(SUM(quantity * Net_price)) OVER (PARTITION BY department ORDER BY DATE_FORMAT(invoice_date, '%Y-%m')) - 1)) AS revenue_perc_change
FROM work.visits
WHERE invoice_date >= '2024-01-01'
GROUP BY month, department
ORDER BY department, month;

-- Step 3: Combine quantity and revenue summaries using CTEs

WITH qty_sum AS (
  SELECT 
    DATE_FORMAT(invoice_date, '%Y-%m') AS month,
    department,
    SUM(quantity) AS month_quantity,
    LAG(SUM(quantity)) OVER (PARTITION BY department ORDER BY DATE_FORMAT(invoice_date, '%Y-%m')) AS previous_month_quantity,
    ((SUM(quantity) / LAG(SUM(quantity)) OVER (PARTITION BY department ORDER BY DATE_FORMAT(invoice_date, '%Y-%m')) - 1)) AS quantity_perc_change
  FROM work.visits
  WHERE invoice_date >= '2024-01-01'
  GROUP BY month, department
  ORDER BY department, month
),
rev_sum AS (
  SELECT 
    DATE_FORMAT(invoice_date, '%Y-%m') AS month,
    department,
    SUM(quantity * Net_price) AS month_revenue,
    LAG(SUM(quantity * Net_price)) OVER (PARTITION BY department ORDER BY DATE_FORMAT(invoice_date, '%Y-%m')) AS previous_month_revenue,
    ((SUM(quantity * Net_price) / LAG(SUM(quantity * Net_price)) OVER (PARTITION BY department ORDER BY DATE_FORMAT(invoice_date, '%Y-%m')) - 1)) AS revenue_perc_change
  FROM work.visits
  WHERE invoice_date >= '2024-01-01'
  GROUP BY month, department
  ORDER BY department, month
)
SELECT
  qty_sum.department,
  qty_sum.month,
  qty_sum.quantity_perc_change,
  rev_sum.revenue_perc_change
FROM qty_sum
INNER JOIN rev_sum
  ON qty_sum.month = rev_sum.month 
  AND qty_sum.department = rev_sum.department
ORDER BY qty_sum.department, qty_sum.month;

