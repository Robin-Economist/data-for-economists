# ==============================================================================
# COMPLETENESS AUDIT - World Development Indicators (WDI), World Bank
# ==============================================================================
#
# FINAL, FIXED-PATH VERSION
# This script always reads/writes to one single, absolute location on your
# PC, no matter what your current working directory (getwd()) happens to
# be when you run it. This avoids the confusion of files scattering across
# multiple "world-bank/wdi/" folders created by accident.
#
# YOUR PROJECT ROOT (edit this once if you ever move the project):
# This points to the folder that ALREADY contains your 4 database folders
# (wdi/, education-statistics/, doing-business/, statistical-performance-indicators/)
PROJECT_ROOT <- "C:/Users/Jeanne/Desktop/WORLDBANK-data/WORLD-BANK"
WORLD_BANK_FOLDER <- "C:/Users/Jeanne/Desktop/world-bank"

# Everything below is built from these — never a relative path.
OUTPUT_DIR    <- file.path(WORLD_BANK_FOLDER, "wdi")
RAW_DIR       <- file.path(PROJECT_ROOT, "audit_WDI")
DETAIL_DIR    <- file.path(PROJECT_ROOT, "audit_detail_country")
REPORT_DIR    <- file.path(PROJECT_ROOT, "missing_report")

dir.create(OUTPUT_DIR, recursive = TRUE, showWarnings = FALSE)
dir.create(RAW_DIR, recursive = TRUE, showWarnings = FALSE)
dir.create(DETAIL_DIR, recursive = TRUE, showWarnings = FALSE)
dir.create(REPORT_DIR, recursive = TRUE, showWarnings = FALSE)

cat("All files for this script will be read/written under:\n")
cat(" -", RAW_DIR, "(raw downloaded batches)\n")
cat(" -", DETAIL_DIR, "(long-format detail per batch)\n")
cat(" -", REPORT_DIR, "(missing-years report per batch)\n")
cat(" -", OUTPUT_DIR, "(FINAL deliverables — this is what you upload to GitHub)\n\n")

# ==============================================================================

library(WDI)
library(dplyr)
library(tidyr)


# ===== 1. Load metadata and target the WDI database =====
meta <- WDIcache()
db_name <- "World Development Indicators"
series_codes <- meta$series$indicator[meta$series$sourceDatabase == db_name]


# ===== 2. Download raw data, in batches (skips if already done) =====
batch_size <- 20
n_batches <- ceiling(length(series_codes) / batch_size)

options(timeout = 120)

cat("Batches already present:", length(list.files(RAW_DIR)), "/", n_batches, "\n")

for (i in 1:n_batches) {
  out_path <- file.path(RAW_DIR, paste0("batch_", i, ".rds"))
  if (file.exists(out_path)) next

  start_idx <- (i - 1) * batch_size + 1
  end_idx <- min(i * batch_size, length(series_codes))
  batch_codes <- series_codes[start_idx:end_idx]

  cat(as.character(Sys.time()), "- Batch", i, "/", n_batches, "\n")

  result <- tryCatch({
    WDI(indicator = batch_codes, country = "all", start = 1960, end = 2025, extra = FALSE)
  }, error = function(e) {
    cat("  Error:", conditionMessage(e), "\n")
    return(NULL)
  })

  if (!is.null(result)) saveRDS(result, out_path)
  Sys.sleep(3)
}

cat("Batches downloaded:", length(list.files(RAW_DIR)), "/", n_batches, "\n")


# ===== 3. Compute full detail: indicator x country x year x status =====
raw_files <- list.files(RAW_DIR, full.names = TRUE)

for (f in raw_files) {
  batch_name <- tools::file_path_sans_ext(basename(f))
  out_path <- file.path(DETAIL_DIR, paste0(batch_name, "_detail.rds"))

  if (file.exists(out_path)) next

  cat("Detail:", batch_name, "\n")

  batch_data <- readRDS(f)

  long_data <- batch_data %>%
    pivot_longer(
      cols = -c(country, iso2c, iso3c, year),
      names_to = "indicator",
      values_to = "value"
    )

  detail_batch <- long_data %>%
    mutate(missing = is.na(value)) %>%
    select(indicator, country, iso3c, year, missing)

  saveRDS(detail_batch, out_path)

  rm(batch_data, long_data, detail_batch)
  gc()
}

cat("Detail files:", length(list.files(DETAIL_DIR)), "\n")


# ===== 4. Utility: group years into compact ranges =====
group_years <- function(years) {
  years <- sort(unique(years))
  if (length(years) == 0) return("")
  diffs <- c(1, diff(years))
  group_id <- cumsum(diffs != 1)
  groups <- split(years, group_id)
  ranges <- sapply(groups, function(g) {
    if (length(g) == 1) as.character(g) else paste0(min(g), "-", max(g))
  })
  paste(ranges, collapse = ", ")
}


# ===== 5. Build the final report: one row per (country, series) =====
detail_files <- list.files(DETAIL_DIR, full.names = TRUE)

for (f in detail_files) {
  batch_name <- tools::file_path_sans_ext(basename(f))
  out_path <- file.path(REPORT_DIR, paste0(batch_name, "_report.rds"))

  if (file.exists(out_path)) next

  cat("Report:", batch_name, "\n")

  d <- readRDS(f)

  report_batch <- d %>%
    filter(missing == TRUE) %>%
    group_by(indicator, country, iso3c) %>%
    summarise(
      missing_years = group_years(year),
      nb_missing_years = n(),
      .groups = "drop"
    )

  saveRDS(report_batch, out_path)

  rm(d, report_batch)
  gc()
}

cat("Report files:", length(list.files(REPORT_DIR)), "\n")


# ===== 6. Export the consolidated report — FINAL DELIVERABLE =====
report_files <- list.files(REPORT_DIR, full.names = TRUE)
output_csv <- file.path(OUTPUT_DIR, "missing_values_report_WDI.csv")
if (file.exists(output_csv)) file.remove(output_csv)

for (f in report_files) {
  d <- readRDS(f)
  write.table(
    d, output_csv, sep = ",", row.names = FALSE,
    col.names = !file.exists(output_csv), append = TRUE
  )
  rm(d)
  gc()
}

cat("Export complete:", output_csv, "\n")


# ==============================================================================
# COMPLETENESS STATISTICS — also FINAL DELIVERABLES
# ==============================================================================

# ----- By series -----
completeness_by_series <- bind_rows(lapply(detail_files, function(f) {
  d <- readRDS(f)
  d %>% group_by(indicator) %>%
    summarise(total_obs = n(), missing_obs = sum(missing), .groups = "drop")
})) %>%
  mutate(completeness_rate = round(100 * (1 - missing_obs / total_obs), 1)) %>%
  arrange(completeness_rate)

write.csv(completeness_by_series, file.path(OUTPUT_DIR, "completeness_stats_by_series.csv"), row.names = FALSE)

# ----- By country -----
completeness_by_country <- bind_rows(lapply(detail_files, function(f) {
  d <- readRDS(f)
  d %>% group_by(country, iso3c) %>%
    summarise(total_obs = n(), missing_obs = sum(missing), .groups = "drop")
})) %>%
  group_by(country, iso3c) %>%
  summarise(total_obs = sum(total_obs), missing_obs = sum(missing_obs), .groups = "drop") %>%
  mutate(completeness_rate = round(100 * (1 - missing_obs / total_obs), 1)) %>%
  arrange(completeness_rate)

write.csv(completeness_by_country, file.path(OUTPUT_DIR, "completeness_stats_by_country.csv"), row.names = FALSE)

# ----- By year -----
completeness_by_year <- bind_rows(lapply(detail_files, function(f) {
  d <- readRDS(f)
  d %>% group_by(year) %>%
    summarise(total_obs = n(), missing_obs = sum(missing), .groups = "drop")
})) %>%
  group_by(year) %>%
  summarise(total_obs = sum(total_obs), missing_obs = sum(missing_obs), .groups = "drop") %>%
  mutate(completeness_rate = round(100 * (1 - missing_obs / total_obs), 1)) %>%
  arrange(year)

write.csv(completeness_by_year, file.path(OUTPUT_DIR, "completeness_stats_by_year.csv"), row.names = FALSE)


# ===== DONE =====
cat("\n=== ALL DELIVERABLES ARE IN:", OUTPUT_DIR, "===\n")
print(list.files(OUTPUT_DIR))
