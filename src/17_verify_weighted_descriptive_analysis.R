# STAGE 25: INDEPENDENT VERIFICATION OF WEIGHTED DESCRIPTIVES
# Independently calculate weighted health percentages from cleaned data.
# Compare them with Stage 24 results.
# No regression is performed. Source data are not modified.

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

stage24_path <- file.path(
  project_root,
  "outputs",
  "tables",
  "weighted_health_by_migration.csv"
)

verification_path <- file.path(
  project_root,
  "outputs",
  "tables",
  "stage25_verification.csv"
)

if (!file.exists(data_path)) {
  stop("ERROR: Cleaned dataset not found.")
}

if (!file.exists(stage24_path)) {
  stop("ERROR: Stage 24 output not found.")
}

# Load the original cleaned analysis data and Stage 24 output.
data <- read.csv(data_path, stringsAsFactors = FALSE)
stage24 <- read.csv(stage24_path, stringsAsFactors = FALSE)

# Check required columns.
required_data <- c("health", "migration_group", "anweight")
required_stage24 <- c(
  "migration_group",
  "health_code",
  "weighted_percentage"
)

if (!all(required_data %in% names(data))) {
  stop("ERROR: Required variables are missing from the cleaned dataset.")
}

if (!all(required_stage24 %in% names(stage24))) {
  stop("ERROR: Required columns are missing from Stage 24 output.")
}

# Convert variables explicitly.
data$health <- suppressWarnings(as.numeric(as.character(data$health)))
data$anweight <- suppressWarnings(as.numeric(as.character(data$anweight)))
data$migration_group <- trimws(as.character(data$migration_group))

groups <- c(
  "Non-migrant background",
  "First-generation migrant background",
  "Second-generation migrant background"
)

health_labels <- c(
  "Very good",
  "Good",
  "Fair",
  "Bad",
  "Very bad"
)

# Independently apply the same documented eligibility rules.
eligible <- data[
  !is.na(data$health) &
    data$health %in% 1:5 &
    !is.na(data$migration_group) &
    data$migration_group %in% groups &
    !is.na(data$anweight) &
    is.finite(data$anweight) &
    data$anweight > 0,
]

cat("STAGE 25: INDEPENDENT VERIFICATION\n")
cat("==================================\n")
cat("Rows in cleaned dataset:", nrow(data), "\n")
cat("Eligible respondents:", nrow(eligible), "\n")

# Calculate weighted percentages directly using sums of weights.
independent_results <- data.frame()

for (group_name in groups) {

  group_data <- eligible[
    eligible$migration_group == group_name,
  ]

  if (nrow(group_data) == 0) {
    stop(paste("ERROR: No eligible respondents for", group_name))
  }

  total_weight <- sum(group_data$anweight)

  for (health_code in 1:5) {

    category_data <- group_data[
      group_data$health == health_code,
    ]

    category_weight <- sum(category_data$anweight)

    independent_percentage <- 100 * category_weight / total_weight

    independent_results <- rbind(
      independent_results,
      data.frame(
        migration_group = group_name,
        health_code = health_code,
        health_category = health_labels[health_code],
        respondent_count = nrow(category_data),
        weighted_count = category_weight,
        independently_calculated_percentage = independent_percentage
      )
    )
  }
}

# Match the independent calculations to Stage 24.
comparison <- merge(
  independent_results,
  stage24[
    ,
    c("migration_group", "health_code", "weighted_percentage")
  ],
  by = c("migration_group", "health_code"),
  all = TRUE
)

comparison$difference_percentage_points <-
  comparison$independently_calculated_percentage -
  comparison$weighted_percentage

# Check for missing matches and discrepancies.
if (anyNA(comparison$independently_calculated_percentage) ||
    anyNA(comparison$weighted_percentage)) {
  stop("ERROR: Some health categories did not match between the two outputs.")
}

max_difference <- max(
  abs(comparison$difference_percentage_points)
)

cat("\nIndependent calculation versus Stage 24:\n")

print(
  comparison[
    order(comparison$migration_group, comparison$health_code),
    c(
      "migration_group",
      "health_category",
      "respondent_count",
      "independently_calculated_percentage",
      "weighted_percentage",
      "difference_percentage_points"
    )
  ],
  row.names = FALSE
)

cat("\nMaximum absolute difference in percentage points:",
    format(max_difference, digits = 10), "\n")

# Verify that independent percentages total 100% within each group.
group_totals <- aggregate(
  independently_calculated_percentage ~ migration_group,
  data = independent_results,
  FUN = sum
)

cat("\nIndependent percentage totals by group:\n")
print(group_totals, row.names = FALSE)

if (any(abs(group_totals$independently_calculated_percentage - 100) > 0.000001)) {
  stop("ERROR: Independently calculated percentages do not total 100%.")
}

# Save the detailed comparison.
if (!dir.exists(dirname(verification_path))) {
  dir.create(dirname(verification_path), recursive = TRUE)
}

write.csv(
  comparison,
  verification_path,
  row.names = FALSE
)

if (max_difference > 0.000001) {
  cat("\nWARNING: Stage 24 and independent calculations differ.\n")
  cat("Investigate the discrepancy before proceeding.\n")
} else {
  cat("\nSUCCESS: Stage 24 percentages independently verified.\n")
}

cat("Verification output saved to:\n")
cat(verification_path, "\n")

cat("\nNo regression was performed.\n")
cat("The cleaned source dataset was not modified.\n")