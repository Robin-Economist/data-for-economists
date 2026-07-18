# ==============================================================================
# WDI - READY-TO-USE DOWNLOAD SCRIPT
# ==============================================================================
#
# Purpose: download exactly the countries, indicators, and years you need,
# without having to know the WDI package syntax by heart.
#
# HOW TO USE
# 1. Edit the three lists below (COUNTRIES, INDICATORS, YEARS)
# 2. Run the whole script
# 3. Your data appears in the `my_data` dataframe, and is also saved
#    as a CSV file
#
# TIP: to find indicator codes, use WDIsearch("keyword") — see example
# at the bottom of this script.
#
# ==============================================================================

library(WDI)

# ===== PARAMETERS — edit this section =====

# Countries: use ISO 3-letter codes (e.g. "FRA" for France, "USA" for
# United States). Set to "all" (without quotes removed, i.e. COUNTRIES <- "all")
# to include every country.
COUNTRIES <- c("FRA", "DEU", "ITA", "ESP", "GBR", "USA", "JPN", "CHN", "IND", "BRA")

# Indicators: WDI codes. A few common examples are pre-filled below —
# replace them with the ones you need.
INDICATORS <- c(
  "NY.GDP.PCAP.KD",     # GDP per capita (constant 2015 US$)
  "SP.POP.TOTL",        # Population, total
  "SL.UEM.TOTL.ZS",     # Unemployment (% of labor force)
  "FP.CPI.TOTL.ZG",     # Inflation, consumer prices (annual %)
  "SP.DYN.LE00.IN",     # Life expectancy at birth
  "SE.ADT.LITR.ZS",     # Literacy rate, adult total
  "EN.ATM.CO2E.PC"      # CO2 emissions (metric tons per capita)
)

# Years: start and end (WDI requires start >= 1960)
START_YEAR <- 2000
END_YEAR   <- 2023

# Output file name
OUTPUT_FILE <- "my_wdi_data.csv"

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
# Uncomment and run the line below, replacing "keyword" with a topic
# (e.g. "trade", "education", "co2", "poverty"):
#
# WDIsearch("keyword")
#
# This returns a table with indicator codes (first column) and their
# full name (second column) — copy the code you need into INDICATORS above.


# ==============================================================================
# HOW TO FIND COUNTRY CODES
# ==============================================================================
# Uncomment and run the lines below to see the full list of country
# names and their ISO codes:
#
# meta <- WDIcache()
# View(meta$country)
