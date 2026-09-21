# Bygger paketets interna lookup för korta, analysvänliga kommunnamn.
# Källan är data-raw/kommunnamn.csv, sammanställd för paketet med en rad per
# svensk kommun och SCB:s/Valmyndighetens fyrsiffriga kommunkod.

library(readr)
library(tibble)

kommunnamn_2026 <- read_csv(
  "data-raw/kommunnamn.csv",
  col_types = cols(kommun = col_character(), llkk = col_character()),
  show_col_types = FALSE
)

stopifnot(
  identical(names(kommunnamn_2026), c("kommun", "llkk")),
  nrow(kommunnamn_2026) == 290L,
  length(unique(kommunnamn_2026$llkk)) == 290L,
  !anyNA(kommunnamn_2026$llkk),
  !anyNA(kommunnamn_2026$kommun),
  all(nzchar(kommunnamn_2026$llkk)),
  all(nzchar(kommunnamn_2026$kommun)),
  all(grepl("^[0-9]{4}$", kommunnamn_2026$llkk))
)

kommunnamn_2026 <- tibble(
  kommunkod = kommunnamn_2026$llkk,
  kommunnamn = kommunnamn_2026$kommun
)

kontroll <- c(
  "0180" = "Stockholm", "0184" = "Solna",
  "0980" = "Gotland", "2061" = "Smedjebacken"
)
stopifnot(identical(
  setNames(kommunnamn_2026$kommunnamn, kommunnamn_2026$kommunkod)[names(kontroll)],
  kontroll
))

save(kommunnamn_2026, file = "R/sysdata.rda", version = 2, compress = "xz")
