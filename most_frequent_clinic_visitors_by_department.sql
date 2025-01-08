SELECT 
    department, 
    patient_id, 
    total_visits_by_patient, 
    total_visits_by_department,
    round((total_visits_by_patient / total_visits_by_department) * 100,2) AS percentage_visits
FROM (
    SELECT 
        department, 
        patient_id, 
        SUM(COALESCE(intensive, 0) + COALESCE(weekly, 0)) AS total_visits_by_patient, 
        SUM(SUM(COALESCE(intensive, 0) + COALESCE(weekly, 0))) OVER (PARTITION BY department) AS total_visits_by_department,
        ROW_NUMBER() OVER (PARTITION BY department ORDER BY SUM(COALESCE(intensive, 0) + COALESCE(weekly, 0)) DESC) AS r_w
    FROM work.usa_patients 
    GROUP BY department, patient_id
) AS subquery
WHERE r_w < 10;
