# STAGE 34: ORDINAL OUTCOME STABILITY AUDIT
# Descriptive checks only.
# No regression is performed.
# No source data are modified.

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

eligible <- data[
  !is.na(data$health) &
    data$health %in% 1:5 &
    !is.na(data$migration_group) &
    data$migration_group %in% valid_groups &
    !is.na(data$anweight) &
    is.finite(data$anweight) &
    data$anweight > 0,
]

health_labels <- c(
  "Very good",
  "Good",
  "Fair",
  "Bad",
  "Very bad"
)

eligible$health_label <- factor(
  eligible$health,
  levels = 1:5,
  labels = health_labels,
  ordered = TRUE
)

eligible$migration_group <- factor(
  eligible$migration_group,
  levels = valid_groups
)

cat("STAGE 34: ORDINAL OUTCOME STABILITY AUDIT\n")
cat("=========================================\n")

cat("\nEligible respondents:", nrow(eligible), "\n")

cat("\nOverall health-category counts:\n")

overall_counts <- table(
  factor(
    eligible$health_label,
    levels = health_labels
  )
)

print(overall_counts)

cat("\nHealth-category percentages:\n")

print(
  round(
    100 * prop.table(overall_counts),
    2
  )
)

cat("\nHealth counts by migration group:\n")

group_counts <- table(
  eligible$migration_group,
  eligible$health_label
)

print(group_counts)

cat("\nHealth percentages within migration group:\n")

print(
  round(
    100 * prop.table(group_counts, margin = 1),
    2
  )
)

cat("\nEmpty health categories by migration group:\n")

print(group_counts == 0)

cat("\nCategories with fewer than 10 observations overall:\n")

print(overall_counts[overall_counts < 10])

cat("\nInterpretation notes:\n")
cat("- Sparse categories can cause unstable model estimates.\n")
cat("- Empty group-category cells may complicate estimation.\n")
cat("- These counts do not, by themselves, establish model failure.\n")
cat("- No categories were combined in this stage.\n")

if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}

write.csv(
  as.data.frame.matrix(group_counts),
  file.path(
    output_dir,
    "stage34_health_counts_by_migration.csv"
  )
)

report_path <- file.path(
  output_dir,
  "stage34_ordinal_outcome_stability.txt"
)

sink(report_path)

cat("STAGE 34: ORDINAL OUTCOME STABILITY AUDIT\n")
cat("=========================================\n")
cat("Eligible respondents:", nrow(eligible), "\n")

cat("\nOverall health-category counts:\n")
print(overall_counts)

cat("\nHealth counts by migration group:\n")
print(group_counts)

cat("\nHealth percentages within migration group:\n")
print(round(100 * prop.table(group_counts, margin = 1), 2))

cat("\nEmpty health categories by migration group:\n")
print(group_counts == 0)

cat("\nCategories with fewer than 10 observations overall:\n")
print(overall_counts[overall_counts < 10])

cat("\nNo regression was performed.\n")
cat("No source data were modified.\n")

sink()

cat("\nSUCCESS: Stage 34 completed.\n")
cat("Counts saved to outputs/tables/stage34_health_counts_by_migration.csv\n")
cat("Report saved to outputs/tables/stage34_ordinal_outcome_stability.txt\n")
cat("No source data were modified.\n")