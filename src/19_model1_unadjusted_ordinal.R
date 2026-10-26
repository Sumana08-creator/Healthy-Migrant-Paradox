# STAGE 27: MODEL 1 - UNADJUSTED ORDINAL LOGISTIC REGRESSION
#
# Outcome: Self-reported health, ordered from very good to very bad.
# Exposure: Migration background.
# Weight: ESS analysis weight (anweight).
#
# IMPORTANT:
# The respondent-level variance design is provisional pending
# confirmation of the round-specific Swiss sampling documentation.
# No causal conclusions will be drawn.

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

results_path <- file.path(
  output_dir,
  "stage27_model1_unadjusted.txt"
)

if (!file.exists(data_path)) {
  stop("ERROR: Cleaned analysis dataset not found.")
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
      "Missing required variables:",
      paste(missing_variables, collapse = ", ")
    )
  )
}

# Convert variables safely.
data$health <- suppressWarnings(
  as.numeric(as.character(data$health))
)

data$anweight <- suppressWarnings(
  as.numeric(as.character(data$anweight))
)

data$migration_group <- trimws(
  as.character(data$migration_group)
)

# Preserve the intended reference category.
group_levels <- c(
  "Non-migrant background",
  "First-generation migrant background",
  "Second-generation migrant background"
)

data$migration_group <- factor(
  data$migration_group,
  levels = group_levels
)

# Retain complete, valid observations for this model.
model_data <- data[
  !is.na(data$health) &
    data$health %in% 1:5 &
    !is.na(data$migration_group) &
    !is.na(data$anweight) &
    is.finite(data$anweight) &
    data$anweight > 0,
]

cat("STAGE 27: MODEL 1 - UNADJUSTED ORDINAL REGRESSION\n")
cat("=================================================\n")

cat("Rows in cleaned dataset:", nrow(data), "\n")
cat("Rows included in model:", nrow(model_data), "\n")
cat("Rows excluded:", nrow(data) - nrow(model_data), "\n")

if (nrow(model_data) == 0) {
  stop("ERROR: No eligible observations for Model 1.")
}

# Define the health outcome as ordered.
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

# Confirm the analysis sample.
cat("\nHealth category counts:\n")
print(table(model_data$health_ordered))

cat("\nMigration group counts:\n")
print(table(model_data$migration_group))

cat("\nHealth distribution by migration group:\n")
print(
  table(
    model_data$migration_group,
    model_data$health_ordered
  )
)

# Load the survey package.
library(survey)

# PROVISIONAL design:
# Individual-level observations, weighted by anweight.
# This does not use the recorded stratum and psu variables.
design <- svydesign(
  ids = ~1,
  weights = ~anweight,
  data = model_data
)

# Fit the unadjusted ordinal logistic regression.
model1 <- tryCatch(
  svyolr(
    health_ordered ~ migration_group,
    design = design
  ),
  error = function(e) {
    cat("\nMODEL FIT ERROR:\n")
    cat(conditionMessage(e), "\n")
    NULL
  }
)

if (is.null(model1)) {
  stop(
    "Model 1 did not fit. Do not interpret or report model estimates."
  )
}

model_summary <- summary(model1)

cat("\nModel 1 summary:\n")
print(model_summary)

# Extract coefficients and standard errors.
coefficients <- coef(model1)
standard_errors <- model_summary$coefficients[, "Std. Error"]

if (any(!is.finite(coefficients)) ||
    any(!is.finite(standard_errors))) {
  stop(
    "Model produced non-finite estimates or standard errors. ",
    "Do not interpret these results."
  )
}

# For migration-group coefficients, calculate odds ratios and
# approximate Wald confidence intervals.
group_terms <- grep(
  "^migration_group",
  names(coefficients)
)

if (length(group_terms) == 0) {
  stop("No migration-group coefficients were found.")
}

term_names <- names(coefficients)[group_terms]
beta <- coefficients[group_terms]
se <- standard_errors[term_names]

results <- data.frame(
  term = term_names,
  log_odds = as.numeric(beta),
  standard_error = as.numeric(se),
  odds_ratio = exp(as.numeric(beta)),
  lower_95 = exp(as.numeric(beta) - 1.96 * as.numeric(se)),
  upper_95 = exp(as.numeric(beta) + 1.96 * as.numeric(se)),
  stringsAsFactors = FALSE
)

cat("\nMigration-group coefficient results:\n")
print(results, row.names = FALSE)

cat("\nInterpretation guide:\n")
cat("- Reference group: Non-migrant background.\n")
cat("- Outcome categories run from very good to very bad health.\n")
cat("- Odds ratios above 1 indicate higher odds of being in a worse\n")
cat("  health category under the proportional-odds model.\n")
cat("- Odds ratios below 1 indicate lower odds of being in a worse\n")
cat("  health category under that model.\n")
cat("- These are associations, not causal effects.\n")
cat("- Confidence intervals depend on the provisional variance design.\n")
cat("- The proportional-odds assumption has not yet been verified.\n")
cat("- Sparse health categories may affect model stability.\n")

# Save the output.
if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}

capture_output <- capture.output({
  cat("STAGE 27: MODEL 1 - UNADJUSTED ORDINAL REGRESSION\n")
  cat("=================================================\n")
  cat("Reference group: Non-migrant background\n")
  cat("Outcome: Ordered self-reported health, very good to very bad\n")
  cat("Weight: anweight\n")
  cat("Variance design: Provisional ids = ~1\n\n")
  cat("Model summary:\n")
  print(model_summary)
  cat("\nMigration-group estimates:\n")
  print(results, row.names = FALSE)
  cat("\nCaution: Survey variance design and proportional-odds assumption\n")
  cat("require further verification before final interpretation.\n")
})

writeLines(
  capture_output,
  results_path
)

cat("\nSUCCESS: Model 1 fitted successfully.\n")
cat("Results saved to:\n")
cat(results_path, "\n")

cat("\nNo source data were modified.\n")