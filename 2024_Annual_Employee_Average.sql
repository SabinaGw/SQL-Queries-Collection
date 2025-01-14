-- Goal: In the following query, my goal is to calculate the average number of employees in 2024 for each company location. The result is essential for planning the budget for 2025.
-- 
-- Steps:
-- 1. Create two window functions:
--    a. Employee Count Per Month: Generate a list of dates for each month in 2024 and calculate the number of employees at the start of each month for each location.
--    b. Average Annual Employee Count: Calculate the average number of employees over the year for each location.
-- 2. Combine the monthly and annual average data to display the monthly employee count along with the annual average for each location.

WITH Employee_Months AS (
    SELECT 
        Location, 
        YEAR(m.Date) AS Year, 
        MONTH(m.Date) AS Month, 
        COUNT(*) AS Employee_Count 
    FROM (
-- Generate a list of dates for each month in 2024
        SELECT DATE_FORMAT(DATE_ADD('2024-01-01', INTERVAL n MONTH), '%Y-%m-01') AS Date 
        FROM (
-- Create a list of `n` values from 0 to 11, corresponding to the 12 months
            SELECT 0 AS n 
            UNION ALL SELECT 1 
            UNION ALL SELECT 2 
            UNION ALL SELECT 3 
            UNION ALL SELECT 4 
            UNION ALL SELECT 5 
            UNION ALL SELECT 6 
            UNION ALL SELECT 7 
            UNION ALL SELECT 8 
            UNION ALL SELECT 9 
            UNION ALL SELECT 10 
            UNION ALL SELECT 11
        ) numbers
    ) m
-- Join the `work.people` table with the list of dates
    LEFT JOIN work.people p 
-- Condition to include employees who were hired before or on and still employed on or after the date
    ON (p.Hire_date <= m.Date AND (p.End_date IS NULL OR p.End_date >= m.Date)) 
    GROUP BY Location, Year, Month -- Group by location, year, and month
    ORDER BY Location, Year, Month -- Order by location, year, and month
),
-- Create a CTE `Annual_Avg` that calculates the average number of employees for each location based on annual data
Annual_Avg AS (
    SELECT 
        Location,
        AVG(Employee_Count) AS Avg_Employee_Count
    FROM Employee_Months
    GROUP BY Location
)
-- Combine and display data from `Employee_Months` and `Annual_Avg`
SELECT 
    e.Location,
    e.Year,
    e.Month,
    e.Employee_Count, 
    a.Avg_Employee_Count -- Average number of employees
FROM Employee_Months e
JOIN Annual_Avg a 
ON e.Location = a.Location
ORDER BY e.Location, e.Year, e.Month;
