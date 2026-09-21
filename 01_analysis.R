# 2023 national YRBS: import, recode, survey analysis, quality checks, and figures.
# Run from the project root: Rscript R/01_analysis.R


options(survey.lonely.psu = 'adjust', survey.adjust.domain.lonely = TRUE)
stopifnot(requireNamespace('survey', quietly = TRUE), requireNamespace('ggplot2', quietly = TRUE))

dir.create('outputs', showWarnings = FALSE); dir.create('figures', showWarnings = FALSE)

d <- read.csv('data/XXHq.txt', stringsAsFactors = FALSE, na.strings = c('', 'NA'), check.names = FALSE)
qn <- read.csv('data/XXHqn.txt', stringsAsFactors = FALSE, na.strings = c('', 'NA'), check.names = FALSE)
stopifnot(nrow(d) == nrow(qn), !anyDuplicated(d$record), !anyDuplicated(qn$record))

idx <- match(d$record, qn$record)
stopifnot(!anyNA(idx), identical(as.numeric(d$record), as.numeric(qn$record[idx])))

qn <- qn[idx, , drop=FALSE]
stopifnot(nrow(d) == 20103L, all(c('weight','stratum','psu','q27','q28','q29','q99','q103','q104') %in% names(d)))
for (v in c('raceeth','q1','q2','q3','q20','q24','q25','q26','q27','q28','q29','q43','q46','q84','q85','q86','q99','q100','q101','q103','q104','weight','stratum','psu')) d[[v]] <- suppressWarnings(as.numeric(d[[v]]))


# Raw responses are numeric A=1, B=2, etc. Invalid and blank responses are NA.
indicator <- function(x, yes, valid) ifelse(x %in% valid, as.numeric(x %in% yes), NA_real_)
d$seriously_considered <- indicator(d$q27, 1, 1:2)
d$make_a_plan <- indicator(d$q28, 1, 1:2)
d$attempted <- indicator(d$q29, 2:5, 1:5)


# Derived file is aligned by record, then validated against independently recoded raw answers.
comparison <- list('Seriously considered'=c('seriously_considered','QN27'), 'Make a plan'=c('make_a_plan','QN28'), 'Attempted'=c('attempted','QN29'))
concordance <- do.call(rbind, lapply(names(comparison), function(label) {
  raw <- d[[comparison[[label]][1]]]; derived <- indicator(as.numeric(qn[[comparison[[label]][2]]]),1,1:2)
  mismatch <- sum(is.na(raw) != is.na(derived) | (!is.na(raw) & !is.na(derived) & raw != derived))
  data.frame(outcome=label,raw_nonmissing=sum(!is.na(raw)),derived_nonmissing=sum(!is.na(derived)),mismatches=mismatch)
}))

write.csv(concordance,'outputs/raw_derived_concordance.csv',row.names=FALSE)
stopifnot(all(concordance$mismatches==0))


# Use the supplied derived indicators for all estimates after the concordance check.
d$seriously_considered <- indicator(as.numeric(qn$QN27),1,1:2)
d$make_a_plan <- indicator(as.numeric(qn$QN28),1,1:2)
d$attempted <- indicator(as.numeric(qn$QN29),1,1:2)
outcomes <- c('seriously_considered','make_a_plan','attempted')
outcome_labels <- c('Seriously considered','Make a plan','Attempted')
d$sex <- factor(d$q2, levels = 1:2, labels = c('Female','Male'))
d$grade <- factor(d$q3, levels = 1:4, labels = paste0(9:12, c('th','th','th','th'), ' grade'))
d$race_group <- as.character(d$raceeth)
d$race_group[d$raceeth %in% 6:7] <- 'Hispanic/Latino, any race'
race_names <- c('1'='AI/AN, non-Hispanic','2'='Asian, non-Hispanic','3'='Black, non-Hispanic','4'='NH/PI, non-Hispanic','5'='White, non-Hispanic','8'='Multiracial, non-Hispanic')
for (key in names(race_names)) d$race_group[d$race_group == key] <- race_names[[key]]
d$race_group[is.na(d$raceeth)] <- NA_character_


# Every grouping is defined on a specific survey response; no missing answers are set to no.
groups <- list(
  'Sex'=list('Female'=d$q2==1,'Male'=d$q2==2),
  'Grade'=setNames(lapply(1:4, function(k) d$q3==k), paste0(9:12,'th grade')),
  'Race/ethnicity'=list('AI/AN, non-Hispanic'=d$raceeth==1,'Asian, non-Hispanic'=d$raceeth==2,'Black, non-Hispanic'=d$raceeth==3,'NH/PI, non-Hispanic'=d$raceeth==4,'White, non-Hispanic'=d$raceeth==5,'Hispanic/Latino, any race'=d$raceeth %in% c(6,7),'Multiracial, non-Hispanic'=d$raceeth==8),
  'School bullying'=list('Yes'=d$q24==1,'No'=d$q24==2),
  'Electronic bullying'=list('Yes'=d$q25==1,'No'=d$q25==2),
  'Sexual violence, past year'=list('One or more times'=d$q20 %in% 2:5,'Zero times'=d$q20==1),
  'Sad or hopeless'=list('Yes'=d$q26==1,'No'=d$q26==2),
  'Poor mental health, past 30 days'=list('Most/always'=d$q84 %in% 4:5,'Never/rarely/sometimes'=d$q84 %in% 1:3),
  'Binge drinking, past 30 days'=list('One or more days'=d$q43 %in% 2:7,'Zero days'=d$q43==1),
  'Ever used marijuana'=list('Yes'=d$q46 %in% 2:7,'No'=d$q46==1),
  'School-night sleep'=list('Under 8 hours'=d$q85 %in% 1:4,'8 or more hours'=d$q85 %in% 5:7),
  'Unstable housing, past 30 days'=list('Yes'=d$q86 %in% 2:6,'No, including elsewhere'=d$q86 %in% c(1,7)),
  'Household adult substance problem'=list('Yes'=d$q100==1,'No'=d$q100==2),
  'Household adult mental illness/suicidality'=list('Yes'=d$q101==1,'No'=d$q101==2),
  'Adult met basic needs'=list('Most/always'=d$q99 %in% 4:5,'Never/rarely/sometimes'=d$q99 %in% 1:3),
  'Feel close to school people'=list('Agree/strongly agree'=d$q103 %in% 1:2,'Unsure/disagree'=d$q103 %in% 3:5),
  'Family knows whereabouts'=list('Most/always'=d$q104 %in% 4:5,'Never/rarely/sometimes'=d$q104 %in% 1:3)
)


# Restrict to records with usable weight and design variables; none expected in these files.
d$record_id <- seq_len(nrow(d)); excluded_design <- !is.finite(d$weight) | d$weight <= 0 | !is.finite(d$stratum) | !is.finite(d$psu)
if (any(excluded_design)) d <- d[!excluded_design, , drop=FALSE]
design <- survey::svydesign(ids=~psu, strata=~stratum, weights=~weight, data=d, nest=TRUE)


# Domain estimates: subset the full design, retain design-based SE, use t(PSU-strata).
df_design <- survey::degf(design)
calc <- function(variable, mask=rep(TRUE,nrow(d)), group='Overall', category='All') {
  ids <- which(!is.na(mask) & mask & !is.na(d[[variable]]))
  if (length(ids) < 2) return(data.frame(group=group,category=category,outcome=outcome_labels[match(variable,outcomes)],n=length(ids),percent=NA,lower=NA,upper=NA))
  sub <- subset(design, record_id %in% d$record_id[ids])
  a <- survey::svymean(as.formula(paste0('~',variable)), sub, na.rm=TRUE)
  p <- as.numeric(coef(a)); se <- as.numeric(survey::SE(a)); half <- qt(.975,df_design)*se
  data.frame(group=group,category=category,outcome=outcome_labels[match(variable,outcomes)],n=length(ids),percent=100*p,lower=100*max(0,p-half),upper=100*min(1,p+half))
}
results <- do.call(rbind, lapply(seq_along(outcomes), function(j) {
  v <- outcomes[j]; rows <- list(calc(v))
  for (section in names(groups)) for (cat in names(groups[[section]])) rows[[length(rows)+1L]] <- calc(v, groups[[section]][[cat]],section,cat)
  do.call(rbind,rows)
}))

write.csv(results,'outputs/prevalence_by_group.csv',row.names=FALSE)


# Mutually exclusive joint patterns on a complete-response denominator.
complete <- complete.cases(d[,outcomes]); pattern <- ifelse(complete, d$seriously_considered + 2*d$make_a_plan + 4*d$attempted, NA_real_)
pattern_labels <- c('None of three','Seriously considered only','Make a plan only','Seriously considered + Make a plan','Attempted only','Seriously considered + Attempted','Make a plan + Attempted','All three')
co <- do.call(rbind,lapply(0:7,function(k) {
  vv <- paste0('pattern_',k); d[[vv]] <- ifelse(complete,as.numeric(pattern==k),NA_real_)
  dd <- design; dd$variables$temp <- d[[vv]]
  a <- survey::svymean(~temp,subset(dd, !is.na(temp))); p <- as.numeric(coef(a)); half <- qt(.975,df_design)*as.numeric(survey::SE(a))
  data.frame(pattern=pattern_labels[k+1],n=sum(pattern==k,na.rm=TRUE),percent=100*p,lower=100*max(0,p-half),upper=100*min(1,p+half))
}))

write.csv(co,'outputs/cooccurrence.csv',row.names=FALSE)

selected <- c('weight','stratum','psu','q2','q3','raceeth','q27','q28','q29','q20','q24','q25','q26','q43','q46','q84','q85','q86','q99','q100','q101','q103','q104')
quality <- data.frame(variable=selected,nonmissing=sapply(d[selected],function(z)sum(!is.na(z))),missing=sapply(d[selected],function(z)sum(is.na(z))),missing_percent=100*sapply(d[selected],function(z)mean(is.na(z))))
derived_quality <- data.frame(variable=c('QN27','QN28','QN29'),nonmissing=sapply(qn[c('QN27','QN28','QN29')],function(z)sum(!is.na(z))),missing=sapply(qn[c('QN27','QN28','QN29')],function(z)sum(is.na(z))),missing_percent=100*sapply(qn[c('QN27','QN28','QN29')],function(z)mean(is.na(z))))
quality <- rbind(quality, derived_quality)
write.csv(quality,'outputs/data_quality.csv',row.names=FALSE)
writeLines(c(sprintf('Source records: %s',nrow(d)+sum(excluded_design)),sprintf('Excluded for missing/nonpositive weight or missing design variable: %s',sum(excluded_design)),sprintf('Complete responses on all three outcomes: %s',sum(complete)),sprintf('Weight range: %.3f to %.3f; median %.3f; sum %.1f',min(d$weight),max(d$weight),median(d$weight),sum(d$weight)),sprintf('Strata: %s; distinct stratum/PSU pairs: %s; design degrees of freedom: %s',length(unique(d$stratum)),nrow(unique(d[c('stratum','psu')])),df_design),'Raw and derived data matched by unique record ID; QN27, QN28, QN29 each have zero discrepancies from raw recodes.', 'Missing outcome responses are excluded separately for each prevalence estimate.','Q27=1: Seriously considered; Q28=1: Make a plan; Q29=2:5: Attempted.','Race codes 6 and 7 combined as Hispanic/Latino; school support and family support categories are collapsed as specified in README.'),'outputs/quality_summary.txt')


# Four publication-ready figures  Each regenerate from the computed tables.
palette <- c('Seriously considered'='#247294','Make a plan'='#C67325','Attempted'='#8E4B79')
base_theme <- ggplot2::theme_minimal(base_size=12)+ggplot2::theme(panel.grid.minor=ggplot2::element_blank(),
                                                                  legend.position='bottom',plot.title=ggplot2::element_text(face='bold'),axis.text.y=ggplot2::element_text(color='#222222'))

saveplot <- function(data,title,file) {
  data$outcome <- factor(data$outcome,levels=outcome_labels)
  data$label <- ifelse(data$group=='Overall',data$category,paste(data$group,data$category,sep=': '))
  data$label <- factor(data$label,levels=rev(unique(data$label)))
  g <- ggplot2::ggplot(
    data,
    ggplot2::aes(y = label, x = percent, color = outcome)
  ) +
    ggplot2::geom_point(
      position = ggplot2::position_dodge(width = .65),
      size = 2.5
    ) +
    ggplot2::geom_errorbar(
      ggplot2::aes(xmin = lower, xmax = upper),
      position = ggplot2::position_dodge(width = .65),
      orientation = "y",
      width = .18
    ) +
    ggplot2::scale_color_manual(values = palette, drop = FALSE) +
    ggplot2::labs(
      title = title,
      x = "Weighted prevalence (%) with 95% design-based CI",
      y = NULL,
      color = NULL,
      caption = "2023 national YRBS; valid respondents for each outcome and group"
    ) +
    base_theme
  ggplot2::ggsave(file,g,width=10,height=max(3.6, .36*length(unique(data$label))+2),device='png',dpi=300)
}

saveplot(results[results$group=='Overall',],'National prevalence','figures/figure_1_overall.png')
saveplot(results[results$group %in% c('Sex','Grade'),],'Sex and grade','figures/figure_2_demographics.png')
saveplot(results[results$group %in% c('School bullying','Electronic bullying','Sexual violence, past year','Poor mental health, past 30 days'),],'Lived experiences and health','figures/figure_3_experiences.png')
saveplot(results[results$group %in% c('Adult met basic needs','Feel close to school people','Family knows whereabouts'),],'Measured supports and protection potential','figures/figure_4_supports.png')
cat('Analysis complete. Render with: Rscript -e "rmarkdown::render(\'report.Rmd\')"\n')
