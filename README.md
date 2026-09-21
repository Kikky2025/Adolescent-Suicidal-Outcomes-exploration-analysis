# 2023 national YRBS: suicidal outcomes

Reproducible descriptive analysis of self-reported **Seriously considered**, **Make a plan**, and **Attempted** in the preceding 12 months among US students in grades 9–12 attending public and private schools. The raw and derived data, documentation, code, and report source are included. Running the R script generates four PNG figure images.

## Software

R 4.2 or later; R packages `survey`, `ggplot2`, `rmarkdown`, `knitr`. To create a PDF from R Markdown, also install a LaTeX distribution such as TinyTeX. An HTML report needs Pandoc, normally included with RStudio or Quarto; `rmarkdown::find_pandoc()` can check availability.

Install packages in a writable R environment:

```r
install.packages(c('survey', 'ggplot2', 'rmarkdown', 'knitr'))
```

## Exact run instructions

Unzip the project and **change into its top-level folder**, the folder containing this README. On a shell with R available:

```sh
Rscript R/01_analysis.R
Rscript -e "rmarkdown::render('report.Rmd', output_format='html_document', output_file='report.html')"
```

For PDF output, after installing LaTeX:

```sh
Rscript -e "rmarkdown::render('report.Rmd', output_format='pdf_document', output_file='report.pdf')"
```

The script recreates `outputs/prevalence_by_group.csv`, `outputs/cooccurrence.csv`, `outputs/data_quality.csv`, `outputs/raw_derived_concordance.csv`, `outputs/quality_summary.txt`, and four high-resolution PNG figures. The checked CSV tables and PNG previews are included to make the findings inspectable before running R. This delivery environment did not have R installed, so execution of the R script and rendering of `report.Rmd` could not be verified here. The included initial tables and figures were independently calculated from the same supplied records; the R run regenerates them from source. Rounded figures may differ slightly if R's domain variance calculation differs from the independent calculation.

## Structure

- `data/XXHq.txt`: supplied national raw student responses and design variables.
- `data/XXHqn.txt`: supplied derived indicator data, joined to raw responses by unique `record`; QN27–QN29 are used after checking exact concordance.
- `docs/`: supplied 2023 national YRBS guide and questionnaire.
- `R/01_analysis.R`: import, cleaning, recoding, survey estimates, quality summary and plots.
- `outputs/`: analysis tables, quality summary, and public-health insight report.
- `figures/`: four publication-ready PNG images generated on each R run at 300 dpi.
- `report.Rmd`: R Markdown research report with Abstract, Introduction, Methodology, Results, and Conclusion and Recommendation.

## Coding and interpretation

Q27=1 indicates **Seriously considered**; Q28=1 indicates **Make a plan**; Q29=2–5 indicates **Attempted**, with Q29=1 meaning zero attempts. Only valid responses contribute to the outcome-specific denominator. Eight mutually exclusive overlap patterns require valid answers to all three. The script writes `outputs/raw_derived_concordance.csv` and stops if any derived outcome differs from the raw recode. The guide's `weight`, `stratum`, and `psu` fields define the sample weighting and clustering. The questionnaire's printed numbering is not always identical to the data guide's coded variable numbering; consult the coded guide for variable definitions. See `outputs/data_quality_summary.md` for selected-variable missingness, grouping decisions, and limitations.
