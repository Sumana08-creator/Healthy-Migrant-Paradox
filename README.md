# Beyond the Healthy Migrant Paradox

## A Reproducible Statistical Investigation of Health Inequalities in Switzerland

### Project Overview

This project investigates associations between migration background and self-reported health among respondents in Switzerland using European Social Survey (ESS) Round 11, Edition 4.2 data.

The analysis examines three migration-background groups:

- Non-migrant background
- First-generation migrant background
- Second-generation migrant background

The project emphasizes transparent data preparation, reproducible analytical workflows, statistical diagnostics, and explicit reporting of methodological limitations.

### Research Question

How is migration background associated with self-reported health in the Swiss ESS Round 11 sample, and how do the observed associations change after adjustment for age?

### Data and Study Population

The cleaned analysis dataset contains 1,381 records. One record has missing health information, leaving 1,380 respondents eligible for the primary health analyses.

Self-reported health is treated as an ordinal outcome with five ordered categories:

1. Very good
2. Good
3. Fair
4. Bad
5. Very bad

The analysis also examines age, education, and household income. Income has substantially more missing data than the other adjustment variables.

Raw and respondent-level datasets are excluded from version control. Researchers seeking to reproduce the analysis must obtain the appropriate ESS data through authorized channels and comply with the applicable access and redistribution conditions.

### Research Objectives

The project aims to:

1. Describe self-reported health across migration-background groups.
2. Examine migration-background associations using ordinal regression.
3. Investigate how estimated associations change after adjustment for age.
4. Conduct binary-outcome sensitivity analysis.
5. Assess the functional form of age in the sensitivity model.
6. Document methodological limitations and outstanding analytical questions.

### Analytical Workflow

The numbered Python and R scripts in `src/` cover:

1. Data validation and codebook checks.
2. Health outcome and migration-group assessment.
3. Adjustment-variable validation.
4. Preparation of the cleaned analysis dataset.
5. Survey-weight inspection and methodological review.
6. Weighted descriptive analysis.
7. Unadjusted ordinal regression.
8. Proportional-odds diagnostics.
9. Covariate missingness analysis.
10. Age-adjusted ordinal regression.
11. Comparison of unadjusted and adjusted models.
12. Binary health sensitivity analysis.
13. Assessment of the functional form of age.
14. Documentation of methodological decisions.

Selected analytical outputs are stored in `outputs/tables/`. Outputs should be reviewed before publication to ensure that they do not contain respondent-level information or other material unsuitable for public release.

### Preliminary Findings

Weighted descriptive summaries show differences in the distribution of self-reported health across migration-background groups.

In the age-adjusted ordinal model, estimated migration-group associations were attenuated relative to the unadjusted model. The first-generation and second-generation estimates were not statistically significant at the 5% level.

The age coefficient was positive in the age-adjusted ordinal model, indicating higher estimated odds of worse self-reported health with increasing age under the fitted model's parameterization.

A separate binary-outcome sensitivity analysis examines very good/good health versus fair-or-worse health.

These are observational associations. They do not establish causal effects, and non-significant results do not demonstrate that groups have equivalent health outcomes.

### Methodological Limitations

#### Survey Design and Variance Estimation

The analysis uses the ESS analysis weight (`anweight`). The appropriate variance-estimation specification for the Swiss ESS Round 11 sample has not been conclusively established.

The current workflow uses the provisional specification:

`survey::svydesign(ids = ~1, weights = ~anweight, data = data)`

Standard errors, confidence intervals, and p-values should therefore be interpreted cautiously. The results must not be presented as fully validated survey-design-adjusted inference.

#### Proportional-Odds Assumption

The proportional-odds diagnostic was inconclusive. The non-proportional model encountered numerical instability, and only five respondents were in the most severe health category.

The assumption remains an unresolved limitation. The current analysis does not establish either that the assumption holds or that it fails.

#### Age Functional Form

An exploratory quadratic-age test indicated that a quadratic term improved the fitted binary health sensitivity model under the provisional variance specification.

This finding is exploratory and does not establish a definitive age specification for every outcome or model.

#### Missing Data

Household income has substantially more missing data than the other adjustment variables.

Complete-case analyses incorporating income use a smaller sample and may be affected by selection bias. Descriptive comparisons alone do not establish the missing-data mechanism.

#### Study Design and Causal Interpretation

The study is observational and cross-sectional. Statistical associations must not be interpreted as causal effects.

A non-significant result does not demonstrate equivalence between migration-background groups.

### Reproducibility

The repository contains numbered Python and R scripts, dependency documentation, and selected analysis outputs.

#### Software Requirements

Python:
- Python with `pip`
- Dependencies documented in `requirements.txt`

R:
- R
- Packages documented in `r-requirements.txt`

The documented package versions reflect the environment used during project preparation. They do not guarantee that every script will run identically in a different environment.

#### Preparing the Environment

1. Obtain the appropriate ESS Round 11, Edition 4.2 dataset under its applicable access conditions.
2. Place the authorized input data at the location expected by the relevant script.
3. From the project root, install the Python dependency:

   `python -m pip install -r requirements.txt`

4. Install the required R packages in R:

   `install.packages(c("survey", "ordinal"))`

5. Review the input and output paths in each script.
6. Run the scripts in the intended analytical order, confirming that required intermediate files exist before running later stages.
7. Compare regenerated results with the saved, reviewed outputs where available.
8. Review the methodological decision records before interpreting the estimates.

The repository excludes raw and respondent-level datasets. Researchers must obtain the appropriate data independently.

Computational reproducibility does not, by itself, validate the statistical assumptions or survey variance specification.

### Repository Structure

- `src/` — numbered Python and R analysis scripts
- `data/raw/` — raw data, excluded from Git
- `data/processed/` — processed respondent-level data, excluded from Git
- `data/synthetic/` — excluded pending provenance review
- `outputs/tables/` — analysis tables, subject to publication review
- `outputs/figures/` — analytical figures
- `research_protocol.md` — research protocol
- `report/` — research documentation
- `tests/` — validation tests
- `requirements.txt` — Python dependency documentation
- `r-requirements.txt` — R package version documentation

### Research Integrity and Status

The project documents its analysis stages, preliminary findings, and methodological decisions.

The current status is a documented computational workflow with important inferential limitations unresolved.

In particular:

- The survey variance-estimation specification requires further verification.
- The proportional-odds assumption remains inconclusive.
- The quadratic-age finding is exploratory.
- Missing income data may affect complete-case analyses.
- The observational design does not support causal conclusions.

The results should not be presented as fully validated survey-design-adjusted inference. Further methodological verification is necessary before making stronger inferential claims.

### License and Data Availability

A repository license has not yet been selected. Licensing and redistribution permissions must be reviewed before public release.

The ESS respondent-level data are not included in the repository. Researchers must obtain the appropriate data independently and comply with the applicable access and redistribution conditions.

Only materials that the project author is authorized to distribute should be published.

### Acknowledgment

This project uses data from the European Social Survey (ESS). Researchers using the data should follow the ESS's applicable citation and acknowledgment requirements.