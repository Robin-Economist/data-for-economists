# ==============================================================================
# STATISTICAL PERFORMANCE INDICATORS (SPI) - READY-TO-USE DOWNLOAD SCRIPT
# ==============================================================================
#
# Purpose: download exactly the countries, indicators, and years you need
# from the SPI database, without having to know the WDI package syntax
# by heart.
#
# Note: this database does not have an iso2c column (only country, iso3c,
# year) — this only matters if you reshape the raw WDI() output yourself.
#
# HOW TO USE
# 1. Edit the three lists below (COUNTRIES, INDICATORS, YEARS)
# 2. Run the whole script
# 3. Your data appears in the `my_data` dataframe, and is also saved
#    as a CSV file
#
# TIP: to find indicator codes, use WDIsearch("keyword"), or check
# spi_categories.csv in this folder to browse indicators by Pillar
# (Data Use, Data Services, Data Products, Data Sources, Data Infrastructure)
#
# ==============================================================================

library(WDI)

# ===== PARAMETERS — edit this section =====

# Countries: use ISO 3-letter codes (e.g. "FRA" for France, "USA" for
# United States). Set COUNTRIES <- "all" to include every country.
COUNTRIES <- c("FRA", "DEU", "ITA", "ESP", "GBR", "USA", "JPN", "CHN", "IND", "BRA")

# Indicators: SPI codes. A few common examples are pre-filled below —
# replace them with the ones you need.
INDICATORS <- c(
  "SPI.INDEX",           # Overall SPI Score
  "SPI.INDEX.PIL1",      # Pillar 1 - Data Use - Score
  "SPI.INDEX.PIL2",      # Pillar 2 - Data Services - Score
  "SPI.INDEX.PIL3",      # Pillar 3 - Data Products - Score
  "SPI.INDEX.PIL4",      # Pillar 4 - Data Sources - Score
  "SPI.INDEX.PIL5",      # Pillar 5 - Data Infrastructure - Score
  "SPI.D2.1.GDDS"        # SDDS/e-GDDS subscription
)

# Years: SPI covers 2004-2023
START_YEAR <- 2004
END_YEAR   <- 2023

# Output file name
OUTPUT_FILE <- "my_spi_data.csv"

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
# with a topic (e.g. "census", "openness", "governance", "survey"):
#
# WDIsearch("keyword")
#
# Option 2 — browse by Pillar using the category mapping built for this
# database. Uncomment and run:
#
# categories <- read.csv("spi_categories.csv")
# unique(categories$category)                                    # list all 5 pillars
# subset(categories, category == "Pillar 3: Data Products")       # browse one pillar


# ==============================================================================
# HOW TO FIND COUNTRY CODES
# ==============================================================================
# Uncomment and run the lines below to see the full list of country
# names and their ISO codes:
#
# meta <- WDIcache()
# View(meta$country)
