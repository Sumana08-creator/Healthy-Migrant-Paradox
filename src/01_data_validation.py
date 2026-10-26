from pathlib import Path
import pandas as pd

ROOT = Path(__file__).resolve().parent.parent
DATA = ROOT / "data" / "raw" / "ESS11e04_2-subset.csv"
OUT = ROOT / "outputs" / "tables"
OUT.mkdir(parents=True, exist_ok=True)

print("=" * 55)
print("HEALTHY MIGRANT PARADOX: DATA VALIDATION")
print("=" * 55)

if not DATA.exists():
    raise FileNotFoundError(f"Dataset not found: {DATA}")

print("Loading dataset...")
df = pd.read_csv(DATA, low_memory=False)

required = [
    "cntry", "health", "agea", "brncntr", "cntbrthd",
    "facntr", "mocntr", "eisced", "eduyrs", "hinctnta",
    "pspwght", "dweight"
]

missing = [c for c in required if c not in df.columns]
if missing:
    raise ValueError(f"Required columns missing: {missing}")

swiss = df.loc[df["cntry"] == "CH"].copy()
if swiss.empty:
    raise ValueError("No Swiss respondents found.")

print(f"Original observations: {len(df):,}")
print(f"Original variables: {len(df.columns):,}")
print(f"Countries represented: {df['cntry'].nunique()}")
print(f"Swiss respondents: {len(swiss):,}")
print(f"Swiss variables: {len(swiss.columns):,}")

if "idno" in swiss.columns:
    duplicates = int(swiss["idno"].duplicated(keep=False).sum())
    print(f"Rows with repeated respondent IDs: {duplicates:,}")

health = (
    swiss["health"].value_counts(dropna=False).sort_index()
    .rename_axis("response_code")
    .reset_index(name="respondents")
)
health["percentage"] = (
    100 * health["respondents"] / len(swiss)
).round(2)
health.to_csv(OUT / "switzerland_health_response_counts.csv", index=False)

birth = (
    swiss["brncntr"].value_counts(dropna=False).sort_index()
    .rename_axis("response_code")
    .reset_index(name="respondents")
)
birth["percentage"] = (
    100 * birth["respondents"] / len(swiss)
).round(2)
birth.to_csv(OUT / "switzerland_birth_country_response_counts.csv", index=False)

missing_rows = []
for column in required:
    count = int(swiss[column].isna().sum())
    percent = round(100 * count / len(swiss), 2)
    missing_rows.append({
        "variable": column,
        "missing_values": count,
        "total_respondents": len(swiss),
        "missing_percent": percent
    })

pd.DataFrame(missing_rows).to_csv(
    OUT / "switzerland_missingness.csv", index=False
)

swiss.to_csv(OUT / "switzerland_working_data.csv", index=False)

summary = [
    "HEALTHY MIGRANT PARADOX: DATA VALIDATION SUMMARY",
    f"Original observations: {len(df):,}",
    f"Original variables: {len(df.columns):,}",
    f"Swiss respondents: {len(swiss):,}",
    "This is an initial working dataset.",
    "ESS special response codes still require verification.",
    "No inferential analysis has been conducted."
]
(OUT / "data_validation_summary.txt").write_text(
    "\n".join(summary), encoding="utf-8"
)

print()
print("HEALTH RESPONSE CODES")
print(health.to_string(index=False))
print()
print("BORN-IN-COUNTRY RESPONSE CODES")
print(birth.to_string(index=False))
print()
print("MISSING VALUES")
print(pd.DataFrame(missing_rows).to_string(index=False))
print()
print(f"Output directory: {OUT}")
print("DATA VALIDATION COMPLETED SUCCESSFULLY")
