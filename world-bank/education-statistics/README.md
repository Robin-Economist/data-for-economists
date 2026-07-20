# Education Statistics

**Education Statistics** is the largest database on World Bank DataBank, providing detailed data on education systems, outcomes, and financing worldwide.

## Key figures

| | |
|---|---|
| Series (indicators) | 8,308 |
| Countries / regions | ~265 |
| Available period | 1960 – 2025 (varies by series) |
| DataBank link | [databank.worldbank.org](https://databank.worldbank.org/databases/page/1/orderby/popularity/direction/desc) |

## Topics covered

Education Statistics covers enrollment rates, literacy, education expenditure, teacher-to-student ratios, completion rates, and outcomes, broken down by level of education (pre-primary, primary, secondary, tertiary), gender, and location (rural/urban).

## Accessing Education Statistics in R

Same package and method as WDI — see [`world-bank/wdi/README.md`](../wdi/README.md) for general setup instructions.

```r
library(WDI)

meta <- WDIcache()
db_name <- "Education Statistics"
series_codes <- meta$series$indicator[meta$series$sourceDatabase == db_name]

length(series_codes)  # ~8,300

# Example: download one indicator for a few countries
data <- WDI(indicator = "SE.ADT.LITR.ZS", country = c("FRA", "USA", "IND"),
            start = 1960, end = 2025)
```

> ⚠️ Given the size of this database (8,308 series, over 5x larger than WDI), a full download in batches of 20 series takes considerably longer than WDI — expect several hours, potentially spread across multiple sessions. In practice, downloading all 416 batches for this audit took approximately **36 hours**, due to recurring World Bank API instability (timeouts, `400`/`502` errors) requiring several retry passes. The download script below resumes automatically if interrupted, so it can safely be run across multiple sessions without losing progress.

## Indicator categories

With 8,308 series, browsing indicators one by one isn't practical. Since the World Bank API doesn't expose an official thematic classification, indicators were grouped into broad categories based on their **code prefixes** (e.g. `SE.PRM.*` for primary enrollment, `LO.PISA.*` for PISA test scores) — a convention the World Bank itself uses consistently when naming series.

This covers **93.7%** of all 8,308 indicators; the remainder (6.3%) uses less common prefixes and falls under "Other / Uncategorized."

| Category | Indicators | % of total | Examples |
|---|---|---|---|
| **Enrollment & Completion** | 2,869 | 34.5% | Enrollment rates, completion rates, dropout rates by education level |
| **UNESCO (UIS) Enrollment & Efficiency** | 1,637 | 19.7% | UNESCO Institute for Statistics indicators — repetition, graduation, and attendance rates |
| **Learning Outcomes & Test Scores** | 1,165 | 14.0% | Standardized international assessments (PISA, TIMSS, PASEC, PIRLS, PIAAC, EGRA...) |
| **Expenditure & Personnel** | 801 | 9.6% | Education spending, teacher counts, salaries, pupil-teacher ratios |
| *Other / Uncategorized* | 522 | 6.3% | Less common or highly specific indicators |
| **Barro-Lee Educational Attainment** | 426 | 5.1% | Historical educational attainment by cohort (Barro-Lee dataset) |
| **Projections** | 308 | 3.7% | Forward-looking population and attainment projections |
| **Household Surveys** | 250 | 3.0% | Indicators from DHS (Demographic and Health Surveys) and MICS (Multiple Indicator Cluster Surveys) |
| **Population (general demographics)** | 180 | 2.2% | General population figures, not education-specific |
| **SABER (System Assessment)** | 150 | 1.8% | Systems Approach for Better Education Results — qualitative system assessments |

Full indicator-to-category mapping: see [`education_statistics_categories.csv`](./education_statistics_categories.csv)



This folder contains an **exhaustive missing-values audit** of Education Statistics: for each series and each country, which years have no available data.

### Method

Same method as the [WDI completeness audit](../wdi/completeness_audit_WDI.md):
1. Downloaded the entirety of the 8,308 series, all countries, 1960–2025, in batches of 20 series (416 batches total)
2. Reshaped the data into long format (one row = indicator × country × year)
3. Computed a missing/present status for every combination
4. Grouped missing years into readable ranges per (country, series) pair

See the full script: [`audit_EdStats_final.R`](./audit_EdStats_final.R)

### Output

The report [`missing_values_report_EdStats.zip`](./missing_values_report_EdStats.zip) contains one row per (country, series) pair with at least one missing year, with the same column structure as the WDI report.

> Note: this file is provided as a `.zip` archive (rather than a raw `.csv`) due to its size (~141 MB uncompressed) exceeding GitHub's 25 MB upload limit for standard file uploads. Unzip it locally before use.

### General findings

> ⚠️ **This database is dramatically less complete than WDI.** Where WDI's best-covered series reach 99.6% completeness and its best-covered countries approach 50%, Education Statistics tops out at **70.1%** for its best series and **6.7%** for its best-covered countries. This reflects the nature of the database: thousands of highly specific indicators (detailed ratios by education level, precise financing breakdowns) that were realistically never collected for most countries, rather than a data quality failure.

**By series**
- Best series (education population counts, e.g. `SP.PRM.TOTL.IN`): **70.1%** completeness
- Worst series (very specific indicators, e.g. teacher salary/recruitment stats `PER.JR.*`): **0%** completeness — essentially never reported for any country

**By country**
- Best-covered: **Peru and Costa Rica (6.7%)**, followed by Colombia (6.6%), Dominican Republic (6.4%) — Latin American countries dominate, consistent with WDI
- Least-covered: small territories (Anguilla, Channel Islands, Faroe Islands, Isle of Man...) at 0%

**By year**
- The database is close to **0% complete for most of the 1960s** (1961-1964, 1966-1969 all show 0%)
- Completeness peaks around **2010 (10.5%)**, the best-documented year across the whole series
- Drops back toward 0% for 2022-2024, likely reflecting indicators not yet updated with recent data

## Files in this folder

- `README.md` — this document
- `edstats_ready_to_use.R` — ready-to-use script to download custom country/indicator/year selections
- `audit_EdStats_final.R` — full script (download, processing, export)
- `missing_values_report_EdStats.zip` — detailed missing-values report (country x series), zipped due to file size
- `completeness_stats_by_series_EdStats.csv` — % completeness by series
- `completeness_stats_by_country_EdStats.csv` — % completeness by country
- `completeness_stats_by_year_EdStats.csv` — % completeness by year
