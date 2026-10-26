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
print("STAGE 12: SURVEY DESIGN DIAGNOSTICS")
print("=" * 65)

required = ["anweight", "pspwght", "dweight", "pweight", "stratum", "psu"]

for column in required:
    if column not in df.columns:
        print(f"\n{column}: NOT FOUND")
        continue

    values = df[column]

    print(f"\n{column}")
    print(f"  Data type: {values.dtype}")
    print(f"  Missing values: {values.isna().sum()}")
    print(f"  Distinct non-missing values: {values.nunique(dropna=True)}")

    if pd.api.types.is_numeric_dtype(values):
        print(f"  Minimum: {values.min()}")
        print(f"  Maximum: {values.max()}")

print("\nSTRATUM FREQUENCIES")

if "stratum" in df.columns:
    print(df["stratum"].value_counts(dropna=False).sort_index().to_string())

print("\nPSU FREQUENCIES")

if "psu" in df.columns:
    psu_counts = df["psu"].value_counts(dropna=False)
    print(f"Distinct PSU values: {df['psu'].nunique(dropna=True)}")
    print(f"PSU values appearing once: {(psu_counts == 1).sum()}")
    print(f"PSU values appearing more than once: {(psu_counts > 1).sum()}")

print("\nANALYSIS WEIGHT SUMMARY")

if "anweight" in df.columns:
    weights = pd.to_numeric(df["anweight"], errors="coerce")
    print(weights.describe().to_string())
    print(f"Non-positive weights: {(weights.dropna() <= 0).sum()}")

print("\nNo data have been modified.")
print("No regression has been performed.")