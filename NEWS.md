# valresultat (development)

* Adds `personroster()` with one row per candidate, party and official
  personal-vote area. Official qualified-candidate totals take precedence,
  other totals require verified complete district material, and personal-vote
  shares are unrounded proportions on the 0–1 scale.
* Gives `valresultat()` an analysis-oriented, level-specific public column
  contract while retaining the internal 83-column harmonised schema.
* Retains unreported voting districts with `raknat = FALSE`, official
  constituency-specific party rows and typed missing result values.
* Completes unambiguous district geography from official 2026 structures in
  the same ZIP and a fixed 2026 county-code lookup.
* Keeps only analytically distinct reporting scopes in each public level's
  column contract and places district reporting status next to its geography.

# valresultat 0.1.1

* Normalizes Valmyndigheten's live preliminary-count metadata
  `"preliminär"` to the package value `"preliminar"`. The unaccented form
  used by older test data remains supported.
* Skips geographic result objects whose existing `rostfordelning` key is
  explicitly `NULL` while counting is in progress. Explicit zero results are
  retained, and a missing key or malformed result structure remains an error.

# valresultat 0.1.0

* Adds the first public API for harmonised 2026 election results: `valresultat()`,
  `mandat()`, `kandidaturer()`, `kandidater()`, `valda()` and `ersattare()`.
* Supports local and remote Valmyndigheten raw data with strict offline behavior
  for `source = "local"`.
* Uses Valmyndigheten's live `val2026` result collection by default while
  retaining explicit access to `genrep2026` for tests and development. File
  paths come from `index.md5`, with support for the corrected `Val_2026_*`
  names.
* Distinguishes verified zero/false results from missing, partial or unclear
  candidate-result data with typed `NA` values.
* Final D, U and M source files have been integration-tested against selected
  2026 rehearsal files. Preliminary and O sources remain fixture-tested only.

This is an experimental first release focused on the 2026 election.
