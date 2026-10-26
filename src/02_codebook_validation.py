from pathlib import Path
import pandas as pd

# Project paths
ROOT = Path(__file__).resolve().parent.parent

DATA_PATH = ROOT / "data" / "raw" / "ESS11e04_2-subset.csv"
OUTPUT_DIR = ROOT / "outputs" / "tables"

OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

print("=" * 60)
print("STAGE 2: ESS CODEBOOK VALIDATION")
print("=" * 60)

# Load the original dataset and select Switzerland
df = pd.read_csv(DATA_PATH, low_memory=False)
swiss = df.loc[df["cntry"] == "CH"].copy()

print(f"\nSwiss respondents: {len(swiss):,}")

# Variables to examine
variables = [
    "health",
    "brncntr",
    "facntr",
    "mocntr",
]

# Print and save response-code frequencies
frequency_tables = []

for variable in variables:
    counts = (
        swiss[variable]
        .value_counts(dropna=False)
        .sort_index()
        .rename_axis("response_code")
        .reset_index(name="respondents")
    )

    counts.insert(0, "variable", variable)

    counts["percentage"] = (
        100 * counts["respondents"] / len(swiss)
    ).round(2)

    frequency_tables.append(counts)

    print(f"\n{variable.upper()} RESPONSE COUNTS")
    print(counts.to_string(index=False))

frequencies = pd.concat(
    frequency_tables,
    ignore_index=True,
)

frequencies.to_csv(
    OUTPUT_DIR / "switzerland_codebook_frequencies.csv",
    index=False,
)

# Create a preliminary migration-group classification.
# Codes 7, 8, and 9 are treated as missing for these
# yes/no variables, based on the ESS codebook.
#
# We also treat blank values as missing.
#
# This classification is provisional and will be reviewed.

for variable in ["brncntr", "facntr", "mocntr"]:
    swiss[variable] = pd.to_numeric(
        swiss[variable],
        errors="coerce",
    )

valid_yes_no = [1, 2]

for variable in ["brncntr", "facntr", "mocntr"]:
    swiss.loc[
        ~swiss[variable].isin(valid_yes_no),
        variable,
    ] = pd.NA

def classify_migration(row):
    respondent_birth = row["brncntr"]
    father_birth = row["facntr"]
    mother_birth = row["mocntr"]

    # Respondent born abroad
    if respondent_birth == 2:
        return "First-generation migrant background"

    # Cannot classify parental background if respondent's
    # birthplace is missing or refused.
    if pd.isna(respondent_birth):
        return "Unclassified: respondent birthplace missing"

    # Respondent born in Switzerland
    if respondent_birth == 1:

        # Both parents born in Switzerland
        if father_birth == 1 and mother_birth == 1:
            return "Non-migrant background"

        # At least one parent born outside Switzerland
        if father_birth == 2 or mother_birth == 2:
            return "Second-generation migrant background"

        # Parent information is incomplete
        return "Unclassified: parental birthplace incomplete"

    return "Unclassified"

swiss["migration_group"] = swiss.apply(
    classify_migration,
    axis=1,
)

group_counts = (
    swiss["migration_group"]
    .value_counts(dropna=False)
    .rename_axis("migration_group")
    .reset_index(name="respondents")
)

group_counts["percentage"] = (
    100 * group_counts["respondents"] / len(swiss)
).round(2)

group_counts.to_csv(
    OUTPUT_DIR / "switzerland_migration_group_counts.csv",
    index=False,
)

print("\nPRELIMINARY MIGRATION GROUP COUNTS")
print(group_counts.to_string(index=False))

# Save the preliminary classification separately.
# This is not yet the final cleaned analytical dataset.

swiss.to_csv(
    OUTPUT_DIR / "switzerland_migration_classification.csv",
    index=False,
)

print("\nFILES CREATED")
print(OUTPUT_DIR / "switzerland_codebook_frequencies.csv")
print(OUTPUT_DIR / "switzerland_migration_group_counts.csv")
print(OUTPUT_DIR / "switzerland_migration_classification.csv")

print("\nSTAGE 2 VALIDATION COMPLETED")
print("Review group sizes before proceeding to statistical models.")