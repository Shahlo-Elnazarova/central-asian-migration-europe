# Central Asian-Born Population in Europe: Distribution and Population-Stock Change, 2016-2025
# Analysis script
# Data source: Eurostat migr_pop3ctb - Population on 1 January by age group, sex and country of birth
# https://ec.europa.eu/eurostat/databrowser/product/view/migr_pop3ctb?lang=en

library(readr)
library(dplyr)
library(ggplot2)

# -----------------------------------------------------------------------
# 1. Load data
# -----------------------------------------------------------------------
# Eurostat data were downloaded manually from the Data Browser because the
# R API route (get_eurostat()) was unavailable in the local environment.
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

# Identify countries with observations for every year 2016-2025.
# (A simple row-count check, e.g. n() == 10, would pass even if a country
# had a duplicated year and a missing year, so we explicitly check the set
# of years reported against the required range.)
required_years <- 2016:2025

full_coverage_countries <- time_series %>%
  group_by(geo) %>%
  summarise(complete = setequal(unique(TIME_PERIOD), required_years), .groups = "drop") %>%
  filter(complete) %>%
  pull(geo)

# Türkiye and countries with partial time coverage (France, Bulgaria, etc.)
# are excluded from the main trend chart because their series do not cover
# the full 2016-2025 period - see RESEARCH_LOG.md and README.md.

# -----------------------------------------------------------------------
# 4. Identify documented breaks in series (OBS_FLAG == "b")
# -----------------------------------------------------------------------
# Rather than hard-coding which countries/years have a documented break,
# derive this directly from the data so the chart annotations stay correct
# if the underlying extract is refreshed.

breaks <- migr_data %>%
  filter(
    geo %in% full_coverage_countries,
    c_birth %in% ca_countries,
    sex == "Total", age == "Total",
    OBS_FLAG == "b"
  ) %>%
  distinct(geo, TIME_PERIOD) %>%
  arrange(geo, TIME_PERIOD)

# breaks currently contains: Czechia (2021, 2022), Italy (2019) - see
# RESEARCH_LOG.md for interpretation (these likely reflect a change in data
# collection methodology, not a genuine population reversal).

# -----------------------------------------------------------------------
# 5. Main visualization: trend over time, full-coverage countries only
# -----------------------------------------------------------------------
plot_data <- time_series %>% filter(geo %in% full_coverage_countries)

break_years <- sort(unique(breaks$TIME_PERIOD))

main_chart <- ggplot(plot_data, aes(x = TIME_PERIOD, y = total_ca_born, color = geo)) +
  geom_line(linewidth = 1) +
  geom_vline(xintercept = break_years, linetype = "dashed", color = "grey50", alpha = 0.5) +
  labs(
    title = "Central Asian-born population in 13 European reporting countries, 2016-2025",
    subtitle = "Countries with observations for every year 2016-2025: Tajikistan, Uzbekistan, Kyrgyzstan, Kazakhstan, Turkmenistan",
    caption = paste0(
      "Dashed lines mark documented breaks in series (Eurostat OBS_FLAG = 'b'): ",
      paste(unique(breaks$geo), collapse = ", "), ". See RESEARCH_LOG.md.\n",
      "Source: Eurostat, migr_pop3ctb, filtered and aggregated by the author. Accessed 17 September 2026."
    ),
    x = "Year", y = "Population (persons)", color = "Country"
  ) +
  theme_minimal() +
  theme(plot.caption = element_text(hjust = 0, size = 7, color = "grey40"))

main_chart

ggsave("output/central_asian_population_trend.png", main_chart, width = 10, height = 6.5, dpi = 300)
