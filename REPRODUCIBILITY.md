# Reproducibility Guide

## Data access
Uses European Social Survey Round 11 Edition 4.2 data for Switzerland. Obtain the authorized dataset independently and follow ESS access and citation requirements.

Expected input: data/raw/ESS11e04_2-subset.csv

## Software
Install Python dependencies with: python -m pip install -r requirements.txt
Install R packages with: install.packages(c('survey', 'ordinal'))

## Running the analysis
Review numbered scripts in src/ and run them in their intended order. The complete workflow has not yet been independently verified from a fresh installation.

## Data protection
Raw data, processed respondent-level data, local environments, backups, and CSV outputs are excluded from Git by the current ignore rules. Review outputs before sharing.

## Limitations
The survey variance specification remains provisional. The proportional-odds assumption is inconclusive, the quadratic-age finding is exploratory, and missing income data may affect complete-case analyses. This observational study does not establish causal effects.
