# Central Asian Migration in Europe: Population Distribution and Growth

## Research question

How is the population born in Central Asian countries (Tajikistan,
Uzbekistan, Kyrgyzstan, Kazakhstan, Turkmenistan) distributed across
European destination countries, and what patterns of growth can be
identified over 2016-2025?

## Why this matters

Migration from Central Asia to Europe is under-studied relative to other
migration corridors, despite growing numbers in several countries. This
project uses Eurostat's harmonized country-of-birth statistics to build an
evidence-based picture of where Central Asian-born populations live in
Europe and how this has changed over the past decade.

## Data source

**Eurostat, `migr_pop3ctb`** — Population on 1 January by age group, sex
and country of birth.
https://ec.europa.eu/eurostat/databrowser/product/view/migr_pop3ctb?lang=en

**Country of birth**, not citizenship, is used to define Central
Asian-born population, since citizenship changes over time (e.g. through
naturalization) and does not reliably capture people of migrant origin.

## Key findings

- Among the 13 European countries with complete, directly comparable data
  for 2016-2025 (Austria, Belgium, Czechia, Finland, Hungary, Iceland,
  Italy, Latvia, Lithuania, Netherlands, Norway, Slovakia, Slovenia),
  **Czechia held the largest Central Asian-born population for most of the
  decade, but Lithuania overtook it by 2025** after a sharp rise from 2022
  onward (roughly 10,000 to 27,000).
- **Türkiye** reports by far the largest Central Asian-born population of
  any country in the dataset (289,268 in 2020) but is excluded from the
  main trend chart because its data only covers 2021-2025 and would
  dominate the chart's scale. It is treated as a separate case, plausibly
  reflecting Turkic-language and historical migration ties rather than a
  data artifact, though this interpretation is not confirmed here.
- **Germany, Spain, Poland, and the UK** — despite being major migration
  destinations — report no country-of-birth breakdown at this level of
  detail in this dataset, and so could not be included. This appears to be
  a limitation of cross-country statistical harmonization rather than an
  absence of Central Asian-origin population in these countries.

See `RESEARCH_LOG.md` for the full methodology, data coverage analysis, and
known data-quality flags.

## Methodological notes and limitations

- **Data coverage is uneven across countries.** Of ~43 reporting countries,
  23 report at least some individual Central Asian country-of-birth data;
  20 do not, including several major destinations (see above).
- **Time coverage is also uneven.** No single year has data for all
  reporting countries, so the main analysis uses a multi-year trend for the
  subset of countries with complete 2016-2025 coverage, rather than a
  single-year cross-country ranking.
- **Two countries have documented breaks in their time series**: Czechia
  (2021-2022) and Italy (2019). These are annotated on the main chart.
  Apparent jumps around these years likely reflect changes in data
  collection methodology rather than solely real population change.
- **Aggregate statistics, not individual-level data.** These are national
  population counts, not survey or administrative microdata. No claims are
  made here about individual migrants' characteristics or experiences.

## Repository structure

```
├── README.md
├── RESEARCH_LOG.md
├── analysis.R
├── data/              # Raw data (not tracked in git - see .gitignore)
└── output/            # Generated charts
```

## Status

- [x] Research question defined
- [x] Dataset identified and data coverage assessed
- [x] Data downloaded and loaded into R
- [x] Time-series trend chart built and annotated for known data breaks
- [ ] Population-adjusted (per-100,000) comparison
- [ ] Urban/rural (degree of urbanisation) dimension

## Author

Shahlo Elnazarova
