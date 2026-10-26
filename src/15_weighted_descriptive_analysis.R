# STAGE 24: WEIGHTED DESCRIPTIVE ANALYSIS
# All five health categories are retained for every migration group.

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

output_dir <- file.path(project_root, "outputs", "tables")

output_path <- file.path(
  output_dir,
  "weighted_health_by_migration.csv"
)

if (!file.exists(data_path)) {
  stop("ERROR: Cleaned analysis dataset was not found.")
}

data <- read.csv(
  data_path,
  stringsAsFactors = FALSE
)

cat("STAGE 24: WEIGHTED DESCRIPTIVE ANALYSIS\n")
cat("=======================================\n")
cat("Rows in cleaned dataset:", nrow(data), "\n")

required_variables <- c(
  "health",
  "migration_group",
  "anweight"
)

missing_variables <- setdiff(required_variables, names(data))

if (length(missing_variables) > 0) {
  stop(
    paste(
      "Missing variables:",
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

health_labels <- c(
  "Very good",
  "Good",
  "Fair",
  "Bad",
  "Very bad"
)

analysis_data <- data[
  !is.na(data$health) &
    data$health %in% 1:5 &
    !is.na(data$migration_group) &
    data$migration_group %in% valid_groups &
    !is.na(data$anweight) &
    is.finite(data$anweight) &
    data$anweight > 0,
]

cat("Valid respondents included:", nrow(analysis_data), "\n")
cat("Respondents excluded:", nrow(data) - nrow(analysis_data), "\n")

if (nrow(analysis_data) == 0) {
  stop("ERROR: No valid respondents remain after filtering.")
}

analysis_data$migration_group <- factor(
  analysis_data$migration_group,
  levels = valid_groups
)

analysis_data$health_factor <- factor(
  analysis_data$health,
  levels = 1:5,
  labels = health_labels
)

library(survey)

# Provisional design for descriptive weighted estimates.
# Variance-estimation design still requires methodological verification.
survey_design <- svydesign(
  ids = ~1,
  weights = ~anweight,
  data = analysis_data
)

results <- list()
result_index <- 1

for (group_name in valid_groups) {

  group_data <- analysis_data[
    analysis_data$migration_group == group_name,
  ]

  group_design <- subset(
    survey_design,
    migration_group == group_name
  )

  # Explicitly preserve all five categories, including zero-count categories.
  unweighted_counts <- as.integer(
    table(
      factor(
        group_data$health,
        levels = 1:5
      )
    )
  )

  weighted_table <- svytable(
    ~health_factor,
    design = group_design
  )

  # Match weighted counts to the five categories by their labels.
  weighted_counts <- as.numeric(
    weighted_table[health_labels]
  )

  # Treat absent categories as zero, not missing.
  weighted_counts[is.na(weighted_counts)] <- 0

  total_unweighted <- nrow(group_data)
  total_weighted <- sum(weighted_counts)

  if (total_unweighted == 0 || total_weighted <= 0) {
    stop(paste("Invalid totals for group:", group_name))
  }

  group_results <- data.frame(
    migration_group = rep(group_name, 5),
    health_code = 1:5,
    health_category = health_labels,
    unweighted_count = unweighted_counts,
    weighted_count = weighted_counts,
    weighted_percentage =
      100 * weighted_counts / total_weighted,
    unweighted_percentage =
      100 * unweighted_counts / total_unweighted,
    stringsAsFactors = FALSE
  )

  results[[result_index]] <- group_results
  result_index <- result_index + 1
}

final_results <- do.call(rbind, results)

percentage_checks <- aggregate(
  weighted_percentage ~ migration_group,
  data = final_results,
  FUN = sum
)

cat("\nWeighted percentage totals by migration group:\n")
print(percentage_checks)

if (any(abs(percentage_checks$weighted_percentage - 100) > 0.01)) {
  stop("ERROR: Weighted percentages do not total approximately 100%.")
}

if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}

write.csv(
  final_results,
  output_path,
  row.names = FALSE
)

cat("\nUnweighted respondent totals by group:\n")
print(
  aggregate(
    unweighted_count ~ migration_group,
    data = final_results,
    FUN = sum
  )
)

cat("\nWeighted health distribution:\n")

print(
  final_results[
    ,
    c(
      "migration_group",
      "health_category",
      "unweighted_count",
      "weighted_count",
      "weighted_percentage"
    )
  ],
  row.names = FALSE
)

cat("\nSUCCESS: Weighted descriptive analysis completed.\n")
cat("Output saved to:\n")
cat(output_path, "\n")

cat("\nResearch notes:\n")
cat("- This is a descriptive analysis, not a regression.\n")
cat("- The cleaned source dataset was not modified.\n")
cat("- The survey design used for variance estimation remains provisional.\n")