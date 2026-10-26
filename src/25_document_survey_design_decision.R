# STAGE 33: DOCUMENT SURVEY DESIGN DECISION
# Research documentation only.
# No source data are modified.

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

protocol_path <- file.path(
  project_root,
  "research_protocol.md"
)

report_path <- file.path(
  output_dir,
  "stage33_survey_design_decision.txt"
)

if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}

report <- c(
  "STAGE 33: SURVEY DESIGN DECISION RECORD",
  "=======================================",
  "",
  "Study:",
  "ESS Round 11 Edition 4.2, Switzerland (CH)",
  "",
  "Official documentation reviewed:",
  "FORS, European Social Survey in Switzerland:",
  "https://forscenter.ch/projects/european-social-survey/",
  "",
  "European Social Survey, Weighting:",
  "https://www.europeansocialsurvey.org/methodology/ess-methodology/data-processing-and-archiving/weighting",
  "",
  "DOCUMENTED FINDINGS",
  "-------------------",
  "1. FORS describes the Swiss ESS design since 2010 as a",
  "   single-stage random selection of individuals nationally,",
  "   without stratification.",
  "",
  "2. ESS recommends the analysis weight anweight for ESS analyses.",
  "",
  "3. In the cleaned Swiss dataset, anweight equals pspwght multiplied",
  "   by pweight. This identity was verified numerically.",
  "",
  "4. The supplied stratum variable has seven observed values.",
  "",
  "5. The supplied psu variable has one unique value per respondent.",
  "",
  "ANALYTICAL DECISION",
  "-------------------",
  "The official general Swiss methodology does not support assuming",
  "that the seven observed stratum codes and unique PSU values represent",
  "a conventional stratified, clustered sample for this Swiss analysis.",
  "",
  "Do not specify stratum and psu as design variables solely because",
  "they appear in the integrated dataset.",
  "",
  "For the next modelling stage, a design using ids = ~1 and weights =",
  "~anweight may be evaluated as a provisional specification consistent",
  "with the documented single-stage, non-stratified design.",
  "",
  "This is not yet a final variance-design validation. Confirm the",
  "round-specific Swiss documentation and the provenance of the supplied",
  "design fields before finalising inferential results.",
  "",
  "LIMITATIONS",
  "-----------",
  "The analysis weight adjusts the estimates but does not, by itself,",
  "resolve every source of uncertainty or bias.",
  "",
  "Previous regression results remain provisional until the variance",
  "specification and ordinal-model assumptions have been assessed.",
  "",
  "No regression was performed by this script.",
  "No source data were modified."
)

writeLines(report, report_path)

cat(paste(report, collapse = "\n"), "\n")

cat("\nReport saved to:\n")
cat(normalizePath(report_path, winslash = "/", mustWork = FALSE), "\n")