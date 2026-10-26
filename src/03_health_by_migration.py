from pathlib import Path
import pandas as pd

# Project paths
ROOT = Path(__file__).resolve().parent.parent
DATA_PATH = ROOT / "data" / "raw" / "ESS11e04_2-subset.csv"
OUTPUT_DIR = ROOT / "outputs" / "tables"

OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

print("=" * 65)
print("STAGE 3: DESCRIPTIVE HEALTH ANALYSIS")
print("=" * 65)

# Load data
df = pd.read_csv(DATA_PATH, low_memory=False)

# Select Switzerland
swiss = df.loc[df["cntry"] == "CH"].copy()

# Convert relevant variables to numeric
variables = ["health", "brncntr", "facntr", "mocntr"]

for variable in variables:
    swiss[variable] = pd.to_numeric(
        swiss[variable],
        errors="coerce",
    )

# Recode special response codes as missing.
# These codes follow the ESS codebook for these variables.

swiss.loc[~swiss["health"].isin([1, 2, 3, 4, 5]), "health"] = pd.NA

for variable in ["brncntr", "facntr", "mocntr"]:
    swiss.loc[~swiss[variable].isin([1, 2]), variable] = pd.NA

# Define preliminary migration groups
def classify_migration(row):
    respondent = row["brncntr"]
    father = row["facntr"]
    mother = row["mocntr"]

    if respondent == 2:
        return "First-generation migrant background"

    if pd.isna(respondent):
        return "Unclassified"

    if respondent == 1:
        if father == 1 and mother == 1:
            return "Non-migrant background"

        if father == 2 or mother == 2:
            return "Second-generation migrant background"

    return "Unclassified"


swiss["migration_group"] = swiss.apply(
    classify_migration,
    axis=1,
)

# Keep classifiable migration groups for this comparison
analysis_groups = [
    "Non-migrant background",
    "First-generation migrant background",
    "Second-generation migrant background",
]

analysis = swiss.loc[
    swiss["migration_group"].isin(analysis_groups)
].copy()

# Save the number of valid health observations by group
health_availability = (
    analysis.groupby("migration_group", observed=True)["health"]
    .agg(
        total_respondents="size",
        valid_health_responses="count",
    )
    .reset_index()
)

health_availability["missing_health_responses"] = (
    health_availability["total_respondents"]
    - health_availability["valid_health_responses"]
)

health_availability.to_csv(
    OUTPUT_DIR / "health_data_availability_by_migration.csv",
    index=False,
)

print("\nHEALTH DATA AVAILABILITY")
print(health_availability.to_string(index=False))

# Count health responses within each migration group
health_counts = pd.crosstab(
    analysis["migration_group"],
    analysis["health"],
    dropna=False,
)

# Ensure all five valid categories appear
health_counts = health_counts.reindex(
    columns=[1, 2, 3, 4, 5],
    fill_value=0,
)

health_counts.columns = [
    "Very good",
    "Good",
    "Fair",
    "Bad",
    "Very bad",
]

health_counts.to_csv(
    OUTPUT_DIR / "health_counts_by_migration.csv"
)

print("\nHEALTH COUNTS BY MIGRATION GROUP")
print(health_counts.to_string())

# Calculate percentages within each migration group
health_percentages = health_counts.div(
    health_counts.sum(axis=1).replace(0, pd.NA),
    axis=0,
) * 100

health_percentages = health_percentages.round(2)

health_percentages.to_csv(
    OUTPUT_DIR / "health_percentages_by_migration.csv"
)

print("\nHEALTH PERCENTAGES WITHIN EACH MIGRATION GROUP")
print(health_percentages.to_string())

print("\nOUTPUT FILES")
print(OUTPUT_DIR / "health_data_availability_by_migration.csv")
print(OUTPUT_DIR / "health_counts_by_migration.csv")
print(OUTPUT_DIR / "health_percentages_by_migration.csv")

print("\nSTAGE 3 DESCRIPTIVE ANALYSIS COMPLETED")
print("These are unweighted descriptive results.")
print("No regression or causal analysis has been conducted.")