# Stage 24 diagnostic: inspect actual values
# Read-only diagnostic. No regression or data modification.

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
  stop("Cleaned dataset not found.")
}

data <- read.csv(
  data_path,
  stringsAsFactors = FALSE
)

cat("DIAGNOSTIC: CLEANED ANALYSIS DATA\n")
cat("=================================\n")

cat("\nDataset dimensions:\n")
cat("Rows:", nrow(data), "\n")
cat("Columns:", ncol(data), "\n")

for (variable in c("health", "migration_group", "anweight")) {

  cat("\n---------------------------------\n")
  cat("Variable:", variable, "\n")

  if (!variable %in% names(data)) {
    cat("VARIABLE NOT FOUND\n")
    next
  }

  cat("Class:", paste(class(data[[variable]]), collapse = ", "), "\n")
  cat("Missing values:", sum(is.na(data[[variable]])), "\n")

  cat("First 10 values:\n")
  print(head(data[[variable]], 10))

  cat("Distinct values and frequencies:\n")
  print(head(sort(table(data[[variable]], useNA = "ifany"),
                  decreasing = TRUE), 20))
}

cat("\nHealth numeric conversion check:\n")

health_numeric <- suppressWarnings(
  as.numeric(as.character(data$health))
)

cat("Nonmissing after conversion:", sum(!is.na(health_numeric)), "\n")
cat("Health values 1 to 5:", sum(health_numeric %in% 1:5, na.rm = TRUE), "\n")

cat("\nMigration-group matching check:\n")

expected_groups <- c(
  "Non-migrant",
  "First-generation",
  "Second-generation"
)

group_text <- trimws(as.character(data$migration_group))

cat("Distinct group values:\n")
print(unique(group_text))

cat("Matches expected group names:\n")
print(table(group_text %in% expected_groups, useNA = "ifany"))

cat("\nDiagnostic complete.\n")
cat("No regression was performed.\n")
cat("No source data were modified.\n")