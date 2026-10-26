from pathlib import Path
import pandas as pd

ROOT = Path(__file__).resolve().parent.parent

DATA_PATH = (
    ROOT / "data" / "processed"
    / "switzerland_cleaned_analysis.csv"
)

OUTPUT_DIR = ROOT / "outputs" / "tables"
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

print("=" * 60)
print("STAGE 8: SURVEY WEIGHT ASSESSMENT")
print("=" * 60)

df = pd.read_csv(DATA_PATH)

weight_columns = ["pspwght", "dweight"]

results = []

for column in weight_columns:
    values = pd.to_numeric(df[column], errors="coerce")
    valid = values.dropna()

    results.append({
        "variable": column,
        "total_observations": len(values),
        "valid_observations": len(valid),
        "missing_observations": int(values.isna().sum()),
        "minimum": valid.min(),
        "maximum": valid.max(),
        "mean": valid.mean(),
        "standard_deviation": valid.std(),
        "sum": valid.sum(),
        "unique_values": valid.nunique(),
        "non_positive_values": int((valid <= 0).sum()),
    })

summary = pd.DataFrame(results)

print("\nWEIGHT SUMMARY")
print(summary.to_string(index=False))

print("\nPOST-STRATIFICATION WEIGHT BY MIGRATION GROUP")

group_summary = (
    df.groupby("migration_group", observed=True)["pspwght"]
    .agg(["count", "mean", "std", "min", "max", "sum"])
    .reset_index()
)

print(group_summary.to_string(index=False))

summary.to_csv(
    OUTPUT_DIR / "survey_weight_summary.csv",
    index=False
)

group_summary.to_csv(
    OUTPUT_DIR / "survey_weight_by_migration_group.csv",
    index=False
)

print("\nSaved:")
print(OUTPUT_DIR / "survey_weight_summary.csv")
print(OUTPUT_DIR / "survey_weight_by_migration_group.csv")

print("\nNo regression has been performed.")
print("Weight summaries alone do not establish the correct survey design.")