Research Protocol

Beyond the Healthy Migrant Paradox: A Reproducible Statistical Investigation of Health Inequalities



Protocol version: 2.0

Study design: Cross-sectional observational analysis

Primary data source: European Social Survey (ESS), Round 11

Study population: Survey respondents in Switzerland who can be classified into the prespecified migration-background groups

Primary outcome: Self-reported general health

Primary analytical approach: Ordinal regression, subject to model diagnostics and verification of the survey-design methodology



1\. Background and Rationale



The healthy migrant paradox describes the observation that some migrant populations appear to have better health outcomes than non-migrant populations, despite potentially experiencing socioeconomic disadvantage and barriers to healthcare.



However, comparisons between migrant and non-migrant populations may be influenced by differences in age, education, household income, migration history, and other characteristics. The results may also depend on how migration background and health are defined, how missing data are handled, and whether the statistical analysis appropriately accounts for the survey design.



A transparent and reproducible investigation is therefore needed to examine how estimated differences in self-reported health vary across migration-background groups and how these differences change after statistical adjustment.



This study will investigate these associations using documented survey data and prespecified analytical procedures. It will distinguish descriptive differences from adjusted associations and avoid interpreting cross-sectional associations as causal effects.



The analysis will also examine whether alternative model specifications and missing-data decisions materially affect the findings.



2\. Research Aim



To investigate differences in self-reported general health between migration-background groups in Switzerland and assess how these differences change after accounting for age and socioeconomic characteristics.



3\. Research Questions

3.1 Primary research question



How do estimated differences in self-reported general health between first-generation migrants, second-generation individuals, and people with a non-migrant background change after adjustment for age and socioeconomic characteristics?



3.2 Secondary research questions

How does the distribution of self-reported health differ across the three migration-background groups?

To what extent do age differences account for observed differences in self-reported health?

How do estimated associations change after adjustment for educational attainment?

How sensitive are the findings to the inclusion of household income?

How might missing observations and complete-case selection influence the findings?

Are the results robust to alternative outcome definitions and statistical model specifications?

How do survey weighting and assumptions about the sampling design influence the estimates and their uncertainty?

4\. Study Design



The study will use a cross-sectional observational design based on existing survey data.



The analysis will estimate associations between migration background and self-reported general health at the time of the survey.



The study will not attempt to establish that migration causes better or worse health. The temporal ordering of migration, socioeconomic circumstances, and reported health cannot be established sufficiently from the proposed analysis alone.



5\. Data Source and Study Population

5.1 Data source



The study uses the European Social Survey Round 11 integrated dataset.



The working dataset contains respondents from Switzerland selected using the country variable cntry.



The original source file is:



data/raw/ESS11e04\_2-subset.csv



The cleaned analytical dataset is:



data/processed/switzerland\_cleaned\_analysis.csv



The original raw dataset will remain unchanged.



The exact ESS release, download date, dataset citation, and applicable documentation will be recorded in the final research materials.



5.2 Study population



The preliminary cleaned dataset contains 1,381 respondents classified into three migration-background groups:



Migration-background group	Respondents

Non-migrant background	780

First-generation migrant background	393

Second-generation migrant background	208

Total	1,381



These counts describe the current working dataset. They will be reconfirmed before the primary analysis.



5.3 Eligibility and exclusions



Respondents will be classified according to the prespecified migration-background definitions.



The primary regression analysis will require non-missing values for the outcome and the variables included in the relevant model.



The number of respondents excluded at each stage will be reported, with exclusion reasons documented.



No exclusions will be made solely because a respondent reports poor health.



6\. Exposure: Migration Background



Migration background will be represented by a categorical variable with three groups.



Category	Operational definition

Non-migrant background	Respondent born in Switzerland, with both parents born in Switzerland

First-generation migrant background	Respondent born outside Switzerland

Second-generation migrant background	Respondent born in Switzerland, with at least one parent born outside Switzerland



The non-migrant-background group will serve as the reference category.



Respondents whose migration background cannot be classified because of missing or invalid birthplace information will not be assigned to a group by assumption. Their numbers and reasons for exclusion will be documented.



These are operational definitions for this study, not universal definitions of migration background. Their limitations will be acknowledged when interpreting results.



7\. Primary Outcome: Self-Reported General Health



The primary outcome is the ESS variable health.



The variable represents respondents' assessment of their general health.



The five substantive response categories are:



Original ESS code	Health category	Analytical order

1	Very good	1

2	Good	2

3	Fair	3

4	Bad	4

5	Very bad	5



Higher analytical values will indicate worse self-reported health.



Special non-substantive response codes, including refusal, don't know, and no answer, will be treated as missing according to the codebook.



The outcome will be analysed as an ordered categorical variable rather than automatically assuming that the distance between adjacent health categories is equal.



Preliminary outcome distribution



The current cleaned dataset contains 1,380 valid health responses:



Health category	Respondents	Percentage

Very good	444	32.17%

Good	686	49.71%

Fair	214	15.51%

Bad	31	2.25%

Very bad	5	0.36%



The small number of respondents reporting very bad health will be considered when evaluating model stability and alternative outcome specifications.



8\. Covariates and Potential Confounders

8.1 Age



Variable: agea



Age will be included as a continuous covariate in the age-adjusted model, subject to examination of its distribution and relationship with the outcome.



The age variable will be checked for invalid special codes before analysis.



A linear age effect will be assessed for suitability. If the relationship appears nonlinear, a prespecified alternative such as a restricted cubic spline or another justified functional form will be considered.



8.2 Educational attainment



Variable: eisced



Educational attainment will be used as the primary socioeconomic adjustment variable in the main adjusted model.



Special missing-value codes will be recoded according to the ESS codebook. Substantive categories will be checked before the variable is treated as categorical or ordinal.



The analysis will not assume that educational categories are equally spaced.



8.3 Household income



Variable: hinctnta



Household income decile will be included in a supplementary model to investigate whether the estimated migration-group associations change after additional socioeconomic adjustment.



The current readiness assessment indicates that the model including income has approximately 1,178 complete cases, compared with 1,381 respondents in the classified analytical dataset.



Because income has substantially more missing data than the other main variables, the income-adjusted model will be interpreted cautiously.



8.4 Other variables



Additional covariates will not be added automatically.



Any additional variable will require a substantive justification, an explicit definition, and a documented assessment of its suitability.



The analysis will avoid indiscriminately adjusting for variables that might lie on the pathway between migration-related experiences and health.



9\. Statistical Analysis Plan

9.1 Stage A: Data validation and descriptive analysis



The analysis will first:



Verify the dataset structure and country restriction.

Confirm migration-group counts and definitions.

Check outcome coding and special missing-value codes.

Describe the distributions of age, education, and income.

Quantify missingness for each analytical variable.

Confirm the availability and meaning of survey weights and sampling-design variables.



Descriptive tables will present respondent counts and percentages for categorical variables and suitable summaries for continuous variables.



Health distributions will be reported separately for each migration-background group.



Weighted and unweighted descriptive estimates will be distinguished clearly.



9.2 Stage B: Primary model



The primary candidate model will be ordinal logistic regression using the five ordered health categories.



Migration background will be the principal explanatory variable.



The primary model will estimate associations between migration-background group and the odds of reporting worse rather than better health.



The proportional-odds assumption will be evaluated rather than taken for granted.



Model convergence, sparse outcome categories, influential observations, and the stability of estimates will be examined.



If the ordinal model is unsuitable, the reasons will be documented and an alternative model will be selected based on statistical and substantive justification.



9.3 Stage C: Sequential adjustment



The following sequence will be used to examine how estimates change with adjustment.



Model 1 — Unadjusted



Outcome: self-reported general health.



Predictor: migration-background group.



Purpose: describe the crude association between migration background and self-reported health.



Model 2 — Age-adjusted



Predictors:



Migration-background group.

Age.



Purpose: assess how estimated migration-group associations change after adjustment for age.



Model 3 — Education-adjusted



Predictors:



Migration-background group.

Age.

Educational attainment.



Purpose: examine whether adjustment for education changes the estimated associations further.



Model 4 — Income sensitivity model



Predictors:



Migration-background group.

Age.

Educational attainment.

Household income.



Purpose: assess whether the results are sensitive to additional income adjustment.



The sample size for every model will be reported. Differences between estimates will be interpreted alongside the changes in analytical sample size.



A change in an adjusted association will not automatically be interpreted as evidence of mediation or a causal mechanism.



9.4 Stage D: Survey weighting and variance estimation



The ESS analysis weight anweight will be evaluated as the primary candidate weight in accordance with the relevant ESS guidance.



The following decisions must be documented before final model fitting:



The precise meaning and construction of anweight.

The meaning and suitability of stratum and psu.

Whether the available sampling-design variables support design-based variance estimation.

The appropriate method for calculating standard errors and confidence intervals.

The implications of analysing the Swiss subset of the integrated ESS dataset.



The design weight, post-stratification weight, population weight, and analysis weight will not be multiplied together arbitrarily.



If the available dataset does not support defensible design-based variance estimation, that limitation will be stated explicitly and an appropriate alternative will be justified.



The final report will distinguish weighted point estimates from the method used to calculate their uncertainty.



9.5 Stage E: Age standardisation



Age standardisation will be used as a complementary analysis to facilitate comparison between migration-background groups with different age distributions.



The age-standardisation method, age strata or reference distribution, and weighting approach will be documented.



Standardised estimates will be compared with the crude descriptive results and regression-adjusted estimates.



The analysis will not assume that standardisation alone eliminates all confounding.



9.6 Stage F: Missing-data analysis



Missingness will be examined for all variables used in the models.



The analysis will report:



The number and percentage of missing observations.

The variables with the greatest missingness.

The complete-case sample size for each model.

Differences in available characteristics between respondents included in and excluded from the income-adjusted analysis, where feasible.



Complete-case analysis will be treated as potentially vulnerable to selection bias.



Multiple imputation may be considered if its assumptions are defensible and an appropriate imputation model can be specified. It will not be used automatically merely because data are missing.



The final report will distinguish observed missingness patterns from assumptions about the unobserved data.



9.7 Stage G: Sensitivity analyses



The following sensitivity analyses are planned:



Compare weighted and unweighted estimates where appropriate.

Compare the primary ordinal model with a justified alternative specification.

Assess the impact of including household income.

Investigate the consequences of the small number of very bad health responses.

Assess the influence of missing-data decisions.

Compare crude, age-adjusted, and socioeconomic-adjusted estimates.

Investigate alternative assumptions about age where justified.



Any changes to the prespecified analysis will be documented with the reason and the stage at which the decision was made.



10\. Model Diagnostics and Reporting



The following will be assessed where applicable:



Model convergence.

Proportional-odds assumption.

Sparse cells and unstable estimates.

Functional form of continuous covariates.

Multicollinearity among covariates.

Influential observations.

Suitability of the variance-estimation method.

Sensitivity to missing-data and model-specification decisions.



Results will be reported using estimated associations, confidence intervals, sample sizes, and relevant diagnostic information.



For ordinal logistic regression, odds ratios and confidence intervals will be reported with the outcome direction clearly defined.



Because higher analytical outcome values represent worse health, an odds ratio above 1 will indicate higher odds of being in a worse health category, provided the model uses the specified ordering and parameterisation.



The model's coding and interpretation will be checked explicitly before results are reported.



11\. Missing Data, Selection Bias, and Generalisability



The study recognises that survey participation and missing responses may differ across demographic and migration-background groups.



The Swiss sample may not perfectly represent every population subgroup, and survey weighting cannot automatically eliminate every source of bias.



Findings will therefore be interpreted in relation to:



The ESS target population and sampling frame.

The survey response process.

The operational migration-background definitions.

Missing-data assumptions.

The selected model and weighting approach.



Conclusions will not be generalised beyond the population and period supported by the data.



12\. Ethical Considerations



The analysis will use existing survey data and will follow the data-use conditions associated with the ESS dataset.



The project will not attempt to identify individual respondents.



Data will be analysed at the aggregate level, and the report will avoid language that stereotypes migrant or non-migrant populations.



The study will describe group-level statistical patterns without treating migration background as a deterministic explanation of an individual's health.



Any additional institutional ethics or data-governance requirements will be confirmed according to the intended academic use of the project.



13\. Reproducibility and Research Integrity



The project will retain:



The original raw data without modification.

The cleaned analytical dataset.

The data-cleaning and validation scripts.

The statistical analysis scripts.

The research protocol and a record of methodological changes.

The Python and package versions.

The data dictionary and relevant ESS documentation.

Generated tables and figures.

Model diagnostics and sensitivity-analysis outputs.

Tests that verify key assumptions and reproducibility.



The primary analysis will be run from documented scripts rather than relying exclusively on interactive commands.



The data source, dataset release, variable definitions, exclusions, transformations, weighting decisions, and modelling decisions will be reported transparently.



Random seeds will be recorded for analyses involving random procedures.



Synthetic simulations, if conducted, will be stored and labelled separately from the real ESS data. Simulation results will be used to investigate statistical behaviour and will not be presented as empirical evidence about actual populations.



14\. Limitations



Several limitations are anticipated.



First, the cross-sectional design limits temporal interpretation and does not establish causal relationships.



Second, self-reported general health is subjective and may be influenced by differences in health perception and reporting.



Third, the operational migration-background classification captures only selected aspects of migration history and parental birthplace.



Fourth, missing income information may affect the composition of the sample used for socioeconomic adjustment.



Fifth, the small number of respondents reporting very bad health may affect model stability and the precision of estimates.



Sixth, the appropriateness of the available survey-design variables and variance-estimation methods must be established before final inference.



Finally, statistical adjustment cannot guarantee the elimination of unmeasured confounding or selection bias.



These limitations will be considered when interpreting the findings and proposing future research.



15\. Planned Outputs



The final research outputs will include:



A data-source and variable-definition document.

A data-validation and missingness report.

Descriptive tables by migration-background group.

A documented survey-weighting and variance-estimation decision.

Ordinal regression results for the prespecified model sequence.

Model-diagnostic results.

Age-standardised comparisons.

Missing-data and sensitivity-analysis results.

Reproducible figures and tables.

A research report that distinguishes empirical findings, methodological assumptions, and limitations.

16\. Decision Log



The following decisions will be recorded as the analysis progresses.



Decision	Current status

Use the Swiss ESS Round 11 subset	Selected; dataset provenance to be documented fully

Use three migration-background groups	Preliminary operational classification established

Preserve five ordered health categories	Planned

Investigate ordinal logistic regression	Planned; subject to diagnostics

Use non-migrant background as reference	Planned

Evaluate anweight as the primary candidate weight	Planned; confirm against applicable ESS documentation

Finalise treatment of stratum and psu	Pending verification

Assess age adjustment	Planned

Use education in the main adjusted model	Planned

Examine income separately	Planned

Evaluate missingness and complete-case selection	Planned

Perform sensitivity analyses	Planned

Make causal claims	Not supported by the proposed design

