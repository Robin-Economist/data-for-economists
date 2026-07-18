# Education Statistics

**Education Statistics** is the largest database on World Bank DataBank, providing detailed data on education systems, outcomes, and financing worldwide.

## Key figures

| | |
|---|---|
| Series (indicators) | ~8,300 |
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

> ⚠️ Given the size of this database (~8,300 series, over 5x larger than WDI), a full download in batches of 20 series takes considerably longer — expect several hours, potentially spread across multiple sessions. The download script below resumes automatically if interrupted.

## Completeness audit

*(In progress — this section will be completed once the full download and audit are finished, following the same method as the [WDI completeness audit](../wdi/completeness_audit_WDI.md).)*

## Files in this folder

- `README.md` — this document
- `audit_EdStats.R` — full script (download, processing, export)
- `missing_values_report_EdStats.csv` — detailed missing-values report *(coming soon)*
- `completeness_stats_by_series_EdStats.csv` — % completeness by series *(coming soon)*
- `completeness_stats_by_country_EdStats.csv` — % completeness by country *(coming soon)*
- `completeness_stats_by_year_EdStats.csv` — % completeness by year *(coming soon)*
