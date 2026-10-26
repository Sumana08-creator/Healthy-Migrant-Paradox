# Stage 22: Review sampling variables by country
# Descriptive inspection only; no regression.

library(survey)

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
  "raw",
  "ESS11e04_2-subset.csv"
)

if (!file.exists(data_path)) {
  stop("Original ESS dataset not found.")
}

ess <- read.csv(data_path, stringsAsFactors = FALSE)

cat("STAGE 22: SWISS SAMPLING DESIGN REVIEW\n")
cat("======================================\n")

cat("\nCountries in original dataset:\n")
print(length(unique(ess$cntry)))

cat("\nCountry-level sampling variable counts:\n")

for (country in c("CH", "GB", "DE", "FR")) {
  subset_data <- ess[ess$cntry == country, ]

  cat("\nCountry:", country, "\n")
  cat("Respondents:", nrow(subset_data), "\n")

  for (variable in c("prob", "stratum", "psu")) {
    if (variable %in% names(subset_data)) {
      values <- subset_data[[variable]]

      cat(
        variable,
        "- distinct:",
        length(unique(values[!is.na(values)])),
        "; missing:",
        sum(is.na(values)),
        "\n"
      )
    }
  }
}

cat("\nSwiss sampling-variable examples:\n")

swiss <- ess[ess$cntry == "CH", ]

variables <- intersect(
  c("cntry", "prob", "stratum", "psu",
    "dweight", "pspwght", "pweight", "anweight"),
  names(swiss)
)

print(head(swiss[, variables, drop = FALSE], 10))

cat("\nInspection complete.\n")
cat("No regression was performed.\n")
cat("The original dataset was read only.\n")