# STAGE 26: SURVEY DESIGN REVIEW
# Inspect survey weights and sampling variables.
# No regression or inferential analysis is performed.
# Source data are not modified.

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

report_path <- file.path(
  output_dir,
  "stage26_survey_design_review.txt"
)

if (!file.exists(data_path)) {
  stop("ERROR: Cleaned dataset not found.")
}

data <- read.csv(
  data_path,
  stringsAsFactors = FALSE
)

cat("STAGE 26: SURVEY DESIGN REVIEW\n")
cat("==============================\n")

cat("\nDataset dimensions:\n")
cat("Rows:", nrow(data), "\n")
cat("Columns:", ncol(data), "\n")

# Inspect the relevant variables.
candidate_variables <- c(
  "cntry",
  "pspwght",
  "pweight",
  "anweight",
  "dweight",
  "prob",
  "stratum",
  "psu"
)

available_variables <- intersect(
  candidate_variables,
  names(data)
)

missing_variables <- setdiff(
  candidate_variables,
  names(data)
)

cat("\nVariables available:\n")
print(available_variables)

cat("\nVariables not found:\n")
print(missing_variables)

# Capture output so the review is saved as a report.
review_output <- capture.output({

  cat("STAGE 26: SURVEY DESIGN REVIEW\n")
  cat("==============================\n")

  cat("\nDataset dimensions:", nrow(data), "rows;",
      ncol(data), "columns\n")

  for (variable in available_variables) {

    x <- data[[variable]]

    cat("\n----------------------------------\n")
    cat("Variable:", variable, "\n")
    cat("Class:", paste(class(x), collapse = ", "), "\n")
    cat("Missing values:", sum(is.na(x)), "\n")
    cat("Distinct nonmissing values:", length(unique(x[!is.na(x)])), "\n")

    if (is.numeric(x)) {
      cat("Minimum:", min(x, na.rm = TRUE), "\n")
      cat("Maximum:", max(x, na.rm = TRUE), "\n")
      cat("Mean:", mean(x, na.rm = TRUE), "\n")
    }

    if (variable %in% c("cntry", "stratum")) {
      cat("Value frequencies:\n")
      print(table(x, useNA = "ifany"))
    }

    if (variable == "psu") {
      cat("Number of unique PSU values:",
          length(unique(x[!is.na(x)])), "\n")
      cat("First 15 values:\n")
      print(head(x, 15))
    }
  }

  # Check whether anweight equals pspwght multiplied by pweight.
  if (all(c("anweight", "pspwght", "pweight") %in% names(data))) {

    anweight <- suppressWarnings(as.numeric(data$anweight))
    pspwght <- suppressWarnings(as.numeric(data$pspwght))
    pweight <- suppressWarnings(as.numeric(data$pweight))

    valid <- complete.cases(anweight, pspwght, pweight)

    if (any(valid)) {
      difference <- anweight[valid] -
        (pspwght[valid] * pweight[valid])

      cat("\nWeight identity check:\n")
      cat("Valid rows:", sum(valid), "\n")
      cat("Maximum absolute difference between anweight and",
          "pspwght * pweight:",
          max(abs(difference)), "\n")
    }
  }

  cat("\nInterpretation limits:\n")
  cat("- This script describes the recorded variables only.\n")
  cat("- Variable names alone do not establish their correct use\n")
  cat("  for variance estimation.\n")
  cat("- The appropriate Swiss ESS survey design must be confirmed\n")
  cat("  from authoritative documentation before inferential analysis.\n")
  cat("- No regression, confidence intervals, or significance tests\n")
  cat("  were performed.\n")
})

cat(paste(review_output, collapse = "\n"), "\n")

if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}

writeLines(
  review_output,
  report_path
)

cat("\nSUCCESS: Survey design review completed.\n")
cat("Report saved to:\n")
cat(report_path, "\n")

cat("\nNo regression was performed.\n")
cat("The cleaned dataset was not modified.\n")