# Data quality and coding summary

**Source and records.** The attached 2023 national YRBS raw file has 20,103 rows. Its school-based target is students in grades 9–12 at US public and private schools. No records have missing or nonpositive survey weight, stratum, or PSU; thus there are no design-variable exclusions. The student weights sum to approximately the sample size and do not represent a count of all US students. See `quality_summary.txt` for the range, strata, and PSU count.

**Outcome denominators.** Q27=1 means **Seriously considered**; Q28=1 means **Make a plan**; Q29=2–5 means **Attempted** (Q29=1 is zero times). Item missingness is excluded separately. The eight-category overlap table requires all three responses; 17,603 records qualify. The derived `XXHqn` file is joined using the unique `record` ID. Its QN27, QN28 and QN29 indicators match the raw recodes exactly (zero discordant or differently missing records), and the derived indicators are used for prevalence and overlap. The script writes an explicit concordance table and stops if this check fails. The guide's coding, including variable numbering, takes precedence over the printed questionnaire where numbering differs.

**Other decisions.** Q2 reports female/male sex, not gender identity. Q3 grades 1–4 map to 9th–12th. `raceeth` 6 and 7 are pooled as Hispanic/Latino, any race; the remaining categories preserve the guide's labels. School bullying and electronic bullying are past-year yes/no; sexual violence is at least one time versus zero; sadness/hopelessness is the questionnaire's activity-limiting two-week item. Q84 poor mental health is most/always versus never/rarely/sometimes; Q43 binge drinking is at least one day versus zero in the past 30 days; Q46 marijuana is lifetime any versus zero. Sleep is under 8 versus at least 8 hours. Q86 unstable housing is codes 2–6; code 7 (“somewhere else”) joins code 1 in the guide's comparison category. Q99 and Q104 use most/always versus never/rarely/sometimes. Q103 school closeness uses agree/strongly agree versus unsure/disagree/strongly disagree. Missing answers to a grouping item are excluded from that comparison. The support variables are not combined into a validated scale.

**Uncertainty and exclusions.** Estimates use survey weights and stratified PSU clustering. Confidence intervals are approximate and small race/ethnicity or housing subgroups have low precision. This is descriptive cross-sectional analysis; associations can reflect confounding, differential nonresponse, and reporting. No record-level imputation or adjustment for multiple comparisons was performed.

## Selected-variable missingness

| Variable | Nonmissing n | Missing n | Missing % |
|---|---:|---:|---:|
| weight | 20,103 | 0 | 0.0 |
| stratum | 20,103 | 0 | 0.0 |
| psu | 20,103 | 0 | 0.0 |
| q2 | 19,945 | 158 | 0.8 |
| q3 | 19,910 | 193 | 1.0 |
| raceeth | 19,733 | 370 | 1.8 |
| q27 | 19,667 | 436 | 2.2 |
| q28 | 18,366 | 1,737 | 8.6 |
| q29 | 19,336 | 767 | 3.8 |
| q20 | 15,752 | 4,351 | 21.6 |
| q24 | 19,902 | 201 | 1.0 |
| q25 | 19,898 | 205 | 1.0 |
| q26 | 19,863 | 240 | 1.2 |
| q43 | 15,441 | 4,662 | 23.2 |
| q46 | 16,603 | 3,500 | 17.4 |
| q84 | 15,705 | 4,398 | 21.9 |
| q85 | 17,441 | 2,662 | 13.2 |
| q86 | 14,541 | 5,562 | 27.7 |
| q99 | 15,750 | 4,353 | 21.7 |
| q100 | 13,227 | 6,876 | 34.2 |
| q101 | 13,305 | 6,798 | 33.8 |
| q103 | 11,177 | 8,926 | 44.4 |
| q104 | 10,850 | 9,253 | 46.0 |
| QN27 | 19,667 | 436 | 2.2 |
| QN28 | 18,366 | 1,737 | 8.6 |
| QN29 | 19,336 | 767 | 3.8 |
