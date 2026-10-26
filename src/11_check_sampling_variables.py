from pathlib import Path
import pandas as pd

ROOT = Path(__file__).resolve().parent.parent
DATA_PATH = ROOT / "data" / "processed" / "switzerland_cleaned_analysis.csv"

df = pd.read_csv(DATA_PATH)

print("STAGE 15: SAMPLING VARIABLE INSPECTION")
print("=" * 50)
print(f"Swiss respondents: {len(df)}")

variables = [
    "prob",
    "stratum",
    "psu",
    "dweight",
    "pspwght",
    "pweight",
    "anweight",
]

for variable in variables:
    if variable not in df.columns:
        print(f"\n{variable}: NOT FOUND")
        continue

    values = pd.to_numeric(df[variable], errors="coerce")

    print(f"\n{variable}")
    print(f"  Missing: {values.isna().sum()}")
    print(f"  Unique values: {values.nunique(dropna=True)}")

    if values.notna().any():
        print(f"  Minimum: {values.min()}")
        print(f"  Maximum: {values.max()}")

        if variable in ["prob", "stratum", "psu"]:
            print("  First 10 distinct values:")
            print(sorted(values.dropna().unique())[:10])

if all(v in df.columns for v in ["pspwght", "pweight", "anweight"]):
    calculated = (
        pd.to_numeric(df["pspwght"], errors="coerce")
        * pd.to_numeric(df["pweight"], errors="coerce")
    )
    recorded = pd.to_numeric(df["anweight"], errors="coerce")

    difference = (calculated - recorded).abs()

    print("\nWEIGHT CONSISTENCY CHECK")
    print(f"Maximum absolute difference: {difference.max():.10f}")
    print(
        "Matches within tolerance:",
        bool(difference.le(1e-6).all()),
    )

print("\nInspection complete.")
print("No regression was performed.")
print("No source data were modified.")