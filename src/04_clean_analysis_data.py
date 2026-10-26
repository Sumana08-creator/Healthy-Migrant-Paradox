from pathlib import Path
import pandas as pd

ROOT = Path(__file__).resolve().parent.parent
DATA_PATH = ROOT / "data" / "raw" / "ESS11e04_2-subset.csv"
OUTPUT_DIR = ROOT / "data" / "processed"
TABLE_DIR = ROOT / "outputs" / "tables"

OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
TABLE_DIR.mkdir(parents=True, exist_ok=True)

print("=" * 60)
print("STAGE 5: CLEANING ANALYSIS VARIABLES")
print("=" * 60)

df = pd.read_csv(DATA_PATH, low_memory=False)
swiss = df.loc[df["cntry"] == "CH"].copy()

print(f"Original Swiss sample: {len(swiss)}")

# Convert the analysis variables to numeric.
variables = [
    "health", "agea", "eisced", "eduyrs", "hinctnta",
    "brncntr", "facntr", "mocntr", "pspwght", "dweight"
]

for variable in variables:
    swiss[variable] = pd.to_numeric(
        swiss[variable], errors="coerce"
    )

# Recode documented special response codes as missing.
missing_codes = {
    "health": [7, 8, 9],
    "agea": [999],
    "eisced": [77, 88, 99],
    "eduyrs": [77, 88, 99],
    "hinctnta": [77, 88, 99],
    "brncntr": [7, 8, 9],
    "facntr": [7, 8, 9],
    "mocntr": [7, 8, 9],
}

for variable, codes in missing_codes.items():
    swiss.loc[swiss[variable].isin(codes), variable] = pd.NA

# Classify respondents using respondent and parental birthplace.
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
    classify_migration, axis=1
)

# Create a documented analytical subset.
analysis_groups = [
    "Non-migrant background",
    "First-generation migrant background",
    "Second-generation migrant background",
]

analysis = swiss.loc[
    swiss["migration_group"].isin(analysis_groups)
].copy()

# Save the cleaned dataset.
clean_path = OUTPUT_DIR / "switzerland_cleaned_analysis.csv"
analysis.to_csv(clean_path, index=False)

# Report missingness after recoding.
check_variables = [
    "health", "agea", "eisced", "eduyrs", "hinctnta",
    "pspwght", "dweight", "migration_group"
]

missingness = pd.DataFrame({
    "variable": check_variables,
    "total_respondents": len(analysis),
    "missing_values": [
        analysis[v].isna().sum() for v in check_variables
    ],
})

missingness["missing_percentage"] = (
    missingness["missing_values"]
    / missingness["total_respondents"] * 100
).round(2)

missingness.to_csv(
    TABLE_DIR / "cleaned_data_missingness.csv",
    index=False
)

group_counts = (
    analysis["migration_group"]
    .value_counts()
    .rename_axis("migration_group")
    .reset_index(name="respondents")
)

group_counts.to_csv(
    TABLE_DIR / "cleaned_migration_group_counts.csv",
    index=False
)

print("\nCLEANED SAMPLE")
print(f"Swiss respondents before group exclusions: {len(swiss)}")
print(f"Respondents in three migration groups: {len(analysis)}")

print("\nMISSINGNESS AFTER RECODING")
print(missingness.to_string(index=False))

print("\nMIGRATION GROUP COUNTS")
print(group_counts.to_string(index=False))

print("\nFiles created:")
print(clean_path)
print(TABLE_DIR / "cleaned_data_missingness.csv")
print(TABLE_DIR / "cleaned_migration_group_counts.csv")

print("\nSTAGE 5 COMPLETED")
print("The original raw dataset was not modified.")
print("No regression has been performed.")