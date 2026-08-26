# Worldwide Governance Indicators (WGI)

**Worldwide Governance Indicators (WGI)** measures the quality of governance across countries, based on six core dimensions compiled from dozens of underlying data sources (surveys, expert assessments, NGO reports).

## Key figures

| | |
|---|---|
| Series (indicators) | 36 |
| Countries / regions | ~215 |
| Available period | 1996–2024 (biannual until 2002, annual from 2003) |
| DataBank link | [databank.worldbank.org/databases](https://databank.worldbank.org/databases/page/1/orderby/popularity/direction/desc) |

## The 6 Governance Dimensions

WGI indicators are organized around 6 official dimensions, each measured with several statistical variants (estimate, percentile rank, standard error, confidence interval bounds):

1. **Voice and Accountability (VA)** — perceptions of the extent to which citizens can participate in selecting their government, freedom of expression, association, and media
2. **Political Stability and Absence of Violence/Terrorism (PV)** — likelihood of political instability or politically motivated violence
3. **Government Effectiveness (GE)** — quality of public services, civil service, policy formulation and implementation
4. **Regulatory Quality (RQ)** — ability of the government to formulate and implement sound policies and regulations that permit private sector development
5. **Rule of Law (RL)** — confidence in and abidance by the rules of society, including contract enforcement, property rights, police, and courts
6. **Control of Corruption (CC)** — extent to which public power is exercised for private gain

For each dimension, WGI provides multiple statistical variants per code (e.g. `GOV_WGI_GE.EST` for the estimate, `GOV_WGI_GE.SC` for the score, `GOV_WGI_GE.SC_LB`/`SC_UB` for confidence bounds, `GOV_WGI_GE.SE` for standard error, `GOV_WGI_GE.SR` for the percentile rank).

## Accessing WGI in R

Same package and method as other World Bank databases — see [`world-bank/wdi/README.md`](../wdi/README.md) for general setup instructions.

```r
library(WDI)

meta <- WDIcache()
db_name <- "Worldwide Governance Indicators"
series_codes <- meta$series$indicator[meta$series$sourceDatabase == db_name]

length(series_codes)  # 36

# Example: download the Rule of Law estimate for a few countries
data <- WDI(indicator = "GOV_WGI_RL.EST", country = c("FRA", "USA", "IND"),
            start = 1996, end = 2024)
```

## Indicator categories

The 36 indicators map directly onto the 6 official governance dimensions — this covers **100%** of the indicators.

| Category | Indicators |
|---|---|
| **Voice and Accountability (VA)** | 6 |
| **Political Stability (PV)** | 6 |
| **Government Effectiveness (GE)** | 6 |
| **Regulatory Quality (RQ)** | 6 |
| **Rule of Law (RL)** | 6 |
| **Control of Corruption (CC)** | 6 |

Full indicator-to-category mapping: see [`wgi_categories.csv`](./wgi_categories.csv)

## Completeness audit

This folder contains an **exhaustive missing-values audit** of WGI: for each series and each country, which years have no available data.

### Method

Same method as the other audits in this repo — full download by batch, long-format reshaping, and per (country, series) gap detection.

> Note: this database includes an `iso2c` column, like WDI, Education Statistics, and Doing Business (unlike SPI, which does not).

See the full script: [`audit_WGI.R`](./audit_WGI.R)

### Output

The report [`missing_values_report_WGI.csv`](./missing_values_report_WGI.csv) contains one row per (country, series) pair with at least one missing year, with the same column structure as the other audits in this repo.

### General findings

WGI is **the best-covered World Bank database audited so far** in this repository — noticeably more complete than WDI, Education Statistics, Doing Business, or even SPI.

**By series**
- All 36 indicators score between **95.1% and 97.5%** completeness — an unusually narrow and high range, reflecting a small, mature, and consistently maintained set of indicators
- Rule of Law variants are the most complete (97.5%); Government Effectiveness and Regulatory Quality variants are the least complete (95.1%)

**By country**
- Dozens of countries reach **100% completeness** (e.g. United Kingdom, United States, Uruguay, Uzbekistan, Venezuela, Vietnam, Yemen, Zambia, Zimbabwe)
- Least covered: **French Polynesia (14.1%)** and **New Caledonia (16%)** — small overseas territories with limited independent governance assessments

**By year**
- Coverage was collected only in select years before 2003 (1996, 1998, 2000, 2002), reflecting WGI's original biennial methodology
- Became annual starting in 2003, with completeness climbing from ~90% to a peak around **98.9% in 2015**
- Remains consistently high (97.9%–98.8%) through the most recent year available (2024)

## Files in this folder

- `README.md` — this document
- `wgi_ready_to_use.R` — ready-to-use script to download custom country/indicator/year selections
- `audit_WGI.R` — full script (download, processing, export)
- `missing_values_report_WGI.csv` — detailed missing-values report (country x series)
- `completeness_stats_by_series_WGI.csv` — % completeness by series
- `completeness_stats_by_country_WGI.csv` — % completeness by country
- `completeness_stats_by_year_WGI.csv` — % completeness by year
- `wgi_categories.csv` — indicator-to-category mapping (by governance dimension)
