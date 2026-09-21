# valresultat

`valresultat` is an R package for downloading, parsing and analysing Swedish election data from Valmyndigheten.

The aim is to provide analysis-ready data on election results, mandates, candidates, candidacies, elected representatives and substitutes while preserving important information from the official source files.

> [!WARNING]
> `valresultat` is under active development. Development currently focuses on
> the 2026 Swedish elections, and the public API and data structures may still
> change. Testing uses deterministic fixtures, Valmyndigheten's rehearsal data
> and targeted checks against current live result files.

## Installation

Install the development version from GitHub with `pak`:

```r
install.packages("pak")
pak::pak("richardohrvall/valresultat")
```

Alternatively, using `remotes`:

```r
install.packages("remotes")
remotes::install_github("richardohrvall/valresultat")
```

Then load the package:

```r
library(valresultat)
```

## Main functions

| Function | Description |
| --- | --- |
| `valresultat()` | Party vote results at different geographic levels |
| `mandat()` | Mandate allocation by party |
| `kandidaturer()` | Detailed candidacy data across electoral areas, constituencies and lists |
| `kandidater()` | Analysis-ready candidate data |
| `personroster()` | Personal votes by candidate, party and personal-vote area |
| `valda()` | Elected candidates; a convenience view based on `kandidater()` |
| `ersattare()` | Substitute relationships for elected representatives |

The functions currently target the 2026 parliamentary (`RD`), regional (`RF`) and municipal (`KF`) elections where the corresponding source data are available.

## Quick start

```r
library(valresultat)

# National result in the parliamentary election
valresultat(val = "RD")

# Regional election results at region level
valresultat(val = "RF")

# Municipal election results at municipality level
valresultat(val = "KF")

# Parliamentary election results by municipality
valresultat(val = "RD", niva = "kommun")

# Parliamentary election results by constituency
valresultat(val = "RD", niva = "riksdagsvalkrets")

# Mandate allocation
mandat(val = "RD")

# Candidates
kandidater(val = "RD")

# Personal votes by parliamentary constituency
personroster(val = "RD")

# Elected candidates
valda(val = "RD")

# Substitutes
ersattare(val = "RD")
```

For `valresultat()`, omitting `niva` returns the main level for the election:

- `RD` → `riket`
- `RF` → `region`
- `KF` → `kommun`

Supported geographic levels depend on the election type and on the official source data.

## Election results

`valresultat()` uses a common analysis core across geographic levels and counting
stages, while returning only the geographic columns relevant to the requested
level. Geographic identifiers appear early in the result.

For example:

```r
# Preliminary parliamentary result by voting district
valresultat(
  val = "RD",
  rakning = "preliminar",
  niva = "valdistrikt"
)

# Keep only voting districts that have reported a vote distribution
valresultat(
  val = "RD",
  rakning = "preliminar",
  niva = "valdistrikt"
) |>
  dplyr::filter(raknat)

# Final parliamentary result at national level
valresultat(
  val = "RD",
  rakning = "slutlig",
  niva = "riket"
)
```

At voting-district level, `raknat` distinguishes reported districts from valid
districts whose `rostfordelning` is still `NULL`. Unreported districts remain in
the table, with party rows from the official party universe and `NA` in current
result fields. An explicitly reported zero remains 0. Variables that are not
available are otherwise represented as typed `NA`.

The package uses official results at the requested geographic level when those
results are provided by Valmyndigheten rather than automatically reconstructing
them from lower-level data.

## Candidates and candidacies

`kandidaturer()` preserves detailed source information about individual candidacies. A person may appear several times because the same candidate can stand in several electoral areas, constituencies or lists.

`kandidater()` provides a more analysis-oriented candidate table. Its current observation level is candidate × election type × party.

```r
# Detailed candidacies
kandidaturer(val = "KF")

# Analysis-ready candidates
kandidater(val = "KF")

# Elected candidates
valda(val = "KF")
```

Candidate-result information is included when the corresponding final result data are available.

`personroster()` returns one row per candidate, party and actual personal-vote
area. Its `andel_personroster` is an unrounded proportion on the 0–1 scale.
Verified absence in complete source data is 0, while missing, partial or unclear
personal-vote material is represented by `NA`. The final RD 2026 source has
been checked against current live data. RF and KF currently have structural
fixture and rehearsal coverage and require renewed integration checks against
their final live files.

## Data access

`valresultat` reads public election data from Valmyndigheten. Source files can be accessed remotely or stored locally for reproducible analysis.

Normal calls use the live 2026 result collection, `val2026`. Rehearsal data
remain available for explicit testing or development with:

```r
options(valresultat.resultatsamling_2026 = "genrep2026")
```

The main source modes are:

- `source = "auto"` – use a local source file if it exists, otherwise use the remote source.
- `source = "local"` – use local files only; this mode never accesses the network.
- `source = "remote"` – use the remote source explicitly.

A local data directory can be supplied with `data_dir` or set for the R session:

```r
options(valresultat.data_dir = "C:/path/to/valdata")
```

Functions also support `update` and `archive` where relevant. Raw source files are deliberately kept outside the package repository.

## Geographic levels

Depending on election type and source availability, election results can be requested at geographic levels including:

- `valdistrikt`
- `kommun`
- `kommunvalkrets`
- `lan` (KF only)
- `region`
- `regionvalkrets`
- `riksdagsvalkrets`
- `riket`

RD/`lan` is not supported. RF/`lan` is documented in the source format but is
not activated until a final source has been verified; use `region` for RF.

## Current scope

The 2026 implementation currently includes support for:

- party vote results
- preliminary and final counting
- mandate allocation
- candidates and candidacies
- candidate-result and personal-vote information when available
- elected representatives
- substitutes
- local and remote source files
- optional local archiving of source files

Support for earlier elections is planned for a later stage.

## Status

The package should currently be regarded as experimental. Final individual
vote-distribution (D), subordinate summary (U) and mandate (M) paths have been
checked against selected Valmyndigheten 2026 rehearsal files. Preliminary
paths and superior summaries (O) are implemented and covered by deterministic
fixtures, but have not yet been verified against corresponding real local
files. Live election data may reveal additional source-format edge cases.

Bug reports and suggestions are welcome through the GitHub repository.

## License

MIT
