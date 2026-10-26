# STAGE 39: BINARY LOGISTIC REGRESSION SENSITIVITY ANALYSIS
# Outcome: Fair or worse health versus Very good or Good.
# Predictor: Migration background.
# Adjustment: Age.
# Survey variance specification remains provisional.

script_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
if (length(script_arg) > 0) {
  script_path <- normalizePath(sub("^--file=", "", script_arg[1]), winslash = "/", mustWork = TRUE)
  project_root <- dirname(dirname(script_path))
} else {
  project_root <- normalizePath(".", winslash = "/", mustWork = TRUE)
}
data_path <- file.path(
  project_root,
  "outputs",
  "tables",
  "stage38_binary_health_sensitivity_sample.csv"
)

output_dir <- file.path(
  project_root,
  "outputs",
  "tables"
)

if (!file.exists(data_path)) {
  stop("ERROR: Stage 38 dataset not found.")
}

if (!requireNamespace("survey", quietly = TRUE)) {
  stop("ERROR: The survey package is required.")
}

data <- read.csv(
  data_path,
  stringsAsFactors = FALSE
)

required_variables <- c(
  "health_binary",
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

data$health_binary <- as.numeric(data$health_binary)
data$agea <- as.numeric(data$agea)
data$anweight <- as.numeric(data$anweight)

data$migration_group <- factor(
  data$migration_group,
  levels = c(
    "Non-migrant background",
    "First-generation migrant background",
    "Second-generation migrant background"
  )
)

if (anyNA(data[, required_variables])) {
  stop("ERROR: Missing values found in model variables.")
}

if (!all(data$health_binary %in% c(0, 1))) {
  stop("ERROR: Binary outcome must contain only 0 and 1.")
}

if (any(!is.finite(data$anweight)) || any(data$anweight <= 0)) {
  stop("ERROR: Invalid weights detected.")
}

# Provisional individual-level design with analysis weights.
design <- survey::svydesign(
  ids = ~1,
  weights = ~anweight,
  data = data
)

cat("STAGE 39: BINARY LOGISTIC REGRESSION\n")
cat("====================================\n")
cat("Sample size:", nrow(data), "\n")
cat("Outcome: Fair or worse health = 1\n")
cat("Reference group: Non-migrant background\n")
cat("Adjustment: Age\n")
cat("Survey variance specification: provisional\n\n")

model <- survey::svyglm(
  health_binary ~ migration_group + agea,
  design = design,
  family = quasibinomial()
)

print(summary(model))

estimates <- coef(model)
standard_errors <- sqrt(diag(vcov(model)))

results <- data.frame(
  term = names(estimates),
  estimate = as.numeric(estimates),
  standard_error = as.numeric(standard_errors),
  odds_ratio = exp(as.numeric(estimates)),
  conf_low = exp(
    as.numeric(estimates) -
      1.96 * as.numeric(standard_errors)
  ),
  conf_high = exp(
    as.numeric(estimates) +
      1.96 * as.numeric(standard_errors)
  ),
  p_value = 2 * pnorm(
    abs(as.numeric(estimates) / as.numeric(standard_errors)),
    lower.tail = FALSE
  ),
  row.names = NULL
)

cat("\nOdds ratios and 95% confidence intervals:\n")
print(results, row.names = FALSE)

write.csv(
  results,
  file.path(
    output_dir,
    "stage39_binary_health_sensitivity_results.csv"
  ),
  row.names = FALSE
)

report_path <- file.path(
  output_dir,
  "stage39_binary_health_sensitivity_report.txt"
)

sink(report_path)

cat("STAGE 39: BINARY LOGISTIC REGRESSION\n")
cat("====================================\n")
cat("Sample size:", nrow(data), "\n")
cat("Outcome: Fair or worse health = 1\n")
cat("Reference group: Non-migrant background\n")
cat("Adjustment: Age\n")
cat("Survey variance specification: provisional\n\n")

cat("Model summary:\n")
print(summary(model))

cat("\nOdds ratios and 95% confidence intervals:\n")
print(results, row.names = FALSE)

cat("\nLIMITATIONS\n")
cat("- This is a secondary binary-outcome sensitivity analysis.\n")
cat("- The original five-category health outcome remains the primary outcome.\n")
cat("- The binary outcome loses information about health severity.\n")
cat("- The study is observational and cross-sectional.\n")
cat("- The survey variance specification remains provisional.\n")
cat("- Results should not be interpreted causally.\n")

sink()

cat("\nSUCCESS: Stage 39 completed.\n")
cat("Results saved to outputs/tables/stage39_binary_health_sensitivity_results.csv\n")
cat("Report saved to outputs/tables/stage39_binary_health_sensitivity_report.txt\n")
cat("Survey variance specification remains provisional.\n")