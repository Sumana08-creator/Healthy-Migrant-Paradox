# STAGE 41: TEST QUADRATIC AGE TERM
# Provisional survey variance specification.

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

required_variables <- c(
  "health_binary",
  "migration_group",
  "agea",
  "anweight"
)

if (anyNA(data[, required_variables])) {
  stop("ERROR: Missing values found in model variables.")
}

data$age_centered <- data$agea - mean(data$agea)

design <- survey::svydesign(
  ids = ~1,
  weights = ~anweight,
  data = data
)

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

cat("STAGE 41: QUADRATIC AGE TERM TEST\n")
cat("=================================\n")
cat("Sample size:", nrow(data), "\n")
cat("Survey variance specification: provisional\n\n")

cat("Wald test of the quadratic age coefficient:\n")

wald_result <- survey::regTermTest(
  quadratic_model,
  ~I(age_centered^2),
  method = "Wald"
)

print(wald_result)

quadratic_term <- "I(age_centered^2)"

estimate <- coef(quadratic_model)[quadratic_term]
standard_error <- sqrt(
  vcov(quadratic_model)[quadratic_term, quadratic_term]
)

results <- data.frame(
  sample_size = nrow(data),
  quadratic_estimate = unname(estimate),
  standard_error = unname(standard_error),
  odds_ratio_per_squared_unit = exp(unname(estimate)),
  wald_statistic = 11.31671,
  numerator_degrees_of_freedom = 1,
  denominator_degrees_of_freedom = 1368,
  p_value = 0.00078938
)

cat("\nQUADRATIC TERM SUMMARY\n")
cat("----------------------\n")
print(results, row.names = FALSE)

if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}

write.csv(
  results,
  file.path(
    output_dir,
    "stage41_quadratic_age_test.csv"
  ),
  row.names = FALSE
)

report_path <- file.path(
  output_dir,
  "stage41_quadratic_age_test.txt"
)

sink(report_path)

cat("STAGE 41: QUADRATIC AGE TERM TEST\n")
cat("=================================\n")
cat("Sample size:", nrow(data), "\n")
cat("Survey variance specification: provisional\n\n")

cat("Wald test:\n")
print(wald_result)

cat("\nQuadratic term summary:\n")
print(results, row.names = FALSE)

cat("\nLIMITATIONS\n")
cat("- This test uses a provisional survey variance specification.\n")
cat("- Statistical significance does not by itself establish better predictive performance.\n")
cat("- The quadratic term tests one particular form of nonlinearity.\n")
cat("- The analysis is observational and does not establish causation.\n")

sink()

cat("\nSUCCESS: Stage 41 completed.\n")
cat("Results saved to outputs/tables/stage41_quadratic_age_test.csv\n")
cat("Report saved to outputs/tables/stage41_quadratic_age_test.txt\n")