WITH cte AS (
    SELECT 
        profession, 
        location, 
        AVG(salary) AS avg_salary
    FROM 
        payment 
    GROUP BY 
        profession, location
),
ranked_cte AS (
    SELECT 
        profession, 
        location, 
        avg_salary, 
        RANK() OVER (PARTITION BY location ORDER BY avg_salary DESC) AS salary_rank
    FROM 
        cte
)
SELECT 
    profession,
    MAX(CASE WHEN location = 'SF' THEN salary_rank ELSE NULL END) AS SF,
    MAX(CASE WHEN location = 'LA' THEN salary_rank ELSE NULL END) AS LA,
    MAX(CASE WHEN location = 'CHI' THEN salary_rank ELSE NULL END) AS CHI
FROM 
    ranked_cte
GROUP BY 
    profession
ORDER BY 
    profession ASC;