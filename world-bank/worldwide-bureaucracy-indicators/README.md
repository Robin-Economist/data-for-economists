# Worldwide Bureaucracy Indicators (WWBI)

**Worldwide Bureaucracy Indicators (WWBI)** measures the size, wage bill, and demographic composition of public sector employment across countries — essentially, a cross-country dataset on who works for the government, how much they're paid, and how that compares to the private sector.

## Key figures

| | |
|---|---|
| Series (indicators) | 302 |
| Countries / regions | ~200 |
| Available period | Mostly 2000–2021, varies significantly by country and survey wave |
| DataBank link | [databank.worldbank.org/databases](https://databank.worldbank.org/databases/page/1/orderby/popularity/direction/desc) |

## Topics covered

WWBI is built from harmonized household and labor force surveys, tracking public sector employment relative to the private sector, wage premiums, and demographic characteristics (age, gender, education) of public employees across sub-sectors (core public administration, education, health).

## Accessing WWBI in R

Same package and method as other World Bank databases — see [`world-bank/wdi/README.md`](../wdi/README.md) for general setup instructions.

```r
library(WDI)

meta <- WDIcache()
db_name <- "Worldwide Bureaucracy Indicators"
series_codes <- meta$series$indicator[meta$series$sourceDatabase == db_name]

length(series_codes)  # 302

# Example: download public sector employment share for a few countries
data <- WDI(indicator = "BI.EMP.TOTL.PB.ZS", country = c("FRA", "USA", "IND"),
            start = 2000, end = 2021)
```

## Indicator categories

The 302 indicators were grouped by code prefix into 4 categories — this covers **100%** of the indicators.

| Category | Indicators | % of total | Description |
|---|---|---|---|
| **Public Workforce Demographics** | 132 | 43.7% | Age, gender, and education breakdowns of public employees, by sub-sector (core administration, education, health) |
| **Wages & Pay Compression** | 93 | 30.8% | Public sector wage levels and pay compression ratios between occupations (e.g. judge vs. clerk, doctor vs. clerk) |
| **Employment Composition** | 76 | 25.2% | Share of public vs. private employment, by industry |
| **Sample Metadata** | 1 | 0.3% | Underlying survey sample size |

Full indicator-to-category mapping: see [`wwbi_categories.csv`](./wwbi_categories.csv)

## Completeness audit

This folder contains an **exhaustive missing-values audit** of WWBI: for each series and each country, which years have no available data.

### Method

Same method as the other audits in this repo — full download by batch, long-format reshaping, and per (country, series) gap detection.

See the full script: [`audit_WWBI.R`](./audit_WWBI.R)

### Output

The report [`missing_values_report_WWBI.csv`](./missing_values_report_WWBI.csv) contains one row per (country, series) pair with at least one missing year, with the same column structure as the other audits in this repo.

### General findings

WWBI is a **niche, survey-based database** — noticeably less complete than WDI or WGI, similar in spirit to Education Statistics: many highly specific indicators that were realistically only ever collected for a subset of countries and years, since they depend on detailed household/labor surveys rather than universal administrative reporting.

**By series**
- Best-covered: general population reference series (`SP.POP.TOTL`, `SP.POP.0014.TO`) at **61.5%** — these are context indicators, not bureaucracy-specific
- Worst-covered: detailed demographic breakdowns of public employment by narrow category (e.g. `BI.EMP.PWRK.PB.ZS`, `BI.EMP.TOTL.PB.FE.ZS`) at **6%** — reflecting how granular and survey-dependent these indicators are

**By country**
- Best-covered countries reach only around **46.8%** (e.g. France, Guinea, Iceland) — consistent with a database built from irregular survey waves rather than continuous administrative data
- Least-covered are countries with limited or no household survey infrastructure for public-sector-specific questions

**By year**
- Data is essentially absent before 2000
- Coverage builds up through the 2000s and 2010s as more countries' survey waves were incorporated, with no single "best year" standing out sharply — reflecting the patchwork, survey-driven nature of this database (unlike WDI or WGI, which have steady annual collection)

## Files in this folder

- `README.md` — this document
- `wwbi_ready_to_use.R` — ready-to-use script to download custom country/indicator/year selections
- `audit_WWBI.R` — full script (download, processing, export)
- `missing_values_report_WWBI.csv` — detailed missing-values report (country x series)
- `completeness_stats_by_series_WWBI.csv` — % completeness by series
- `completeness_stats_by_country_WWBI.csv` — % completeness by country
- `completeness_stats_by_year_WWBI.csv` — % completeness by year
- `wwbi_categories.csv` — indicator-to-category mapping
