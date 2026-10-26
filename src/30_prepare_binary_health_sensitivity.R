# STAGE 38: PREPARE BINARY HEALTH SENSITIVITY ANALYSIS
# Creates a secondary outcome for sensitivity analysis.
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

data$health <- as.numeric(data$health)
data$agea <- as.numeric(data$agea)
data$anweight <- as.numeric(data$anweight)

# ESS health codes:
# 1 = Very good
# 2 = Good
# 3 = Fair
# 4 = Bad
# 5 = Very bad
#
# Sensitivity outcome:
# 0 = Very good or Good
# 1 = Fair, Bad, or Very bad

data$health_binary <- ifelse(
  data$health %in% c(1, 2),
  0,
  ifelse(
    data$health %in% c(3, 4, 5),
    1,
    NA
  )
)

data$health_binary_label <- factor(
  data$health_binary,
  levels = c(0, 1),
  labels = c(
    "Very good or Good",
    "Fair or worse"
  )
)

cat("STAGE 38: BINARY HEALTH SENSITIVITY PREPARATION\n")
cat("===============================================\n")

cat("\nSample size:", nrow(data), "\n")

cat("\nBinary outcome counts:\n")
print(table(data$health_binary_label, useNA = "ifany"))

cat("\nBinary outcome percentages:\n")
print(
  round(
    100 * prop.table(table(data$health_binary_label)),
    2
  )
)

cat("\nBinary outcome by migration group:\n")
print(
  table(
    data$migration_group,
    data$health_binary_label,
    useNA = "ifany"
  )
)

cat("\nMissingness in analysis variables:\n")
print(
  colSums(
    is.na(
      data[
        c(
          "health_binary",
          "migration_group",
          "agea",
          "anweight"
        )
      ]
    )
  )
)

if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}

write.csv(
  data,
  file.path(
    output_dir,
    "stage38_binary_health_sensitivity_sample.csv"
  ),
  row.names = FALSE
)

cat("\nSUCCESS: Stage 38 preparation completed.\n")
cat("Prepared sample saved to outputs/tables/stage38_binary_health_sensitivity_sample.csv\n")
cat("No regression was performed.\n")
cat("The original cleaned dataset was not modified.\n")