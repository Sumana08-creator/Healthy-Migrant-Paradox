# STAGE 42: FINAL METHODOLOGICAL DECISION RECORD
# Project: Beyond the Healthy Migrant Paradox
# Dataset: ESS Round 11 Edition 4.2, Switzerland

script_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
if (length(script_arg) > 0) {
  script_path <- normalizePath(sub("^--file=", "", script_arg[1]), winslash = "/", mustWork = TRUE)
  project_root <- dirname(dirname(script_path))
} else {
  project_root <- normalizePath(".", winslash = "/", mustWork = TRUE)
}
output_dir <- file.path(
  project_root,
  "outputs",
  "tables"
)

if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}

report_path <- file.path(
  output_dir,
  "stage42_final_methodological_decision.txt"
)

report <- c(
  "STAGE 42: FINAL METHODOLOGICAL DECISION RECORD",
  "==============================================",
  "",
  "Study:",
  "Beyond the Healthy Migrant Paradox:",
  "A Reproducible Statistical Investigation of Health Inequalities",
  "",
  "Dataset:",
  "European Social Survey Round 11 Edition 4.2, Switzerland (CH)",
  "",
  "1. ANALYTICAL WEIGHT",
  "--------------------",
  "The ESS recommends anweight for ESS analyses.",
  "The cleaned dataset was checked and anweight equals",
  "pspwght multiplied by pweight.",
  "The maximum absolute difference was zero.",
  "",
  "2. SAMPLE DESIGN",
  "----------------",
  "FORS documentation describes the Swiss ESS sample since 2010",
  "as a single-stage national random selection of individuals",
  "without stratification.",
  "",
  "The current working specification is:",
  "survey::svydesign(ids = ~1, weights = ~anweight, data = data)",
  "",
  "This specification is retained provisionally.",
  "The supplied stratum and psu variables are not used because",
  "their role in the Swiss Round 11 sampling design has not been",
  "independently established from round-specific documentation.",
  "",
  "3. LIMITATION OF VARIANCE ESTIMATION",
  "-----------------------------------",
  "The available general documentation supports the working",
  "sampling-design interpretation but does not fully validate",
  "every aspect of the variance specification for this analysis.",
  "",
  "Regression standard errors, confidence intervals and p-values",
  "must therefore be interpreted cautiously and reported with",
  "this limitation.",
  "",
  "4. PRIMARY OUTCOME",
  "------------------",
  "Self-reported health is an ordinal outcome with five categories:",
  "Very good, Good, Fair, Bad and Very bad.",
  "",
  "The ordinal model remains the primary outcome analysis.",
  "The proportional-odds assumption has not been conclusively",
  "validated. The diagnostic was unstable because the very-bad",
  "health category was sparse.",
  "",
  "5. BINARY SENSITIVITY ANALYSIS",
  "------------------------------",
  "A secondary sensitivity analysis defines fair or worse health",
  "as the outcome and combines very good/good health as the",
  "comparison category.",
  "",
  "This analysis loses information about the severity of health",
  "and does not replace the primary ordinal outcome.",
  "",
  "6. AGE SPECIFICATION",
  "--------------------",
  "The binary sensitivity analysis indicated evidence of a",
  "quadratic age association under the provisional specification.",
  "The quadratic term test produced F = 11.31671 and p = 0.00078938.",
  "",
  "This result is treated as exploratory and is not sufficient",
  "on its own to establish the definitive age specification.",
  "",
  "7. MISSING DATA",
  "---------------",
  "Income has substantially more missing data than the other",
  "adjustment variables. Complete-case models including income",
  "have a smaller sample and may be affected by selection bias.",
  "Missingness comparisons alone do not establish the missing-data",
  "mechanism.",
  "",
  "8. INTERPRETATION",
  "-----------------",
  "The study is observational and cross-sectional.",
  "Associations must not be interpreted as causal effects.",
  "Lack of statistical significance does not establish that",
  "migration groups have equivalent health outcomes.",
  "",
  "9. REPRODUCIBILITY",
  "------------------",
  "Raw data were preserved.",
  "Analysis stages and outputs were saved in the project.",
  "The cleaned analysis dataset was used for modelling.",
  "",
  "10. FINAL STATUS",
  "----------------",
  "The analyses are reproducible within the documented workflow.",
  "The survey variance specification and proportional-odds",
  "assumption remain limitations that must be disclosed.",
  "These results should not be described as fully validated",
  "survey-design-adjusted inference."
)

writeLines(report, report_path)

cat("SUCCESS: Stage 42 decision record created.\n")
cat("Report saved to outputs/tables/stage42_final_methodological_decision.txt\n")
cat("No raw or cleaned data were modified.\n")