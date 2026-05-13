-- ============================================================
-- 02_kpis.sql
-- KPIs principales sobre clean_admissions (SQLite)
-- ============================================================

-- Filtros opcionales (ajustar valores o dejar NULL para no filtrar)
DROP VIEW IF EXISTS base_kpis;
CREATE TEMP VIEW base_kpis AS
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

-- Total de pacientes únicos
SELECT
    COUNT(DISTINCT Patient_ID) AS total_patients
FROM base_kpis;

-- Costo promedio por internación
SELECT
    ROUND(AVG(Billing_Amount), 2) AS avg_billing_amount
FROM base_kpis;

-- Duración promedio de internación (días)
SELECT
    ROUND(AVG(length_of_stay), 2) AS avg_length_of_stay
FROM base_kpis;

-- Costo total
SELECT
    ROUND(SUM(Billing_Amount), 2) AS total_billing_amount
FROM base_kpis;

-- Porcentaje de admisiones de emergencia
SELECT
    ROUND(
        SUM(CASE WHEN Admission_Type = 'Emergency' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS pct_emergency_admissions
FROM base_kpis;

-- Distribución de resultados de test
SELECT
    Test_Results,
    COUNT(*) AS admissions,
    ROUND(AVG(Billing_Amount), 2) AS avg_billing_amount,
    ROUND(AVG(length_of_stay), 2) AS avg_length_of_stay
FROM base_kpis
GROUP BY Test_Results
ORDER BY admissions DESC;

-- KPIs por tipo de admisión
SELECT
    Admission_Type,
    COUNT(*) AS admissions,
    ROUND(AVG(Billing_Amount), 2) AS avg_billing_amount,
    ROUND(AVG(length_of_stay), 2) AS avg_length_of_stay,
    ROUND(SUM(Billing_Amount), 2) AS total_billing_amount
FROM base_kpis
GROUP BY Admission_Type
ORDER BY admissions DESC;

-- KPIs por hospital
SELECT
    Hospital,
    COUNT(*) AS admissions,
    ROUND(AVG(Billing_Amount), 2) AS avg_billing_amount,
    ROUND(AVG(length_of_stay), 2) AS avg_length_of_stay,
    ROUND(SUM(Billing_Amount), 2) AS total_billing_amount
FROM base_kpis
GROUP BY Hospital
ORDER BY admissions DESC;

-- KPIs por aseguradora
SELECT
    Insurance AS Insurance_Provider,
    COUNT(*) AS admissions,
    ROUND(AVG(Billing_Amount), 2) AS avg_billing_amount,
    ROUND(AVG(length_of_stay), 2) AS avg_length_of_stay,
    ROUND(SUM(Billing_Amount), 2) AS total_billing_amount
FROM base_kpis
GROUP BY Insurance
ORDER BY admissions DESC;
