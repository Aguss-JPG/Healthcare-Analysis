-- ============================================================
-- 01_data_cleaning.sql
-- Limpieza de datos para hospital_admissions (SQLite)
-- ============================================================

-- Vista limpia con reglas básicas de calidad
DROP VIEW IF EXISTS clean_admissions;

CREATE VIEW clean_admissions AS
SELECT
    Patient_ID,
    Patient_Name,
    Age,
    Gender,
    Blood_Type,
    date(Admission_Date) AS Admission_Date,
    date(Discharge_Date) AS Discharge_Date,
    Diagnosis,
    Doctor,
    Hospital,
    Billing_Amount,
    Admission_Type,
    Insurance,
    Medication,
    Test_Results,
    -- Duración de internación en días
    CAST(julianday(Discharge_Date) - julianday(Admission_Date) AS INTEGER) AS length_of_stay,
    -- Grupo etario para análisis posteriores
    CASE
        WHEN Age < 18 THEN '0-17'
        WHEN Age BETWEEN 18 AND 34 THEN '18-34'
        WHEN Age BETWEEN 35 AND 49 THEN '35-49'
        WHEN Age BETWEEN 50 AND 64 THEN '50-64'
        ELSE '65+'
    END AS age_group
FROM hospital_admissions
WHERE
    Patient_ID IS NOT NULL
    AND Patient_Name IS NOT NULL
    AND Admission_Date IS NOT NULL
    AND Discharge_Date IS NOT NULL
    AND Diagnosis IS NOT NULL
    AND Hospital IS NOT NULL
    AND Billing_Amount IS NOT NULL
    AND Billing_Amount > 0
    AND Age IS NOT NULL
    AND Age >= 0
    AND julianday(Discharge_Date) >= julianday(Admission_Date);

-- Vista de control 
--.SELECT * FROM clean_admissions;
