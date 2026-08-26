# ==============================================================================
# COMPLETENESS AUDIT - Worldwide Governance Indicators (WGI), World Bank
# ==============================================================================
#
# Same method as previous audits (WDI, Education Statistics, Doing
# Business, SPI), applied to "Worldwide Governance Indicators" (~36
# series — measures the quality of governance across countries).
#
# FIXED PATHS — edit PROJECT_ROOT and WORLD_BANK_FOLDER once if you ever
# move the project. Never relies on getwd(), so it always writes to the
# same place no matter where/how you launch R.
#
# ==============================================================================

PROJECT_ROOT      <- "C:/Users/Jeanne/Desktop/WORLDBANK-data/WORLD-BANK"
WORLD_BANK_FOLDER <- "C:/Users/Jeanne/Desktop/world-bank"

RAW_DIR    <- file.path(PROJECT_ROOT, "audit_WGI")
DETAIL_DIR <- file.path(PROJECT_ROOT, "audit_detail_WGI")
REPORT_DIR <- file.path(PROJECT_ROOT, "missing_report_WGI")
OUTPUT_DIR <- file.path(WORLD_BANK_FOLDER, "worldwide-governance-indicators")

for (d in c(RAW_DIR, DETAIL_DIR, REPORT_DIR, OUTPUT_DIR)) {
  dir.create(d, recursive = TRUE, showWarnings = FALSE)
}

cat("Deliverables will be written to:\n", OUTPUT_DIR, "\n\n")

# ==============================================================================

library(WDI)
library(dplyr)
library(tidyr)


# ===== 1. Load metadata and target the WGI database =====
meta <- WDIcache()
db_name <- "Worldwide Governance Indicators"
series_codes <- meta$series$indicator[meta$series$sourceDatabase == db_name]

length(series_codes)  # expect ~36


# ===== 2. Download raw data, in batches =====
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

# ----- Safety check: retry any missing batches -----
batches_present <- as.numeric(gsub("[^0-9]", "", gsub("batch_|\\.rds", "", list.files(RAW_DIR))))
batches_missing <- setdiff(1:n_batches, batches_present)

if (length(batches_missing) > 0) {
  cat("Retrying", length(batches_missing), "missing batch(es):", batches_missing, "\n")
  for (i in batches_missing) {
    out_path <- file.path(RAW_DIR, paste0("batch_", i, ".rds"))
    start_idx <- (i - 1) * batch_size + 1
    end_idx <- min(i * batch_size, length(series_codes))
    batch_codes <- series_codes[start_idx:end_idx]

    cat(as.character(Sys.time()), "- Retry batch", i, "\n")

    result <- tryCatch({
      WDI(indicator = batch_codes, country = "all", start = 1960, end = 2025, extra = FALSE)
    }, error = function(e) {
      cat("  Error:", conditionMessage(e), "\n")
      return(NULL)
    })

    if (!is.null(result)) saveRDS(result, out_path)
    Sys.sleep(3)
  }
}

cat("Final batch count:", length(list.files(RAW_DIR)), "/", n_batches, "\n")


# ===== 3. Check column structure before reshaping =====
# IMPORTANT lesson learned from SPI: not every database returns iso2c.
# Check first, adapt the pivot_longer() exclusion list accordingly.
sample_batch <- readRDS(list.files(RAW_DIR, full.names = TRUE)[1])
cat("Columns in this database:", paste(colnames(sample_batch)[1:5], collapse = ", "), "...\n")
has_iso2c <- "iso2c" %in% colnames(sample_batch)
id_cols <- if (has_iso2c) c("country", "iso2c", "iso3c", "year") else c("country", "iso3c", "year")
cat("Using id columns:", paste(id_cols, collapse = ", "), "\n")


# ===== 4. Compute full detail: indicator x country x year x status =====
raw_files <- list.files(RAW_DIR, full.names = TRUE)

for (f in raw_files) {
  batch_name <- tools::file_path_sans_ext(basename(f))
  out_path <- file.path(DETAIL_DIR, paste0(batch_name, "_detail.rds"))

  if (file.exists(out_path)) next

  cat("Detail:", batch_name, "\n")

  batch_data <- readRDS(f)

  long_data <- batch_data %>%
    pivot_longer(
      cols = -all_of(id_cols),
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


# ===== 5. Utility: group years into compact ranges =====
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


# ===== 6. Build the final report: one row per (country, series) =====
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


# ===== 7. Export the consolidated report — FINAL DELIVERABLE =====
report_files <- list.files(REPORT_DIR, full.names = TRUE)
output_csv <- file.path(OUTPUT_DIR, "missing_values_report_WGI.csv")
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

completeness_by_series <- bind_rows(lapply(detail_files, function(f) {
  d <- readRDS(f)
  d %>% group_by(indicator) %>%
    summarise(total_obs = n(), missing_obs = sum(missing), .groups = "drop")
})) %>%
  mutate(completeness_rate = round(100 * (1 - missing_obs / total_obs), 1)) %>%
  arrange(completeness_rate)
write.csv(completeness_by_series, file.path(OUTPUT_DIR, "completeness_stats_by_series_WGI.csv"), row.names = FALSE)

completeness_by_country <- bind_rows(lapply(detail_files, function(f) {
  d <- readRDS(f)
  d %>% group_by(country, iso3c) %>%
    summarise(total_obs = n(), missing_obs = sum(missing), .groups = "drop")
})) %>%
  group_by(country, iso3c) %>%
  summarise(total_obs = sum(total_obs), missing_obs = sum(missing_obs), .groups = "drop") %>%
  mutate(completeness_rate = round(100 * (1 - missing_obs / total_obs), 1)) %>%
  arrange(completeness_rate)
write.csv(completeness_by_country, file.path(OUTPUT_DIR, "completeness_stats_by_country_WGI.csv"), row.names = FALSE)

completeness_by_year <- bind_rows(lapply(detail_files, function(f) {
  d <- readRDS(f)
  d %>% group_by(year) %>%
    summarise(total_obs = n(), missing_obs = sum(missing), .groups = "drop")
})) %>%
  group_by(year) %>%
  summarise(total_obs = sum(total_obs), missing_obs = sum(missing_obs), .groups = "drop") %>%
  mutate(completeness_rate = round(100 * (1 - missing_obs / total_obs), 1)) %>%
  arrange(year)
write.csv(completeness_by_year, file.path(OUTPUT_DIR, "completeness_stats_by_year_WGI.csv"), row.names = FALSE)


# ===== DONE =====
cat("\n=== ALL DELIVERABLES ARE IN:", OUTPUT_DIR, "===\n")
print(list.files(OUTPUT_DIR))

cat("\n--- Top 10 LEAST complete series ---\n")
print(head(completeness_by_series, 10))
cat("\n--- Top 10 MOST complete series ---\n")
print(tail(completeness_by_series, 10))
cat("\n--- Top 10 LEAST complete countries ---\n")
print(head(completeness_by_country, 10))
cat("\n--- Top 10 MOST complete countries ---\n")
print(tail(completeness_by_country, 10))
cat("\n--- Completeness by year ---\n")
print(as.data.frame(completeness_by_year))
