parse_valdistriktskoppling_2026 <- function(raw) {

  vd <- raw$valdistrikt

  kopplingar <- purrr::map(
    vd,
    \(x) x$valdistriktskodForegaendeVal
  )

  n_kopplingar <- lengths(kopplingar)

  tibble::tibble(
    valtyp = as_chr_na(raw$valtyp),
    valdatum = as_chr_na(raw$valdatum),
    valdatum_fg = as_chr_na(raw$tidigareValdatum),
    valdistriktskod = rep(
      purrr::map_chr(vd, \(x) as_chr_na(x$valdistriktskod)),
      n_kopplingar
    ),
    valdistriktsnamn = rep(
      purrr::map_chr(vd, \(x) as_chr_na(x$namn)),
      n_kopplingar
    ),
    valdistriktskod_fg = unlist(
      kopplingar,
      use.names = FALSE
    ),
    status_jamforelse = rep(
      purrr::map_chr(vd, \(x) as_chr_na(x$statusJamforelse)),
      n_kopplingar
    )
  )
}
