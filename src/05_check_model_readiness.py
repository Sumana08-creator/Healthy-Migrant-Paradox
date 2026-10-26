from pathlib import Path
import pandas as pd

ROOT = Path(__file__).resolve().parent.parent
DATA_PATH = ROOT / "data" / "processed" / "switzerland_cleaned_analysis.csv"
OUTPUT_DIR = ROOT / "outputs" / "tables"
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

print("=" * 60)
print("STAGE 6: MODEL READINESS CHECK")
print("=" * 60)

df = pd.read_csv(DATA_PATH)

# Define the outcome and candidate adjustment variables.
base_variables = [
    "health",
    "agea",
    "migration_group",
]

education_variables = [
    "eisced",
    "eduyrs",
]

income_variable = ["hinctnta"]

model_sets = {
    "Model 1: Health and migration group": base_variables,
    "Model 2: Plus age": base_variables,
    "Model 3: Plus age and education level": (
        base_variables + ["eisced"]
    ),
    "Model 4: Plus age and years of education": (
        base_variables + ["eduyrs"]
    ),
    "Model 5: Plus age, education level and income": (
        base_variables + ["eisced", "hinctnta"]
    ),
}

results = []

print(f"\nTotal respondents in cleaned file: {len(df)}")

for model_name, variables in model_sets.items():
    complete = df[variables].notna().all(axis=1)
    n_complete = int(complete.sum())

    results.append({
        "model": model_name,
        "variables": ", ".join(variables),
        "total_respondents": len(df),
        "complete_cases": n_complete,
        "excluded_for_missingness": len(df) - n_complete,
        "complete_case_percentage": round(
            n_complete / len(df) * 100, 2
        ),
    })

    print(f"\n{model_name}")
    print(f"Variables: {', '.join(variables)}")
    print(f"Complete cases: {n_complete}")
    print(f"Excluded for missingness: {len(df) - n_complete}")
    print(
        f"Complete-case percentage: "
        f"{n_complete / len(df) * 100:.2f}%"
    )

results_df = pd.DataFrame(results)
results_df.to_csv(
    OUTPUT_DIR / "model_readiness_summary.csv",
    index=False
)

print("\n" + "=" * 60)
print("MODEL READINESS CHECK COMPLETED")
print("=" * 60)
print(OUTPUT_DIR / "model_readiness_summary.csv")
print("No regression has been performed.")