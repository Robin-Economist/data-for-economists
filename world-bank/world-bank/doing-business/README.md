# Doing Business

**Doing Business** was a World Bank flagship report measuring the ease of doing business across countries (and, for some indicators, specific major cities), based on regulatory indicators such as starting a business, getting credit, paying taxes, and resolving insolvency.

> ⚠️ **This program was discontinued.** On September 16, 2021, the World Bank Group announced it would discontinue the Doing Business report, following an independent investigation into data irregularities in the 2018 and 2020 editions. The investigation found that Bank management had pressured staff to alter data affecting the rankings of **China** (Doing Business 2018 — Starting a Business, Getting Credit, and Paying Taxes indicators) and **Azerbaijan, Saudi Arabia, and the United Arab Emirates** (Doing Business 2020 — various indicators). Irregularities were first reported internally in June 2020, prompting a pause in publication before the final discontinuation announcement in September 2021. The World Bank has since launched a successor program, *Business Ready (B-READY)*, starting in spring 2024. This database is kept here for historical reference — see the year range below. Source: [World Bank official statement, September 16, 2021](https://www.worldbank.org/en/news/statement/2021/09/16/world-bank-group-to-discontinue-doing-business-report).

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

## Indicator categories

Doing Business indicators map closely onto the program's official regulatory themes. Categories below were built from code prefixes (e.g. `IC.REG.*` for business registration, `PAY.TAX.*` for tax indicators) — this covers **100%** of the 190 indicators, with no uncategorized remainder.

| Category | Indicators | % of total |
|---|---|---|
| **Trading Across Borders** | 31 | 16.3% |
| **Starting a Business** | 30 | 15.8% |
| **Enforcing Contracts** | 21 | 11.1% |
| **Paying Taxes** | 21 | 11.1% |
| **Getting Electricity** | 20 | 10.5% |
| **Protecting Minority Investors** | 19 | 10.0% |
| **Construction Permits** | 17 | 8.9% |
| **Getting Credit** | 15 | 7.9% |
| **Resolving Insolvency** | 13 | 6.8% |
| **General / Composite Business Indicators** | 3 | 1.6% |

Full indicator-to-category mapping: see [`doing_business_categories.csv`](./doing_business_categories.csv)



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
- `doingbusiness_ready_to_use.R` — ready-to-use script to download custom country/indicator/year selections
- `audit_DoingBusiness.R` — full script (download, processing, export)
- `missing_values_report_DoingBusiness.csv` — detailed missing-values report (country x series)
- `completeness_stats_by_series_DoingBusiness.csv` — % completeness by series
- `completeness_stats_by_country_DoingBusiness.csv` — % completeness by country
- `completeness_stats_by_year_DoingBusiness.csv` — % completeness by year
- `doing_business_categories.csv` — indicator-to-category mapping
