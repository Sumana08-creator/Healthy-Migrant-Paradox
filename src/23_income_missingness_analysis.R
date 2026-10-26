# STAGE 31: INCOME MISSINGNESS ANALYSIS
# Compare respondents with observed and missing income.
# Descriptive analysis only; no regression or imputation.
# Source data are not modified.

script_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
if (length(script_arg) > 0) {
  script_path <- normalizePath(sub("^--file=", "", script_arg[1]), winslash = "/", mustWork = TRUE)
  project_root <- dirname(dirname(script_path))
} else {
  project_root <- normalizePath(".", winslash = "/", mustWork = TRUE)
}
data_path <- file.path(
  project_root,
  "data",
  "processed",
  "switzerland_cleaned_analysis.csv"
)

output_dir <- file.path(
  project_root,
  "outputs",
  "tables"
)

if (!file.exists(data_path)) {
  stop("ERROR: Cleaned dataset not found.")
}

data <- read.csv(
  data_path,
  stringsAsFactors = FALSE
)

required_variables <- c(
  "health",
  "migration_group",
  "agea",
  "eisced",
  "hinctnta",
  "anweight"
)

missing_variables <- setdiff(
  required_variables,
  names(data)
)

if (length(missing_variables) > 0) {
  stop(
    paste(
      "Required variables not found:",
      paste(missing_variables, collapse = ", ")
    )
  )
}

# Convert key variables safely.
data$health <- suppressWarnings(as.numeric(as.character(data$health)))
data$agea <- suppressWarnings(as.numeric(as.character(data$agea)))
data$eisced <- suppressWarnings(as.numeric(as.character(data$eisced)))
data$hinctnta <- suppressWarnings(as.numeric(as.character(data$hinctnta)))
data$anweight <- suppressWarnings(as.numeric(as.character(data$anweight)))

data$migration_group <- trimws(
  as.character(data$migration_group)
)

valid_groups <- c(
  "Non-migrant background",
  "First-generation migrant background",
  "Second-generation migrant background"
)

# Use the established eligible health/migration/weight sample.
eligible <- data[
  !is.na(data$health) &
    data$health %in% 1:5 &
    !is.na(data$migration_group) &
    data$migration_group %in% valid_groups &
    !is.na(data$anweight) &
    is.finite(data$anweight) &
    data$anweight > 0,
]

# Group respondents by whether household income is missing.
eligible$income_status <- ifelse(
  is.na(eligible$hinctnta),
  "Income missing",
  "Income observed"
)

cat("STAGE 31: INCOME MISSINGNESS ANALYSIS\n")
cat("=====================================\n")
cat("Eligible respondents:", nrow(eligible), "\n")

cat("\nIncome availability:\n")
print(table(eligible$income_status))

cat("\nIncome availability by migration group:\n")
print(
  prop.table(
    table(
      eligible$migration_group,
      eligible$income_status
    ),
    margin = 1
  ) * 100
)

cat("\nMean age by income availability:\n")
print(
  aggregate(
    agea ~ income_status,
    data = eligible,
    FUN = function(x) mean(x, na.rm = TRUE)
  )
)

cat("\nHealth distribution by income availability (row percentages):\n")

health_distribution <- prop.table(
  table(
    eligible$income_status,
    factor(
      eligible$health,
      levels = 1:5,
      labels = c(
        "Very good",
        "Good",
        "Fair",
        "Bad",
        "Very bad"
      )
    )
  ),
  margin = 1
) * 100

print(round(health_distribution, 2))

cat("\nEducation-category distribution by income availability:\n")

education_distribution <- prop.table(
  table(
    eligible$income_status,
    eligible$eisced,
    useNA = "ifany"
  ),
  margin = 1
) * 100

print(round(education_distribution, 2))

# Save a simple missingness summary.
missingness_summary <- data.frame(
  income_status = c("Income observed", "Income missing"),
  respondents = as.integer(
    table(
      factor(
        eligible$income_status,
        levels = c("Income observed", "Income missing")
      )
    )
  ),
  stringsAsFactors = FALSE
)

missingness_summary$percentage <- (
  100 * missingness_summary$respondents / nrow(eligible)
)

if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}

write.csv(
  missingness_summary,
  file.path(output_dir, "stage31_income_missingness_summary.csv"),
  row.names = FALSE
)

cat("\nSUCCESS: Income missingness analysis completed.\n")
cat("Summary saved to outputs/tables/stage31_income_missingness_summary.csv\n")
cat("\nNo regression was performed.\n")
cat("No source data were modified.\n")