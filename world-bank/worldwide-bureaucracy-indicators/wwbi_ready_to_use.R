# ==============================================================================
# WORLDWIDE BUREAUCRACY INDICATORS (WWBI) - READY-TO-USE DOWNLOAD SCRIPT
# ==============================================================================
#
# Purpose: download exactly the countries, indicators, and years you need
# from the WWBI database, without having to know the WDI package syntax
# by heart.
#
# HOW TO USE
# 1. Edit the three lists below (COUNTRIES, INDICATORS, YEARS)
# 2. Run the whole script
# 3. Your data appears in the `my_data` dataframe, and is also saved
#    as a CSV file
#
# TIP: to find indicator codes, use WDIsearch("keyword"), or check
# wwbi_categories.csv in this folder to browse indicators by theme
# (workforce demographics, wages, employment composition)
#
# ==============================================================================

library(WDI)

# ===== PARAMETERS — edit this section =====

# Countries: use ISO 3-letter codes (e.g. "FRA" for France, "USA" for
# United States). Set COUNTRIES <- "all" to include every country.
COUNTRIES <- c("FRA", "DEU", "ITA", "ESP", "GBR", "USA", "JPN", "CHN", "IND", "BRA")

# Indicators: WWBI codes. A few common examples are pre-filled below —
# replace them with the ones you need.
INDICATORS <- c(
  "BI.EMP.TOTL.PB.ZS",     # Public sector employment, as a share of total employment
  "BI.WAG.TOTL.PB.ZS",     # Public sector wage premium
  "BI.PWK.PUBS.FE.ZS",     # Share of female public employees
  "BI.EMP.FRML.PB.ED.ZS",  # Education workers, share of public formal employment
  "BI.EMP.FRML.PB.HE.ZS"   # Health workers, share of public formal employment
)

# Years: WWBI data mostly covers 2000-2021 (varies by country survey wave)
START_YEAR <- 2000
END_YEAR   <- 2021

# Output file name
OUTPUT_FILE <- "my_wwbi_data.csv"

# ===== END OF PARAMETERS — no need to edit below this line =====


# ----- Download -----
cat("Downloading", length(INDICATORS), "indicator(s) for",
    ifelse(length(COUNTRIES) == 1 && COUNTRIES == "all", "all countries", paste(length(COUNTRIES), "countries")),
    "from", START_YEAR, "to", END_YEAR, "...\n")

my_data <- WDI(
  indicator = INDICATORS,
  country = COUNTRIES,
  start = START_YEAR,
  end = END_YEAR,
  extra = FALSE
)

cat("Done. Rows downloaded:", nrow(my_data), "\n")

# ----- Preview -----
head(my_data)

# ----- Save to CSV -----
write.csv(my_data, OUTPUT_FILE, row.names = FALSE)
cat("Saved to:", OUTPUT_FILE, "\n")


# ==============================================================================
# HOW TO FIND INDICATOR CODES
# ==============================================================================
# Option 1 — search by keyword. Uncomment and run, replacing "keyword"
# with a topic (e.g. "wage", "public sector", "civil service"):
#
# WDIsearch("keyword")
#
# Option 2 — browse by theme using the category mapping built for this
# database. Uncomment and run:
#
# categories <- read.csv("wwbi_categories.csv")
# unique(categories$category)                                          # list all themes
# subset(categories, category == "Wages & Pay Compression")            # browse one theme


# ==============================================================================
# HOW TO FIND COUNTRY CODES
# ==============================================================================
# Uncomment and run the lines below to see the full list of country
# names and their ISO codes:
#
# meta <- WDIcache()
# View(meta$country)
