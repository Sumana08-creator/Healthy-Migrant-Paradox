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
print("STAGE 7: HEALTH OUTCOME ASSESSMENT")
print("=" * 60)

df = pd.read_csv(DATA_PATH)

health_labels = {
    1: "Very good",
    2: "Good",
    3: "Fair",
    4: "Bad",
    5: "Very bad",
}

df["health"] = pd.to_numeric(df["health"], errors="coerce")

counts = (
    df["health"]
    .value_counts()
    .reindex([1, 2, 3, 4, 5], fill_value=0)
)

results = pd.DataFrame({
    "health_code": counts.index,
    "health_category": [
        health_labels[int(code)] for code in counts.index
    ],
    "respondents": counts.values,
})

results["percentage_of_valid_health_responses"] = (
    results["respondents"]
    / results["respondents"].sum() * 100
).round(2)

print(f"\nTotal respondents: {len(df)}")
print(f"Valid health responses: {df['health'].notna().sum()}")
print(f"Missing health responses: {df['health'].isna().sum()}")

print("\nHEALTH DISTRIBUTION")
print(results.to_string(index=False))

results.to_csv(
    OUTPUT_DIR / "health_outcome_assessment.csv",
    index=False
)

print("\nSaved:")
print(OUTPUT_DIR / "health_outcome_assessment.csv")

print("\nNo regression has been performed.")