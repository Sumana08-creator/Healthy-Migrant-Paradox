# Stage 21: Inspect survey-analysis capabilities
# This script does not fit any models or modify data.

library(survey)

cat("STAGE 21: SURVEY PACKAGE CAPABILITY CHECK\n")
cat("=========================================\n\n")

cat("Survey package version:\n")
print(packageVersion("survey"))

functions_to_check <- c(
  "svydesign",
  "svymean",
  "svytable",
  "svyolr",
  "svyglm",
  "svycontrast"
)

cat("\nFunction availability:\n")

for (function_name in functions_to_check) {
  cat(
    function_name,
    ":",
    exists(function_name, where = asNamespace("survey"), inherits = FALSE),
    "\n"
  )
}

cat("\nOrdinal regression documentation:\n")
help_topic <- utils::help("svyolr", package = "survey")
cat("svyolr help topic found:", length(help_topic) > 0, "\n")

cat("\nInspection complete.\n")
cat("No regression was performed.\n")
cat("No source data were modified.\n")