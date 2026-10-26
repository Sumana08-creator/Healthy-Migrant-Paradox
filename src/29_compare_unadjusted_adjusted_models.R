# STAGE 37: COMPARE UNADJUSTED AND AGE-ADJUSTED MODELS
# Both models use the same complete-case sample.
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
  "stage35_age_adjusted_model_sample.csv"
)

output_dir <- file.path(
  project_root,
  "outputs",
  "tables"
)

if (!file.exists(data_path)) {
  stop("ERROR: Prepared Stage 35 dataset not found.")
}

if (!requireNamespace("survey", quietly = TRUE)) {
  stop("ERROR: The survey package is required.")
}

data <- read.csv(
  data_path,
  stringsAsFactors = FALSE
)

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

design <- survey::svydesign(
  ids = ~1,
  weights = ~anweight,
  data = data
)

model_unadjusted <- survey::svyolr(
  health_ordered ~ migration_group,
  design = design,
  method = "logistic"
)

model_age_adjusted <- survey::svyolr(
  health_ordered ~ migration_group + agea,
  design = design,
  method = "logistic"
)

extract_results <- function(model, model_name) {

  estimates <- coef(model)
  standard_errors <- sqrt(diag(vcov(model)))

  result <- data.frame(
    term = names(estimates),
    estimate = as.numeric(estimates),
    standard_error = as.numeric(standard_errors),
    row.names = NULL
  )

  result <- result[
    !grepl("\\|", result$term),
    ,
    drop = FALSE
  ]

  result$model <- model_name
  result$odds_ratio <- exp(result$estimate)
  result$conf_low <- exp(
    result$estimate - 1.96 * result$standard_error
  )
  result$conf_high <- exp(
    result$estimate + 1.96 * result$standard_error
  )

  result[, c(
    "model",
    "term",
    "estimate",
    "standard_error",
    "odds_ratio",
    "conf_low",
    "conf_high"
  )]
}

results_unadjusted <- extract_results(
  model_unadjusted,
  "Unadjusted"
)

results_adjusted <- extract_results(
  model_age_adjusted,
  "Age-adjusted"
)

comparison <- rbind(
  results_unadjusted,
  results_adjusted
)

cat("STAGE 37: MODEL COMPARISON\n")
cat("==========================\n")
cat("Both models use the same sample of", nrow(data), "respondents.\n")
cat("Survey variance specification remains provisional.\n\n")

print(comparison, row.names = FALSE)

write.csv(
  comparison,
  file.path(
    output_dir,
    "stage37_model_comparison.csv"
  ),
  row.names = FALSE
)

cat("\nSUCCESS: Model comparison completed.\n")
cat("Saved to outputs/tables/stage37_model_comparison.csv\n")
cat("No source data were modified.\n")