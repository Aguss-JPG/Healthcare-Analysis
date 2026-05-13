import csv
import os
import sqlite3
import hashlib

BASE_DIR = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
CSV_PATH = os.path.join(BASE_DIR, "data", "raw", "healthcare_dataset.csv")
DB_PATH = os.path.join(BASE_DIR, "database", "health.db")

os.makedirs(os.path.dirname(DB_PATH), exist_ok=True)

schema_sql = """
DROP TABLE IF EXISTS hospital_admissions;

CREATE TABLE hospital_admissions (
    Patient_ID TEXT,
    Patient_Name TEXT,
    Age INTEGER,
    Gender TEXT,
    Blood_Type TEXT,
    Admission_Date TEXT,
    Discharge_Date TEXT,
    Diagnosis TEXT,
    Doctor TEXT,
    Hospital TEXT,
    Billing_Amount REAL,
    Room_Number TEXT,
    Admission_Type TEXT,
    Insurance TEXT,
    Medication TEXT,
    Test_Results TEXT
);
"""

with sqlite3.connect(DB_PATH) as conn:
    conn.executescript(schema_sql)

    with open(CSV_PATH, newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        required_cols = [
            "Name",
            "Age",
            "Gender",
            "Blood Type",
            "Medical Condition",
            "Date of Admission",
            "Doctor",
            "Hospital",
            "Insurance Provider",
            "Billing Amount",
            "Room Number",
            "Admission Type",
            "Discharge Date",
            "Medication",
            "Test Results",
        ]
        if not reader.fieldnames:
            raise ValueError("El CSV no tiene encabezados.")

        missing = [c for c in required_cols if c not in reader.fieldnames]
        if missing:
            raise ValueError(
                "Faltan columnas requeridas en el CSV: " + ", ".join(missing)
            )

        rows = []
        for row in reader:
            name_raw = row["Name"].strip() if row["Name"] else ""
            name = name_raw.title() if name_raw else ""
            age = row["Age"].strip() if row["Age"] else ""
            blood = row["Blood Type"].strip() if row["Blood Type"] else ""
            condition = row["Medical Condition"].strip() if row["Medical Condition"] else ""
            # ID determinístico a partir de atributos disponibles
            raw_id = f"{name}|{age}|{blood}|{condition}".lower()
            patient_id = (
                "P" + hashlib.sha1(raw_id.encode("utf-8")).hexdigest()[:10]
                if raw_id.strip("|")
                else None
            )
            rows.append(
                (
                    patient_id,
                    name or None,
                    int(row["Age"]) if row["Age"] else None,
                    row["Gender"],
                    row["Blood Type"],
                    row["Date of Admission"],
                    row["Discharge Date"],
                    row["Medical Condition"],
                    row["Doctor"],
                    row["Hospital"],
                    float(row["Billing Amount"]) if row["Billing Amount"] else None,
                    row["Room Number"],
                    row["Admission Type"],
                    row["Insurance Provider"],
                    row["Medication"],
                    row["Test Results"],
                )
            )

    conn.executemany(
        """
        INSERT INTO hospital_admissions (
            Patient_ID, Patient_Name, Age, Gender, Blood_Type,
            Admission_Date, Discharge_Date, Diagnosis, Doctor, Hospital,
            Billing_Amount, Room_Number, Admission_Type, Insurance,
            Medication, Test_Results
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """,
        rows,
    )

print(f"Database created at: {DB_PATH}")
