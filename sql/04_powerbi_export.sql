WITH ranked AS (
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
        CAST(julianday(Discharge_Date) - julianday(Admission_Date) AS INTEGER) AS length_of_stay,
        CASE
            WHEN Age < 18 THEN '0-17'
            WHEN Age BETWEEN 18 AND 34 THEN '18-34'
            WHEN Age BETWEEN 35 AND 49 THEN '35-49'
            WHEN Age BETWEEN 50 AND 64 THEN '50-64'
            ELSE '65+'
        END AS age_group,
        ROW_NUMBER() OVER (
            PARTITION BY Patient_ID, Admission_Date, Discharge_Date
            ORDER BY rowid
        ) AS rn
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
        AND julianday(Discharge_Date) >= julianday(Admission_Date)
)
SELECT
    Patient_ID,
    Patient_Name,
    Age,
    Gender,
    Blood_Type,
    Admission_Date,
    Discharge_Date,
    Diagnosis,
    Doctor,
    Hospital,
    REPLACE(printf('%.2f', ROUND(Billing_Amount, 2)), '.', ',') AS Billing_Amount,
    Admission_Type,
    Insurance,
    Medication,
    Test_Results,
    length_of_stay,
    age_group
FROM ranked
WHERE rn = 1;
