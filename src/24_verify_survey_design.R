# STAGE 32: VERIFY SURVEY DESIGN VARIABLES
# Inspect the Swiss ESS Round 11 design variables.
# No regression is performed.
# No source data are modified.

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
  "cntry",
  "pspwght",
  "pweight",
  "anweight",
  "dweight",
  "prob",
  "stratum",
  "psu"
)

missing_variables <- setdiff(
  required_variables,
  names(data)
)

if (length(missing_variables) > 0) {
  stop(
    paste(
      "Required variables not found:",
      paste(missing_variables, collapse = ", ")
    )
  )
}

cat("STAGE 32: SWISS ESS SURVEY DESIGN REVIEW\n")
cat("========================================\n")

cat("\nDataset rows:", nrow(data), "\n")

if ("cntry" %in% names(data)) {
  cat("\nCountry codes:\n")
  print(table(data$cntry, useNA = "ifany"))
}

design_variables <- c(
  "pspwght",
  "pweight",
  "anweight",
  "dweight",
  "prob",
  "stratum",
  "psu"
)

cat("\nVariable summaries:\n")

for (variable in design_variables) {
  x <- data[[variable]]

  cat("\nVariable:", variable, "\n")
  cat("Class:", paste(class(x), collapse = ", "), "\n")
  cat("Missing:", sum(is.na(x)), "\n")
  cat("Unique non-missing values:", length(unique(x[!is.na(x)])), "\n")

  if (is.numeric(x)) {
    cat("Minimum:", min(x, na.rm = TRUE), "\n")
    cat("Maximum:", max(x, na.rm = TRUE), "\n")
    cat("Mean:", mean(x, na.rm = TRUE), "\n")
  } else {
    cat("Most common values:\n")
    print(head(sort(table(x, useNA = "ifany"), decreasing = TRUE), 10))
  }
}

cat("\nStratum frequencies:\n")
print(table(data$stratum, useNA = "ifany"))

cat("\nNumber of unique PSU values:\n")
cat(length(unique(data$psu[!is.na(data$psu)])), "\n")

cat("\nPSU frequency summary:\n")
psu_frequency <- table(data$psu, useNA = "ifany")
print(summary(as.numeric(psu_frequency)))

cat("\nWeight identity check:\n")

valid_weights <- !is.na(data$pspwght) &
  !is.na(data$pweight) &
  !is.na(data$anweight)

if (any(valid_weights)) {
  difference <- data$anweight[valid_weights] -
    data$pspwght[valid_weights] * data$pweight[valid_weights]

  cat(
    "Maximum absolute difference between anweight and pspwght * pweight:",
    max(abs(difference)),
    "\n"
  )
} else {
  cat("No complete weight records available for comparison.\n")
}

cat("\nIMPORTANT:\n")
cat("This script describes the supplied variables only.\n")
cat("It does not establish that stratum or psu are valid design identifiers.\n")
cat("Confirm their meaning in the Round 11 Swiss documentation before\n")
cat("choosing a final variance-estimation design.\n")

if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}

output_file <- file.path(
  output_dir,
  "stage32_survey_design_variable_review.txt"
)

sink(output_file)

cat("STAGE 32: SWISS ESS SURVEY DESIGN REVIEW\n")
cat("========================================\n")
cat("Dataset rows:", nrow(data), "\n")

for (variable in design_variables) {
  x <- data[[variable]]

  cat("\nVariable:", variable, "\n")
  cat("Missing:", sum(is.na(x)), "\n")
  cat("Unique non-missing values:", length(unique(x[!is.na(x)])), "\n")

  if (is.numeric(x)) {
    cat("Minimum:", min(x, na.rm = TRUE), "\n")
    cat("Maximum:", max(x, na.rm = TRUE), "\n")
    cat("Mean:", mean(x, na.rm = TRUE), "\n")
  }
}

cat("\nStratum frequencies:\n")
print(table(data$stratum, useNA = "ifany"))

cat("\nPSU frequency summary:\n")
print(summary(as.numeric(table(data$psu, useNA = "ifany"))))

if (any(valid_weights)) {
  cat(
    "\nMaximum absolute weight identity difference:",
    max(abs(difference)),
    "\n"
  )
}

sink()

cat("\nSUCCESS: Stage 32 review completed.\n")
cat("Report saved to:\n")
cat(normalizePath(output_file, winslash = "/", mustWork = FALSE), "\n")
cat("\nNo regression was performed.\n")
cat("No source data were modified.\n")