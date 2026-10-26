# STAGE 36: AGE-ADJUSTED ORDINAL REGRESSION
# Uses the prepared complete-case dataset.
# Survey design specification remains provisional.

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
  "stage35_age_adjusted_model_sample.csv"
)

output_dir <- file.path(
  project_root,
  "outputs",
  "tables"
)

if (!file.exists(data_path)) {
  stop("ERROR: Stage 35 prepared dataset not found.")
}

if (!requireNamespace("survey", quietly = TRUE)) {
  stop("ERROR: Install the survey package before running this script.")
}

data <- read.csv(
  data_path,
  stringsAsFactors = FALSE
)

required_variables <- c(
  "health",
  "health_ordered",
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

data$health_ordered <- ordered(
  data$health_ordered,
  levels = c(
    "Very good",
    "Good",
    "Fair",
    "Bad",
    "Very bad"
  )
)

data$migration_group <- factor(
  data$migration_group,
  levels = c(
    "Non-migrant background",
    "First-generation migrant background",
    "Second-generation migrant background"
  )
)

data$agea <- as.numeric(data$agea)
data$anweight <- as.numeric(data$anweight)

if (anyNA(data[, required_variables])) {
  stop("ERROR: Missing values detected in model variables.")
}

if (any(!is.finite(data$anweight)) || any(data$anweight <= 0)) {
  stop("ERROR: Invalid analysis weights detected.")
}

# Provisional design: individual-level observations with analysis weights.
design <- survey::svydesign(
  ids = ~1,
  weights = ~anweight,
  data = data
)

cat("STAGE 36: AGE-ADJUSTED ORDINAL REGRESSION\n")
cat("=========================================\n")
cat("Sample size:", nrow(data), "\n")
cat("Survey variance specification: provisional\n")
cat("Outcome: health_ordered\n")
cat("Predictors: migration_group + agea\n\n")

model <- survey::svyolr(
  health_ordered ~ migration_group + agea,
  design = design,
  method = "logistic"
)

model_summary <- summary(model)

print(model_summary)

# Extract coefficient estimates and confidence intervals.
coefficients <- coef(model)
standard_errors <- sqrt(diag(vcov(model)))

if (any(!is.finite(coefficients)) ||
    any(!is.finite(standard_errors))) {
  warning("Some estimates or standard errors are non-finite.")
}

z_values <- coefficients / standard_errors

results <- data.frame(
  term = names(coefficients),
  estimate = as.numeric(coefficients),
  standard_error = as.numeric(standard_errors),
  z_value = as.numeric(z_values),
  p_value = 2 * pnorm(abs(z_values), lower.tail = FALSE),
  odds_ratio = exp(as.numeric(coefficients)),
  conf_low = exp(as.numeric(coefficients) -
                   1.96 * as.numeric(standard_errors)),
  conf_high = exp(as.numeric(coefficients) +
                    1.96 * as.numeric(standard_errors)),
  row.names = NULL
)

results <- results[
  !grepl("\\|", results$term),
  ,
  drop = FALSE
]

cat("\nCoefficient results (excluding ordinal thresholds):\n")
print(results, row.names = FALSE)

write.csv(
  results,
  file.path(
    output_dir,
    "stage36_age_adjusted_ordinal_results.csv"
  ),
  row.names = FALSE
)

report_path <- file.path(
  output_dir,
  "stage36_age_adjusted_ordinal_report.txt"
)

sink(report_path)

cat("STAGE 36: AGE-ADJUSTED ORDINAL REGRESSION\n")
cat("=========================================\n")
cat("Sample size:", nrow(data), "\n")
cat("Survey variance specification: provisional\n\n")

cat("Model summary:\n")
print(model_summary)

cat("\nCoefficient results (excluding ordinal thresholds):\n")
print(results, row.names = FALSE)

cat("\nINTERPRETATION LIMITATIONS\n")
cat("- This is an observational cross-sectional analysis.\n")
cat("- Estimates are associations, not causal effects.\n")
cat("- Proportional odds has not been conclusively verified.\n")
cat("- The very-bad-health category contains only five respondents.\n")
cat("- Survey variance estimation remains provisional.\n")
cat("- Results must be checked for numerical stability.\n")

sink()

cat("\nSUCCESS: Stage 36 model fitted.\n")
cat("Results saved to outputs/tables/stage36_age_adjusted_ordinal_results.csv\n")
cat("Report saved to outputs/tables/stage36_age_adjusted_ordinal_report.txt\n")
cat("Interpret inferential results cautiously until design verification.\n")