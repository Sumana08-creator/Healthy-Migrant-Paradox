# STAGE 28: PROPORTIONAL-ODDS ASSUMPTION DIAGNOSTIC
#
# Compare a proportional-odds model with a model that allows
# predictor effects to vary across cumulative outcome thresholds.
#
# This is a diagnostic comparison, not the final survey-weighted
# inferential analysis. The variance design remains provisional.

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
  "stage28_proportional_odds_diagnostic.txt"
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

if (!all(required_variables %in% names(data))) {
  stop("ERROR: Required variables are missing.")
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

group_levels <- c(
  "Non-migrant background",
  "First-generation migrant background",
  "Second-generation migrant background"
)

model_data <- data[
  !is.na(data$health) &
    data$health %in% 1:5 &
    !is.na(data$migration_group) &
    data$migration_group %in% group_levels &
    !is.na(data$anweight) &
    is.finite(data$anweight) &
    data$anweight > 0,
]

model_data$migration_group <- factor(
  model_data$migration_group,
  levels = group_levels
)

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

cat("STAGE 28: PROPORTIONAL-ODDS DIAGNOSTIC\n")
cat("======================================\n")
cat("Eligible respondents:", nrow(model_data), "\n")

cat("\nHealth category counts:\n")
print(table(model_data$health_ordered))

cat("\nHealth distribution by migration group:\n")
print(table(
  model_data$migration_group,
  model_data$health_ordered
))

# Install nothing automatically. Check required packages.
if (!requireNamespace("ordinal", quietly = TRUE)) {
  stop(
    "The 'ordinal' package is not installed. ",
    "Install it in a separate step before running this diagnostic."
  )
}

# Fit a proportional-odds model using clm.
proportional_model <- tryCatch(
  ordinal::clm(
    health_ordered ~ migration_group,
    data = model_data,
    weights = anweight,
    link = "logit"
  ),
  error = function(e) {
    cat("\nProportional-odds model error:\n")
    cat(conditionMessage(e), "\n")
    NULL
  }
)

if (is.null(proportional_model)) {
  stop("Proportional-odds diagnostic model could not be fitted.")
}

cat("\nProportional-odds model summary:\n")
print(summary(proportional_model))

# Fit a nominal-effects model that allows migration-group effects
# to vary across thresholds.
nonproportional_model <- tryCatch(
  ordinal::clm(
    health_ordered ~ migration_group,
    nominal = ~ migration_group,
    data = model_data,
    weights = anweight,
    link = "logit"
  ),
  error = function(e) {
    cat("\nNon-proportional model error:\n")
    cat(conditionMessage(e), "\n")
    NULL
  }
)

if (is.null(nonproportional_model)) {
  stop(
    "The non-proportional model could not be fitted. ",
    "Do not conclude that the assumption passed."
  )
}

cat("\nModel allowing non-proportional effects:\n")
print(summary(nonproportional_model))

cat("\nLikelihood-ratio comparison:\n")

comparison <- tryCatch(
  anova(
    proportional_model,
    nonproportional_model
  ),
  error = function(e) {
    cat("Comparison could not be calculated:\n")
    cat(conditionMessage(e), "\n")
    NULL
  }
)

if (!is.null(comparison)) {
  print(comparison)
}

cat("\nIMPORTANT INTERPRETATION LIMITS:\n")
cat("- These models use case weights but not a verified survey variance design.\n")
cat("- The comparison is a diagnostic, not the final survey-weighted test.\n")
cat("- Sparse categories may cause convergence or stability problems.\n")
cat("- A non-significant comparison does not prove proportional odds.\n")
cat("- Do not finalize regression inference until survey design is verified.\n")

if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}

report <- capture.output({
  cat("STAGE 28: PROPORTIONAL-ODDS DIAGNOSTIC\n")
  cat("Eligible respondents:", nrow(model_data), "\n\n")
  cat("Proportional-odds model:\n")
  print(summary(proportional_model))
  cat("\nNon-proportional model:\n")
  print(summary(nonproportional_model))
  cat("\nLikelihood-ratio comparison:\n")
  if (!is.null(comparison)) {
    print(comparison)
  } else {
    cat("Comparison unavailable; inspect console output.\n")
  }
})

writeLines(report, output_path)

cat("\nDiagnostic report saved to:\n")
cat(output_path, "\n")
cat("No source data were modified.\n")