# STAGE 29: SUMMARISE MODEL DIAGNOSTICS
# Document existing findings without fitting another model.
# Source data are not modified.

script_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
if (length(script_arg) > 0) {
  script_path <- normalizePath(sub("^--file=", "", script_arg[1]), winslash = "/", mustWork = TRUE)
  project_root <- dirname(dirname(script_path))
} else {
  project_root <- normalizePath(".", winslash = "/", mustWork = TRUE)
}
model1_path <- file.path(
  project_root,
  "outputs",
  "tables",
  "stage27_model1_unadjusted.txt"
)

diagnostic_path <- file.path(
  project_root,
  "outputs",
  "tables",
  "stage28_proportional_odds_diagnostic.txt"
)

output_path <- file.path(
  project_root,
  "outputs",
  "tables",
  "stage29_diagnostic_summary.txt"
)

if (!file.exists(model1_path)) {
  stop("Stage 27 model output was not found.")
}

if (!file.exists(diagnostic_path)) {
  stop("Stage 28 diagnostic output was not found.")
}

model1_text <- readLines(model1_path, warn = FALSE)
diagnostic_text <- readLines(diagnostic_path, warn = FALSE)

summary_text <- c(
  "STAGE 29: MODEL DIAGNOSTIC SUMMARY",
  "==================================",
  "",
  "Stage 27: Unadjusted ordinal regression",
  "----------------------------------------",
  "The model fitted successfully using anweight.",
  "The variance-estimation design remains provisional.",
  "The proportional-odds assumption has not been conclusively verified.",
  "",
  "Stage 28: Proportional-odds diagnostic",
  "--------------------------------------",
  "The likelihood-ratio comparison reported:",
  "LR statistic = 2.6282",
  "Degrees of freedom = 6",
  "p-value = 0.8539",
  "",
  "Important limitations:",
  "1. The more flexible model reported a numerically singular Hessian.",
  "2. Standard errors for the flexible model were undefined.",
  "3. Only five respondents reported very bad health.",
  "4. The nonsignificant comparison does not prove proportional odds.",
  "5. The survey variance-estimation approach remains provisional.",
  "6. The diagnostic comparison used case weights and is not a final",
  "   survey-design-adjusted test.",
  "",
  "Recommended next actions:",
  "1. Verify the Swiss ESS survey design from authoritative documentation.",
  "2. Document sparse health categories and assess model stability.",
  "3. Examine missingness in age, education, and income.",
  "4. Only then fit and assess adjusted regression models.",
  "",
  "No new regression was fitted by this script.",
  "No source data were modified."
)

dir.create(
  dirname(output_path),
  recursive = TRUE,
  showWarnings = FALSE
)

writeLines(summary_text, output_path)

cat(paste(summary_text, collapse = "\n"), "\n")
cat("\nSummary saved to:\n")
cat(output_path, "\n")