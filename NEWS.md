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
