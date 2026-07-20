# Doing Business

**Doing Business** was a World Bank flagship report measuring the ease of doing business across countries (and, for some indicators, specific major cities), based on regulatory indicators such as starting a business, getting credit, paying taxes, and resolving insolvency.

> ⚠️ **This program was discontinued.** The World Bank stopped publishing the Doing Business report in September 2021, following an internal audit that found irregularities in how some country rankings had been calculated (notably affecting China and Saudi Arabia in the 2018 edition). The World Bank has since been developing a successor program, *Business Ready (B-READY)*. This database is kept here for historical reference — see the year range below.

## Key figures

| | |
|---|---|
| Series (indicators) | 190 |
| Countries / regions | includes some major cities (e.g. Beijing, Delhi, Lahore, Los Angeles) in addition to countries |
| Available period | 2003 – 2019 (17 years — matches the program's active lifespan) |
| DataBank link | [databank.worldbank.org/databases](https://databank.worldbank.org/databases/page/1/orderby/popularity/direction/desc) |

## Topics covered

Regulatory indicators grouped around: starting a business, construction permits, electricity access, registering property, getting credit, protecting minority investors, paying taxes, trading across borders, enforcing contracts, and resolving insolvency.

## Accessing Doing Business in R

Same package and method as WDI — see [`world-bank/wdi/README.md`](../wdi/README.md) for general setup instructions.

```r
library(WDI)

meta <- WDIcache()
db_name <- "Doing Business"
series_codes <- meta$series$indicator[meta$series$sourceDatabase == db_name]

length(series_codes)  # 190

# Example: download one indicator for a few countries
data <- WDI(indicator = "IC.REG.MIN.CAP", country = c("FRA", "USA", "IND"),
            start = 2003, end = 2019)
```

## Completeness audit

This folder contains an **exhaustive missing-values audit** of Doing Business: for each series and each country, which years have no available data.

### Method

Same method as the [WDI](../wdi/completeness_audit_WDI.md) and [Education Statistics](../education-statistics/README.md) audits — full download by batch, long-format reshaping, and per (country, series) gap detection.

See the full script: [`audit_DoingBusiness.R`](./audit_DoingBusiness.R)

### Output

The report [`missing_values_report_DoingBusiness.csv`](./missing_values_report_DoingBusiness.csv) contains one row per (country, series) pair with at least one missing year, with the same column structure as the WDI and Education Statistics reports.

### General findings

Doing Business is **better covered than Education Statistics**, likely because it is a smaller, more focused, and more recently discontinued database — but still noticeably below WDI.

**By series**
- Best series (e.g. `IC.REG.MIN.CAP`, `IC.REG.DFRN.PC.DFRN`, several insolvency-resolution indicators): **99.6%** completeness
- Worst series (several ranking indicators tied to the discontinued "Doing Business 2019" ranking methodology, `*.RK.DB19`): **5.2%** completeness

**By country**
- Least covered: **Liechtenstein (9.1%)**, Somalia (23.3%), Libya (32.6%) — small or lower-capacity states
- Notably, several **cities** appear among the least-covered entities (Chittagong, Kano, Los Angeles, Beijing, Delhi, Lahore) — Doing Business uniquely tracked some indicators at the city level for large countries, not just nationally
- Best covered: a large group of countries tied at **55.8%** (Switzerland, Thailand, Uganda, Ukraine, United Kingdom, Zambia, and others)

**By year**
- Completeness starts low (**12.4% in 2003**, the program's first year) and climbs steadily as data collection matured
- Peaks at **80.8% in 2019**, the last year before discontinuation — consistent with a program that improved its data collection over time before being shut down

## Files in this folder

- `README.md` — this document
- `audit_DoingBusiness.R` — full script (download, processing, export)
- `missing_values_report_DoingBusiness.csv` — detailed missing-values report (country x series)
- `completeness_stats_by_series_DoingBusiness.csv` — % completeness by series
- `completeness_stats_by_country_DoingBusiness.csv` — % completeness by country
- `completeness_stats_by_year_DoingBusiness.csv` — % completeness by year
