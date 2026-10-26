# STAGE 35: PREPARE AGE-ADJUSTED ORDINAL MODEL DATA
# Data preparation and validation only.
# No regression is performed.
# The original cleaned dataset is not modified.

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
  "anweight"
)

missing_variables <- setdiff(
  required_variables,
  names(data)
)

if (length(missing_variables) > 0) {
  stop(
    paste(
      "Required variables missing:",
      paste(missing_variables, collapse = ", ")
    )
  )
}

data$health <- suppressWarnings(
  as.numeric(as.character(data$health))
)

data$agea <- suppressWarnings(
  as.numeric(as.character(data$agea))
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

model_data <- eligible[
  !is.na(eligible$agea) &
    is.finite(eligible$agea) &
    eligible$agea >= 0,
]

model_data$health_ordered <- ordered(
  model_data$health,
  levels = 1:5,
  labels = c(
    "Very good",
    "Good",
    "Fair",
    "Bad",
    "Very bad"
  )
)

model_data$migration_group <- factor(
  model_data$migration_group,
  levels = valid_groups
)

cat("STAGE 35: AGE-ADJUSTED MODEL DATA PREPARATION\n")
cat("=============================================\n")

cat("\nEligible health/group/weight sample:", nrow(eligible), "\n")
cat("Complete cases for age-adjusted model:", nrow(model_data), "\n")
cat(
  "Excluded because age was missing or invalid:",
  nrow(eligible) - nrow(model_data),
  "\n"
)

cat("\nMigration-group counts:\n")
print(table(model_data$migration_group))

cat("\nHealth-category counts:\n")
print(table(model_data$health_ordered))

cat("\nHealth by migration group:\n")
print(table(
  model_data$migration_group,
  model_data$health_ordered
))

cat("\nAge summary:\n")
print(summary(model_data$agea))

cat("\nWeight summary:\n")
print(summary(model_data$anweight))

cat("\nMissing values in model variables:\n")
print(colSums(is.na(
  model_data[
    c(
      "health_ordered",
      "migration_group",
      "agea",
      "anweight"
    )
  ]
)))

if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}

write.csv(
  data.frame(
    health = model_data$health,
    health_ordered = as.character(model_data$health_ordered),
    migration_group = as.character(model_data$migration_group),
    agea = model_data$agea,
    anweight = model_data$anweight
  ),
  file.path(
    output_dir,
    "stage35_age_adjusted_model_sample.csv"
  ),
  row.names = FALSE
)

cat("\nSUCCESS: Stage 35 data preparation completed.\n")
cat("Prepared sample saved to outputs/tables/stage35_age_adjusted_model_sample.csv\n")
cat("No regression was performed.\n")
cat("The original cleaned dataset was not modified.\n")