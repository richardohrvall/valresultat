# valresultat

`valresultat` is an R package for downloading, parsing and analysing Swedish election data from Valmyndigheten.

The aim is to provide analysis-ready data on election results, mandates, candidates, candidacies, elected representatives and substitutes while preserving important information from the official source files.

> [!WARNING]
> `valresultat` is under active development. Development currently focuses on the 2026 Swedish elections, and the public API and data structures may still change. The current 2026 implementation has primarily been developed and tested against Valmyndigheten's public rehearsal/test data.

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

`valresultat()` returns party results in a common, harmonised structure across geographic levels and counting stages as far as the source material allows.

For example:

```r
# Preliminary parliamentary result by voting district
valresultat(
  val = "RD",
  rakning = "preliminar",
  niva = "valdistrikt"
)

# Final parliamentary result at national level
valresultat(
  val = "RD",
  rakning = "slutlig",
  niva = "riket"
)
```

Variables that are not applicable or not available in a particular source are represented as `NA`. The package uses official results at the requested geographic level when such results are provided by Valmyndigheten rather than automatically reconstructing them from lower-level data.

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

## Data access

`valresultat` reads public election data from Valmyndigheten. Source files can be accessed remotely or stored locally for reproducible analysis.

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
- `region`
- `regionvalkrets`
- `riksdagsvalkrets`
- `riket`

Some additional geographic summaries documented by Valmyndigheten are not yet exposed in the current version.

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

The package should currently be regarded as experimental. The code has automated tests and the implemented 2026 result paths have been checked against available Valmyndigheten rehearsal files. Live election data may reveal additional source-format edge cases.

Bug reports and suggestions are welcome through the GitHub repository.

## License

MIT
