# Central Asian Migration in Europe: Population Distribution and Urban Concentration
# Analysis script
# Data source: Eurostat migr_pop3ctb - Population on 1 January by age group, sex and country of birth
# https://ec.europa.eu/eurostat/databrowser/product/view/migr_pop3ctb?lang=en

library(readr)
library(dplyr)
library(ggplot2)

# -----------------------------------------------------------------------
# 1. Load data
# -----------------------------------------------------------------------
# Note: get_eurostat() via the `eurostat` R package failed with a persistent
# SSL certificate error on this machine (reproducible in R and in-browser
# when hitting the raw API endpoint directly). Data was instead downloaded
# manually from the Eurostat Data Browser (SDMX-CSV 1.0 format, filtered to
# the 5 Central Asian countries of birth) and loaded from disk.
# See RESEARCH_LOG.md for full details of this blocker.

migr_data <- read_csv("data/migr_pop3ctb__custom_22797139_linear.csv")

ca_countries <- c("Tajikistan", "Uzbekistan", "Kyrgyzstan", "Kazakhstan", "Turkmenistan")

# -----------------------------------------------------------------------
# 2. Check data coverage
# -----------------------------------------------------------------------
# Not all reporting countries publish country-of-birth data at the same
# level of detail. This step identifies which countries report individual
# Central Asian countries (vs. the "Central Asia" aggregate, vs. nothing).

coverage <- migr_data %>%
  filter(
    c_birth %in% c(ca_countries, "Central Asia"),
    sex == "Total", age == "Total"
  ) %>%
  filter(!is.na(OBS_VALUE)) %>%
  distinct(geo, c_birth)

coverage_countries <- unique(coverage$geo)

coverage_summary <- coverage %>%
  count(geo, name = "n_categories_reported") %>%
  arrange(desc(n_categories_reported), geo)

# Countries with NO Central Asian country-of-birth data at all
# (includes Germany, Spain, Poland, UK, and others - see RESEARCH_LOG.md)
all_geo <- unique(migr_data$geo)
no_ca_data <- setdiff(all_geo, coverage_countries)

# -----------------------------------------------------------------------
# 3. Build the time series (2016-2025)
# -----------------------------------------------------------------------
time_series <- migr_data %>%
  filter(
    c_birth %in% ca_countries,
    sex == "Total", age == "Total",
    !is.na(OBS_VALUE)
  ) %>%
  group_by(geo, TIME_PERIOD) %>%
  summarise(total_ca_born = sum(OBS_VALUE), .groups = "drop")

# Identify countries with a complete 2016-2025 run (10 years)
full_coverage_countries <- time_series %>%
  count(geo) %>%
  filter(n == 10) %>%
  pull(geo)

# Türkiye and countries with partial time coverage (France, Bulgaria, etc.)
# are excluded from the main trend chart - see RESEARCH_LOG.md and README.md
# for rationale.

# -----------------------------------------------------------------------
# 4. Main visualization: trend over time, full-coverage countries only
# -----------------------------------------------------------------------
plot_data <- time_series %>% filter(geo %in% full_coverage_countries)

# Known documented breaks in series (OBS_FLAG == "b") affecting this chart:
#   - Czechia: 2021, 2022
#   - Italy:   2019
# These are annotated on the chart rather than removed, since the surrounding
# data is still informative, but they should not be read as pure population
# change.

main_chart <- ggplot(plot_data, aes(x = TIME_PERIOD, y = total_ca_born, color = geo)) +
  geom_line(linewidth = 1) +
  geom_vline(xintercept = 2021, linetype = "dashed", color = "grey50", alpha = 0.5) +
  geom_vline(xintercept = 2019, linetype = "dashed", color = "grey50", alpha = 0.5) +
  annotate("text", x = 2021, y = max(plot_data$total_ca_born),
           label = "Czechia: break (2021-22)",
           hjust = -0.05, size = 3, color = "grey40") +
  annotate("text", x = 2019, y = max(plot_data$total_ca_born) * 0.9,
           label = "Italy: break (2019)",
           hjust = -0.05, size = 3, color = "grey40") +
  labs(
    title = "Central Asian-born population in Europe, 2016-2025",
    subtitle = "Countries with complete reporting: Tajikistan, Uzbekistan, Kyrgyzstan, Kazakhstan, Turkmenistan",
    x = "Year", y = "Population (persons)", color = "Country"
  ) +
  theme_minimal()

main_chart

ggsave("output/central_asian_population_trend.png", main_chart, width = 10, height = 6, dpi = 300)
