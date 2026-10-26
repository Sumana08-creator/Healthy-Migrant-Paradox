from pathlib import Path
import pandas as pd

ROOT = Path(__file__).resolve().parent.parent
DATA_PATH = ROOT / "data" / "raw" / "ESS11e04_2-subset.csv"
OUTPUT_DIR = ROOT / "outputs" / "tables"
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

variables = ["agea", "eisced", "eduyrs", "hinctnta", "pspwght", "dweight"]

print("=" * 60)
print("STAGE 4: ADJUSTMENT VARIABLE VALIDATION")
print("=" * 60)

df = pd.read_csv(DATA_PATH, low_memory=False)
swiss = df.loc[df["cntry"] == "CH"].copy()

summary_rows = []
frequency_tables = []

for variable in variables:
    values = pd.to_numeric(swiss[variable], errors="coerce")

    print("\n" + "-" * 50)
    print(f"VARIABLE: {variable}")
    print("-" * 50)
    print(f"Total respondents: {len(values)}")
    print(f"Non-missing values: {values.notna().sum()}")
    print(f"Missing values: {values.isna().sum()}")

    if values.notna().any():
        print(f"Minimum observed value: {values.min()}")
        print(f"Maximum observed value: {values.max()}")
        print(f"Distinct values: {values.nunique()}")

    counts = values.value_counts(dropna=False).sort_index()
    print("\nObserved value frequencies:")
    print(counts.to_string())

    table = counts.rename_axis("observed_value").reset_index(name="frequency")
    table.insert(0, "variable", variable)
    frequency_tables.append(table)

    summary_rows.append({
        "variable": variable,
        "total_respondents": len(values),
        "non_missing_values": int(values.notna().sum()),
        "missing_values": int(values.isna().sum()),
        "minimum_observed": values.min(),
        "maximum_observed": values.max(),
        "distinct_values": int(values.nunique()),
    })

pd.DataFrame(summary_rows).to_csv(
    OUTPUT_DIR / "adjustment_variable_summary.csv",
    index=False
)

pd.concat(frequency_tables, ignore_index=True).to_csv(
    OUTPUT_DIR / "adjustment_variable_frequencies.csv",
    index=False
)

print("\n" + "=" * 60)
print("STAGE 4 VALIDATION COMPLETED")
print("=" * 60)
print("Two output files were saved in outputs/tables.")
print("No special codes have been recoded.")
print("No regression has been performed.")