# STAGE 30: COVARIATE MISSINGNESS AND MODEL READINESS AUDIT
# Read-only analysis. No regression is performed.
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

output_path <- file.path(
  output_dir,
  "stage30_missingness_audit.csv"
)

if (!file.exists(data_path)) {
  stop("ERROR: Cleaned analysis dataset not found.")
}

data <- read.csv(
  data_path,
  stringsAsFactors = FALSE
)

cat("STAGE 30: COVARIATE MISSINGNESS AUDIT\n")
cat("=====================================\n")
cat("Rows in cleaned dataset:", nrow(data), "\n")

# Verify the variables needed for the planned models.
variables <- c(
  "health",
  "migration_group",
  "agea",
  "eisced",
  "eduyrs",
  "hinctnta",
  "anweight"
)

missing_variables <- setdiff(
  variables,
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

# Identify the analysis-eligible sample using the established
# health, migration-group and weight criteria.
data$health <- suppressWarnings(
  as.numeric(as.character(data$health))
)

data$anweight <- suppressWarnings(
  as.numeric(as.character(data$anweight))
)

data$migration_group <- trimws(
  as.character(data$migration_group)
)

valid_groups <- c(
  "Non-migrant background",
  "First-generation migrant background",
  "Second-generation migrant background"
)

eligible <- !is.na(data$health) &
  data$health %in% 1:5 &
  !is.na(data$migration_group) &
  data$migration_group %in% valid_groups &
  !is.na(data$anweight) &
  is.finite(data$anweight) &
  data$anweight > 0

cat("Health/group/weight-eligible respondents:", sum(eligible), "\n")

# These variables were cleaned in Stage 4.
# Inspect missingness as recorded in the cleaned dataset.
audit_variables <- c(
  "health",
  "migration_group",
  "agea",
  "eisced",
  "eduyrs",
  "hinctnta",
  "anweight"
)

audit_results <- data.frame()

for (variable in audit_variables) {

  values <- data[[variable]]

  missing_count <- sum(is.na(values))

  audit_results <- rbind(
    audit_results,
    data.frame(
      variable = variable,
      total_rows = nrow(data),
      missing_count = missing_count,
      missing_percentage = 100 * missing_count / nrow(data),
      complete_rows = sum(!is.na(values)),
      stringsAsFactors = FALSE
    )
  )
}

cat("\nMissingness across the cleaned dataset:\n")
print(audit_results, row.names = FALSE)

# Calculate sample sizes for planned complete-case models.
model_variables <- list(
  Model_1 = c("health", "migration_group", "anweight"),
  Model_2_age = c("health", "migration_group", "agea", "anweight"),
  Model_3_education = c(
    "health", "migration_group", "agea", "eisced", "anweight"
  ),
  Model_4_years_education = c(
    "health", "migration_group", "agea", "eduyrs", "anweight"
  ),
  Model_5_income = c(
    "health", "migration_group", "agea", "eisced", "hinctnta", "anweight"
  )
)

sample_results <- data.frame()

for (model_name in names(model_variables)) {

  selected_variables <- model_variables[[model_name]]

  complete <- complete.cases(
    data[eligible, selected_variables, drop = FALSE]
  )

  included <- sum(complete)

  sample_results <- rbind(
    sample_results,
    data.frame(
      model = model_name,
      eligible_sample = sum(eligible),
      complete_case_sample = included,
      excluded_from_eligible = sum(eligible) - included,
      percentage_retained = 100 * included / sum(eligible),
      stringsAsFactors = FALSE
    )
  )
}

cat("\nComplete-case sample sizes:\n")
print(sample_results, row.names = FALSE)

if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}

write.csv(
  audit_results,
  output_path,
  row.names = FALSE
)

sample_output_path <- file.path(
  output_dir,
  "stage30_model_sample_sizes.csv"
)

write.csv(
  sample_results,
  sample_output_path,
  row.names = FALSE
)

cat("\nMissingness report saved to:\n")
cat(output_path, "\n")

cat("\nModel sample-size report saved to:\n")
cat(sample_output_path, "\n")

cat("\nNo regression was performed.\n")
cat("No source data were modified.\n")