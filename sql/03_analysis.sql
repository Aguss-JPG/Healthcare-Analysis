-- ============================================================
-- 03_analysis.sql
-- Consultas de análisis e insights (SQLite)
-- ============================================================

-- Filtros opcionales (ajustar valores o dejar NULL para no filtrar)
DROP VIEW IF EXISTS base_analysis;
CREATE TEMP VIEW base_analysis AS
WITH params AS (
    SELECT
        '2024' AS year_filter,
        NULL AS hospital_filter,
        NULL AS insurance_filter
)
SELECT c.*
FROM clean_admissions c
CROSS JOIN params p
WHERE (p.year_filter IS NULL OR strftime('%Y', c.Admission_Date) = p.year_filter)
  AND (p.hospital_filter IS NULL OR c.Hospital = p.hospital_filter)
  AND (p.insurance_filter IS NULL OR c.Insurance = p.insurance_filter);

-- Diagnósticos más frecuentes
SELECT
    Diagnosis,
    COUNT(*) AS admissions
FROM base_analysis
GROUP BY Diagnosis
ORDER BY admissions DESC;

-- Diagnósticos por tipo de admisión
SELECT
    Admission_Type,
    Diagnosis,
    COUNT(*) AS admissions
FROM base_analysis
GROUP BY Admission_Type, Diagnosis
ORDER BY Admission_Type, admissions DESC;

-- Costo promedio por diagnóstico
SELECT
    Diagnosis,
    ROUND(AVG(Billing_Amount), 2) AS avg_billing_amount
FROM base_analysis
GROUP BY Diagnosis
ORDER BY avg_billing_amount DESC;

-- Costo promedio por diagnóstico y tipo de admisión
SELECT
    Admission_Type,
    Diagnosis,
    ROUND(AVG(Billing_Amount), 2) AS avg_billing_amount
FROM base_analysis
GROUP BY Admission_Type, Diagnosis
ORDER BY Admission_Type, avg_billing_amount DESC;

-- Duración promedio por grupo etario
SELECT
    age_group,
    ROUND(AVG(length_of_stay), 2) AS avg_length_of_stay
FROM base_analysis
GROUP BY age_group
ORDER BY avg_length_of_stay DESC;

-- Duración promedio por diagnóstico
SELECT
    Diagnosis,
    ROUND(AVG(length_of_stay), 2) AS avg_length_of_stay
FROM base_analysis
GROUP BY Diagnosis
ORDER BY avg_length_of_stay DESC;

-- Comparación por tipo de admisión
SELECT
    Admission_Type,
    COUNT(*) AS admissions,
    ROUND(AVG(Billing_Amount), 2) AS avg_billing_amount,
    ROUND(AVG(length_of_stay), 2) AS avg_length_of_stay
FROM base_analysis
GROUP BY Admission_Type
ORDER BY admissions DESC;

-- Análisis por hospital (volumen y costo)
SELECT
    Hospital,
    COUNT(*) AS admissions,
    ROUND(SUM(Billing_Amount), 2) AS total_billing_amount,
    ROUND(AVG(Billing_Amount), 2) AS avg_billing_amount
FROM base_analysis
GROUP BY Hospital
ORDER BY admissions DESC;

-- Análisis por aseguradora
SELECT
    Insurance AS Insurance_Provider,
    COUNT(*) AS admissions,
    ROUND(AVG(Billing_Amount), 2) AS avg_billing_amount,
    ROUND(SUM(Billing_Amount), 2) AS total_billing_amount
FROM base_analysis
GROUP BY Insurance
ORDER BY admissions DESC;

-- Resultados de test y costos
SELECT
    Test_Results,
    COUNT(*) AS admissions,
    ROUND(AVG(Billing_Amount), 2) AS avg_billing_amount,
    ROUND(AVG(length_of_stay), 2) AS avg_length_of_stay
FROM base_analysis
GROUP BY Test_Results
ORDER BY admissions DESC;

-- Análisis por médico (volumen y costo)
SELECT
    Doctor,
    COUNT(*) AS admissions,
    ROUND(AVG(Billing_Amount), 2) AS avg_billing_amount,
    ROUND(SUM(Billing_Amount), 2) AS total_billing_amount
FROM base_analysis
GROUP BY Doctor
ORDER BY admissions DESC;

-- Análisis por tipo de sangre
SELECT
    Blood_Type,
    COUNT(*) AS admissions,
    ROUND(AVG(Billing_Amount), 2) AS avg_billing_amount,
    ROUND(AVG(length_of_stay), 2) AS avg_length_of_stay
FROM base_analysis
GROUP BY Blood_Type
ORDER BY admissions DESC;

-- Medicación más frecuente
SELECT
    Medication,
    COUNT(*) AS admissions
FROM base_analysis
GROUP BY Medication
ORDER BY admissions DESC;

-- Tendencia temporal por mes de admisión
SELECT
    strftime('%Y-%m', Admission_Date) AS admission_month,
    COUNT(*) AS admissions,
    ROUND(AVG(Billing_Amount), 2) AS avg_billing_amount,
    ROUND(AVG(length_of_stay), 2) AS avg_length_of_stay
FROM base_analysis
GROUP BY admission_month
ORDER BY admission_month;
