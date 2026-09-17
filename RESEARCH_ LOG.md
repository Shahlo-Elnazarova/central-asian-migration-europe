# Research Log

## Project setup

**Research question:** How is the population born in Central Asian countries
distributed across European destination countries, and what patterns of
concentration and growth can be identified?

**Countries of origin:** Tajikistan, Uzbekistan, Kyrgyzstan, Kazakhstan,
Turkmenistan

**Definitional choice:** Country of birth (not citizenship) is used to
define Central Asian-born population. A person born in Tajikistan who
later naturalizes as, say, German would be excluded from a citizenship-based
measure but is retained under country of birth, which better captures actual
migrant origin.

## Dataset selection

Searched the Eurostat Data Browser for "population by country of birth."
Several candidate datasets were identified:

- `cens_21cob_r3` (2021 EU Census, NUTS 3 regional detail, single year only)
- `urb_cpopcb` (city-level, Urban Audit)
- Several `migr_pop*` datasets, by citizenship or by country of birth

**Chosen dataset: `migr_pop3ctb`** — "Population on 1 January by age group,
sex and country of birth." Selected because it is (a) an annual time series
(2016-2025 in the downloaded extract), not a single-year snapshot, and (b)
reports country of birth, not citizenship, at national level.

## Technical blocker: SSL certificate error

`get_eurostat("migr_pop3ctb")` (R `eurostat` package) failed consistently
with:

Error in get_eurostat("migr_pop3ctb", ...) :
  get_eurostat_raw fails with the id migr_pop3ctb
SSL peer certificate or SSH remote key was not OK

**Diagnosis steps taken:**
- Restarted R session — no change
- Reinstalled `curl` and `httr` — no change
- Tried `Sys.setenv(CURL_SSL_BACKEND = "openssl")` — no change
- Tested the same API URL directly in a web browser — same failure
  ("Check Internet connection"), while general internet access was
  unaffected. This confirmed the issue was specific to Eurostat's API
  endpoint (or the local network/security software's handling of it),
  not a general connectivity problem.

**Resolution:** Downloaded the filtered dataset manually from the Eurostat
Data Browser website (format: SDMX-CSV 1.0, scope: only displayed
dimensions, uncompressed), then loaded it into R with `readr::read_csv()`.
This route uses a different part of Eurostat's infrastructure than the
API/bulk-download endpoint and worked without issue.

## Data coverage findings

Of the countries in `migr_pop3ctb`, coverage of individual Central Asian
countries of birth is uneven:

- **23 countries** report at least some individual Central Asian country
  breakdown (22 report all five countries plus the "Central Asia" aggregate;
  France reports only Kazakhstan, Kyrgyzstan, and Uzbekistan, and only
  through 2018).
- **20 countries have no data at this breakdown level**, including several
  major migration destinations: **Germany, Spain, Poland, the United
  Kingdom, Greece, Ireland, Portugal**. Checked directly: Germany reports
  population by broad EU/non-EU/citizenship-adjacent categories only, with
  no country- or region-of-birth breakdown at all. This is a genuine
  limitation of cross-country data harmonization, not a data error.
- Several non-EU/EFTA countries (Ukraine, Serbia, Moldova, Georgia,
  Armenia, North Macedonia, Albania, Montenegro) also have no data, which
  may reflect different reporting arrangements outside the EU/EFTA
  statistical system rather than a comparable gap.

**Time coverage** also varies by country: 13 countries have a complete
2016-2025 run; others have partial windows (e.g. Bulgaria only from 2023;
France only through 2018; Türkiye only from 2021). No single year has full
coverage across all reporting countries — 2019/2020 have the most countries
represented (105 rows) if a single-year snapshot were used instead of a
trend.

**Decision:** Given the uneven time coverage, the main analysis uses a
2016-2025 trend (line chart) restricted to the 13 countries with complete
coverage, rather than a single-year cross-country ranking. Türkiye is
excluded from this main chart despite having by far the largest Central
Asian-born population (289,268 in 2020, vs. 12,085 for the next-highest,
Czechia) because its data only runs 2021-2025 and would dominate the chart's
scale; it is treated as a separate outlier/footnote.

## Data quality flags

Checked `OBS_FLAG` for "break in time series" (`b`) among the 13
full-coverage countries used in the main chart:

- **Czechia**: flagged at 2021 and 2022
- **Italy**: flagged at 2019

Italy's Kazakhstan-born population drops from 4,089 (2018) to 689 (2019) —
an 83% apparent fall, implausible as genuine population change — before
gradually recovering. This confirms the break flag reflects a methodology
or data-source change around 2019, not actual migration reversal. Czechia's
rise from ~10,000 to ~16,000 around 2021-2022 coincides with its flagged
break and should likewise not be read as pure population growth.

By contrast, **Lithuania's steep rise (roughly 10,000 to 27,000 between
2022 and 2025) carries no break flag**, and is treated in this project as a
genuine trend rather than a data artifact — though this should still be
treated as provisional pending further corroboration (e.g. against national
statistics) rather than fully confirmed.

## Key finding so far

Among the 13 countries with complete, comparable 2016-2025 data, Czechia
had the largest Central Asian-born population for most of the decade, but
Lithuania overtook it by 2025 following a sharp rise from 2022 onward.
