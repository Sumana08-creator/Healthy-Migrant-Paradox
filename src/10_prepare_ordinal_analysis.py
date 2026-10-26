from pathlib import Path
import pandas as pd

ROOT = Path(__file__).resolve().parent.parent

DATA_PATH = (
    ROOT / "data" / "processed"
    / "switzerland_cleaned_analysis.csv"
)

OUTPUT_DIR = ROOT / "outputs" / "tables"
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

df = pd.read_csv(DATA_PATH)

print("=" * 65)
print("STAGE 13: ORDINAL ANALYSIS DATA PREPARATION")
print("=" * 65)

required_columns = [
    "health",
    "migration_group",
    "agea",
    "eisced",
    "hinctnta",
    "anweight",
]

missing_columns = [
    column for column in required_columns
    if column not in df.columns
]

if missing_columns:
    raise ValueError(
        f"Required columns not found: {missing_columns}"
    )

print(f"\nStarting sample: {len(df)} respondents")

health_labels = {
    1: "Very good",
    2: "Good",
    3: "Fair",
    4: "Bad",
    5: "Very bad",
}

print("\nHEALTH CATEGORY COUNTS")

health = pd.to_numeric(df["health"], errors="coerce")

for code, label in health_labels.items():
    count = int((health == code).sum())
    print(f"{code} - {label}: {count}")

print("\nMIGRATION GROUP COUNTS")
print(df["migration_group"].value_counts(dropna=False).to_string())

print("\nMISSINGNESS IN PLANNED VARIABLES")

for column in required_columns:
    missing = df[column].isna().sum()
    percentage = missing / len(df) * 100

    print(
        f"{column}: {missing} missing "
        f"({percentage:.2f}%)"
    )

print("\nANALYSIS WEIGHT CHECK")

weights = pd.to_numeric(df["anweight"], errors="coerce")

print(f"Missing weights: {weights.isna().sum()}")
print(f"Non-positive weights: {(weights.dropna() <= 0).sum()}")

print("\nOUTPUT")

summary = pd.DataFrame({
    "variable": required_columns,
    "total_rows": len(df),
    "missing_count": [
        df[column].isna().sum()
        for column in required_columns
    ],
})

summary["missing_percentage"] = (
    summary["missing_count"] / len(df) * 100
).round(2)

output_path = OUTPUT_DIR / "ordinal_analysis_data_check.csv"
summary.to_csv(output_path, index=False)

print(f"Saved: {output_path}")
print("\nNo regression has been performed.")
print("No source data have been modified.")