# Stage 20: Verify survey-analysis setup
# Inspection only: no regression and no source-data modification.

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

if (!file.exists(data_path)) {
  stop("Cleaned analysis dataset not found: ", data_path)
}

data <- read.csv(data_path, stringsAsFactors = FALSE)

cat("STAGE 20: SURVEY SETUP CHECK\n")
cat("============================\n")
cat("Rows:", nrow(data), "\n")
cat("Columns:", ncol(data), "\n\n")

required_variables <- c(
  "health",
  "migration_group",
  "agea",
  "anweight",
  "pspwght",
  "pweight",
  "stratum",
  "psu"
)

cat("Required-variable check:\n")

for (variable in required_variables) {
  cat(
    variable, ":",
    if (variable %in% names(data)) "FOUND" else "NOT FOUND",
    "\n"
  )
}

cat("\nSurvey package version:\n")
print(packageVersion("survey"))

cat("\nWeight consistency check:\n")

if (all(c("anweight", "pspwght", "pweight") %in% names(data))) {
  calculated_weight <- data$pspwght * data$pweight
  difference <- abs(calculated_weight - data$anweight)

  cat(
    "Maximum absolute difference:",
    format(max(difference, na.rm = TRUE), scientific = FALSE),
    "\n"
  )
} else {
  cat("Cannot check: one or more weight variables are missing.\n")
}

cat("\nInspection complete.\n")
cat("No regression was performed.\n")
cat("No source data were modified.\n")