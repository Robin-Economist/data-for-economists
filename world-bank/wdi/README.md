# World Development Indicators (WDI)

**World Development Indicators** is the most widely used and general-purpose database from the World Bank. It compiles development indicators for nearly every country in the world.

## Key figures

| | |
|---|---|
| Series (indicators) | ~1,510 |
| Countries / regions | ~265 (including regional aggregates and income groups) |
| Available period | 1960 – 2025 (varies by series) |
| DataBank link | [databank.worldbank.org/source/world-development-indicators](https://databank.worldbank.org/source/world-development-indicators) |

## Topics covered

Indicators are organized into broad categories: economic policy and debt, education, environment, financial sector, health, infrastructure, labor and social protection, poverty, private sector and trade, public sector.

## Accessing WDI in R

The [`WDI`](https://cran.r-project.org/package=WDI) package (v2.7.10) allows querying WDI programmatically.

> ⚠️ The `wbstats` package, previously recommended for the same purpose, was **archived in August 2025**. Use `WDI` instead.

```r
library(WDI)

# Search for an indicator by keyword
WDIsearch("gdp per capita")

# Download an indicator for all countries, over a given period
data <- WDI(indicator = "NY.GDP.PCAP.KD", country = "all", start = 1960, end = 2025)
```

**API constraints to know:**
- `start` must be ≥ 1960
- R variable names cannot contain a hyphen (`data_wdi`, not `data-wdi`)
- There is no `"all"` option for indicators — codes must be listed explicitly
- The API is occasionally unstable (`400`, `502` errors, timeouts) — download in small batches rather than one massive request

## Completeness audit

This folder contains an **exhaustive missing-values audit** of WDI: for each series and each country, which years have no available data.

### Method

1. Downloaded the entirety of the ~1,510 series, all countries, 1960–2025, in batches of 20 series (to work around API instability)
2. Reshaped the data into long format (one row = indicator × country × year)
3. Computed a missing/present status for every combination
4. Grouped missing years into readable ranges per (country, series) pair

See the full script: [`audit_WDI_final_en.R`](./audit_WDI_final_en.R)

### Output

The report [`missing_values_report_WDI.csv`](./missing_values_report_WDI.csv) contains one row per (country, series) pair with at least one missing year, with:

| Column | Description |
|---|---|
| `indicator` | WDI series code (e.g. `NY.GDP.PCAP.KD`) |
| `country` | Country or region name |
| `iso3c` | 3-letter ISO code |
| `missing_years` | Ranges of years with no data (e.g. `1960-1962, 1970`) |
| `nb_missing_years` | Total number of missing years |

**Example usage** (in R, Python, or Excel):
```r
rapport <- read.csv("missing_values_report_WDI.csv")

# Everything missing for a given country
report %>% filter(country == "France")

# All countries missing for a given series
report %>% filter(indicator == "NY.GDP.PCAP.KD")
```

### General findings

- Out of ~1,510 series, about 1,397 have at least one missing value somewhere (the rest are 100% complete).
- The years **2024-2025** and **1960** account for a large share of the gaps, likely for structural reasons (most recent data not yet collected for every country; 1960 as an incomplete starting year for many series) rather than a genuine data quality issue.
- Some series (e.g. several official development assistance indicators, `DT.ODA.*`) are entirely empty for many developed countries (expected: these indicators only apply to aid-recipient countries).

## Completeness statistics

> ⚠️ **Methodological note**: the rates below are calculated over the full 1960–2025 window. However, many WDI series only started being collected several decades after 1960 (recent environmental, governance, or financial indicators). A rate of 50% therefore does not mean that half of the *relevant* data is missing, but reflects this extended time window mechanically. For illustration, even Peru — one of the best-covered countries — has only 77 out of 1,397 series that are completely empty; most series have partial rather than zero coverage, concentrated in recent decades.

### By series (top / bottom)

**10 least complete series:**

| Series | % completeness |
|---|---|
| IC.BRE.BE.OS, IC.BRE.BE.P1, IC.BRE.BE.P2, IC.BRE.BE.P3, IC.BRE.BI.OS, IC.BRE.BI.P1, IC.BRE.BI.P2, IC.BRE.BI.P3, IC.BRE.BL.OS, IC.BRE.BL.P1 | 0.3% |

**10 most complete series:**

| Series | % completeness |
|---|---|
| SP.POP.65UP.MA.ZS, SP.POP.65UP.TO.ZS, SP.POP.7074.FE.5Y, SP.POP.7074.MA.5Y, SP.POP.7579.FE.5Y, SP.POP.7579.MA.5Y, SP.POP.80UP.FE.5Y, SP.POP.80UP.MA.5Y, SP.POP.TOTL.FE.ZS, SP.RUR.TOTL.ZS | 99.6% |

Full detail: [`completeness_stats_by_series.csv`](./completeness_stats_by_series.csv)

### By country (top / bottom)

**10 least complete countries/regions:**

| Country | % completeness |
|---|---|
| Not classified | 0% |
| St. Martin (French part) | 6.3% |
| Channel Islands | 8.6% |
| Isle of Man | 8.6% |
| Sint Maarten (Dutch part) | 9% |
| Northern Mariana Islands | 9.2% |
| Gibraltar | 10.3% |
| Curaçao | 10.7% |
| American Samoa | 11% |
| Liechtenstein | 11.3% |

**10 most complete countries** (among large countries, the maximum completeness observed remains around 50% — see methodological note above):

| Country | % completeness |
|---|---|
| Peru | 49.8% |
| Mexico | 49.5% |
| Colombia | 49.3% |
| India | 48% |
| Indonesia | 47.8% |
| Ecuador | 47.7% |
| Dominican Republic | 47.6% |
| Brazil | 47.6% |
| Egypt, Arab Rep. | 47.5% |
| Thailand | 47.3% |

Full detail: [`completeness_stats_by_country.csv`](./completeness_stats_by_country.csv)

### By year

Overall completeness improves over time (little data in the 1960s, more as data collection became widespread):

| Year | % completeness |
|---|---|
| 1960 | 9.4% |
| 1961 | 10.9% |
| 1962 | 11.2% |
| 1965 | 12.1% |
| 1969 | 12.6% |
| ... | ... |

Full detail (66 years): [`completeness_stats_by_year.csv`](./completeness_stats_by_year.csv)

## Files in this folder

- `README.md` — this document
- `audit_WDI_final_en.R` — full script (download, processing, export)
- `missing_values_report_WDI.csv` — detailed missing-values report (country x series)
- `completeness_stats_by_series.csv` — % completeness by series
- `completeness_stats_by_country.csv` — % completeness by country
- `completeness_stats_by_year.csv` — % completeness by year
- `completeness_audit_WDI.pdf` — summary report (a few pages, key statistics)
