# Statistical Performance Indicators (SPI)

**Statistical Performance Indicators (SPI)** measures the quality, availability, and capacity of countries' own statistical systems — essentially, an index of how good a country's data infrastructure is. It replaced the World Bank's earlier "Statistical Capacity Indicators" program.

## Key figures

| | |
|---|---|
| Series (indicators) | 72 |
| Countries / regions | ~265 |
| Available period | 2004 – 2023 (20 years) |
| DataBank link | [databank.worldbank.org/databases](https://databank.worldbank.org/databases/page/1/orderby/popularity/direction/desc) |

> Note: this database does not return an `iso2c` column (unlike WDI, Education Statistics, and Doing Business) — only `country`, `iso3c`, and `year`. Adjust any reshaping code accordingly.

## Structure: the 5 Pillars

SPI indicators are organized around a formal framework of **5 Pillars**, each measuring a different dimension of statistical capacity:

1. **Data Use** — how much a country's data is used (e.g. by international organizations)
2. **Data Services** — online access, data releases, openness (SDDS/GDDS subscriptions, ODIN score)
3. **Data Products** — coverage of the 17 UN Sustainable Development Goals (poverty, health, education, climate, etc.)
4. **Data Sources** — censuses, surveys, administrative data, geospatial data availability
5. **Data Infrastructure** — legislation, governance, standards, methods, financing of the statistical system

## Accessing SPI in R

Same package as WDI — see [`world-bank/wdi/README.md`](../wdi/README.md) for general setup instructions.

```r
library(WDI)

meta <- WDIcache()
db_name <- "Statistical Performance Indicators (SPI)"
series_codes <- meta$series$indicator[meta$series$sourceDatabase == db_name]

length(series_codes)  # 72

# Example: download the overall SPI score for a few countries
data <- WDI(indicator = "SPI.INDEX", country = c("FRA", "USA", "IND"),
            start = 2004, end = 2023)
```

## Indicator categories

Categories map directly onto the program's 5 official Pillars — this covers **100%** of the 72 indicators, with no uncategorized remainder.

| Category | Indicators | % of total |
|---|---|---|
| **Pillar 3: Data Products** | 21 | 29.2% |
| **Pillar 5: Data Infrastructure** | 16 | 22.2% |
| **Pillar 4: Data Sources** | 15 | 20.8% |
| **Pillar 2: Data Services** | 12 | 16.7% |
| **Pillar 1: Data Use** | 7 | 9.7% |
| **Overall SPI Score** | 1 | 1.4% |

Full indicator-to-category mapping: see [`spi_categories.csv`](./spi_categories.csv)

## Completeness audit

This folder contains an **exhaustive missing-values audit** of SPI: for each series and each country, which years have no available data.

### Method

Same method as the [WDI](../wdi/completeness_audit_WDI.md), [Education Statistics](../education-statistics/README.md), and [Doing Business](../doing-business/README.md) audits — full download by batch, long-format reshaping, and per (country, series) gap detection.

See the full script: [`audit_SPI.R`](./audit_SPI.R)

### Output

The report [`missing_values_report_SPI.csv`](./missing_values_report_SPI.csv) contains one row per (country, series) pair with at least one missing year, with the same column structure as the other audits in this repo.

### General findings

SPI is **the best-covered World Bank database audited so far** — a marked contrast with Education Statistics and Doing Business.

**By series**
- Best series: several raw indicators (e.g. `SPI.D1.5.CHLD.MORT`, `SPI.INDEX.PIL1`) reach **100%** completeness
- Worst series (`SPI.D5.5.DIFI`, `SPI.DIM5.5.INDEX` — finance-related indicators under Pillar 5): **29.8%** completeness

**By country**
- Least covered: **Channel Islands (14.7%)**, Kosovo (41.7%), Isle of Man (43.4%)
- Best covered: **Chile (83.1%)**, followed by a large group of countries tied at 82.4% (Portugal, Singapore, Slovak Republic, Slovenia, Spain, Sweden, Switzerland, United Kingdom, United States)

**By year**
- Completeness is flat around **52–56%** from 2004 to 2014
- A sharp jump occurs in **2015–2016** (56.1% → 65.3% → 87.7%), likely marking the program's formal launch as "SPI" (replacing the earlier Statistical Capacity Indicators)
- Reaches its peak at **93.3% in 2023**, the most recent and best-documented year

## Files in this folder

- `README.md` — this document
- `spi_ready_to_use.R` — ready-to-use script to download custom country/indicator/year selections
- `audit_SPI.R` — full script (download, processing, export)
- `missing_values_report_SPI.csv` — detailed missing-values report (country x series)
- `completeness_stats_by_series_SPI.csv` — % completeness by series
- `completeness_stats_by_country_SPI.csv` — % completeness by country
- `completeness_stats_by_year_SPI.csv` — % completeness by year
- `spi_categories.csv` — indicator-to-category mapping (by Pillar)
