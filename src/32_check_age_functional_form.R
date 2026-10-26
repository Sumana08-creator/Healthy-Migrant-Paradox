# STAGE 40: CHECK AGE FUNCTIONAL FORM
# Compare linear and quadratic age specifications.
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

if (anyNA(data[, c(
  "health_binary",
  "migration_group",
  "agea",
  "anweight"
)])) {
  stop("ERROR: Missing values found in model variables.")
}

# Center age to make the quadratic specification easier to interpret.
data$age_centered <- data$agea - mean(data$agea)

design <- survey::svydesign(
  ids = ~1,
  weights = ~anweight,
  data = data
)

cat("STAGE 40: AGE FUNCTIONAL-FORM CHECK\n")
cat("===================================\n")
cat("Sample size:", nrow(data), "\n")
cat("Survey variance specification: provisional\n\n")

linear_model <- survey::svyglm(
  health_binary ~ migration_group + age_centered,
  design = design,
  family = quasibinomial()
)

quadratic_model <- survey::svyglm(
  health_binary ~ migration_group +
    age_centered + I(age_centered^2),
  design = design,
  family = quasibinomial()
)

cat("LINEAR AGE MODEL\n")
cat("----------------\n")
print(summary(linear_model))

cat("\nQUADRATIC AGE MODEL\n")
cat("-------------------\n")
print(summary(quadratic_model))

extract_results <- function(model, model_name) {

  estimates <- coef(model)
  standard_errors <- sqrt(diag(vcov(model)))

  data.frame(
    model = model_name,
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
    row.names = NULL
  )
}

comparison <- rbind(
  extract_results(linear_model, "Linear age"),
  extract_results(quadratic_model, "Quadratic age")
)

cat("\nCOEFFICIENT COMPARISON\n")
cat("---------------------\n")
print(comparison, row.names = FALSE)

if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}

write.csv(
  comparison,
  file.path(
    output_dir,
    "stage40_age_functional_form_comparison.csv"
  ),
  row.names = FALSE
)

report_path <- file.path(
  output_dir,
  "stage40_age_functional_form_report.txt"
)

sink(report_path)

cat("STAGE 40: AGE FUNCTIONAL-FORM CHECK\n")
cat("===================================\n")
cat("Sample size:", nrow(data), "\n")
cat("Survey variance specification: provisional\n\n")

cat("Linear age model:\n")
print(summary(linear_model))

cat("\nQuadratic age model:\n")
print(summary(quadratic_model))

cat("\nCoefficient comparison:\n")
print(comparison, row.names = FALSE)

cat("\nLIMITATIONS\n")
cat("- This is a sensitivity analysis of the age specification.\n")
cat("- A quadratic term does not capture every possible nonlinear pattern.\n")
cat("- The survey variance specification remains provisional.\n")
cat("- These models do not establish causal relationships.\n")

sink()

cat("\nSUCCESS: Stage 40 completed.\n")
cat("Results saved to outputs/tables/stage40_age_functional_form_comparison.csv\n")
cat("Report saved to outputs/tables/stage40_age_functional_form_report.txt\n")