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

print("=" * 60)
print("STAGE 11: SURVEY DESIGN VARIABLE INSPECTION")
print("=" * 60)

print(f"\nNumber of respondents: {len(df)}")
print(f"Number of variables: {len(df.columns)}")

keywords = [
    "strat",
    "cluster",
    "psu",
    "primary",
    "sample",
    "weight",
    "cntry",
]

matches = [
    column
    for column in df.columns
    if any(keyword in column.lower() for keyword in keywords)
]

print("\nPOTENTIALLY RELEVANT SURVEY VARIABLES")

for column in matches:
    print(
        f"{column}: "
        f"{df[column].nunique(dropna=True)} distinct non-missing values"
    )

print("\nWEIGHT VARIABLES")

for column in ["pspwght", "dweight", "pweight"]:
    if column in df.columns:
        values = pd.to_numeric(df[column], errors="coerce")
        print(
            f"{column}: present; "
            f"missing={values.isna().sum()}; "
            f"unique={values.nunique(dropna=True)}"
        )
    else:
        print(f"{column}: not present")

print("\nNo data have been modified.")
print("No regression has been performed.")