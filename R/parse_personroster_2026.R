parse_personroster_2026 <- function(raw) {

  vd <- raw$valdistrikt
  vd_id <- seq_along(vd)

  # Valdistrikt ------------------------------------------------------------

  distrikt <- tibble::tibble(
    vd_id = vd_id,
    rapporteringstid =
      purrr::map_chr(vd, \(x) as_chr_na(x$rapporteringsTid)),
    valdistriktsnamn =
      purrr::map_chr(vd, \(x) as_chr_na(x$namn)),
    valdistriktstyp =
      purrr::map_chr(vd, \(x) as_chr_na(x$valdistriktstyp)),
    valdistriktskod =
      purrr::map_chr(vd, \(x) as_chr_na(x$valdistriktskod)),
    kommunkod =
      purrr::map_chr(vd, \(x) as_chr_na(x$kommunkod)),
    lankod =
      purrr::map_chr(vd, \(x) as_chr_na(x$lankod)),
    valomradeskod =
      purrr::map_chr(vd, \(x) as_chr_na(x$valomradeskod)),
    kretskod =
      purrr::map_chr(vd, \(x) as_chr_na(x$kretskod)),
    kommunvalkretsnamn =
      purrr::map_chr(vd, \(x) as_chr_na(x$kommunvalkretsNamn)),
    kommunvalkretskod =
      purrr::map_chr(vd, \(x) as_chr_na(x$kommunvalkretsKod))
  )

  # Partier ---------------------------------------------------------------

  parti_list <- purrr::map(
    vd,
    \(x) x$rostfordelning$rosterPaverkaMandat$partiRoster
  )

  parti_flat <- unlist(
    parti_list,
    recursive = FALSE,
    use.names = FALSE
  )

  parti_id <- seq_along(parti_flat)

  partier <- tibble::tibble(
    parti_id = parti_id,
    vd_id = rep(vd_id, lengths(parti_list)),
    partibeteckning =
      purrr::map_chr(parti_flat, \(x) as_chr_na(x$partibeteckning)),
    partiforkortning =
      purrr::map_chr(parti_flat, \(x) as_chr_na(x$partiforkortning)),
    partikod =
      purrr::map_chr(parti_flat, \(x) as_chr_na(x$partikod)),
    fargkod =
      purrr::map_chr(parti_flat, \(x) as_chr_na(x$fargkod)),
    ordningsnummer =
      purrr::map_int(parti_flat, \(x) as_int_na(x$ordningsnummer))
  )

  # Listor ----------------------------------------------------------------

  list_list <- purrr::map(
    parti_flat,
    \(x) {
      if (is.null(x$listRoster)) {
        list()
      } else {
        x$listRoster
      }
    }
  )

  list_flat <- unlist(
    list_list,
    recursive = FALSE,
    use.names = FALSE
  )

  list_id <- seq_along(list_flat)

  listdata <- tibble::tibble(
    list_id = list_id,
    parti_id = rep(parti_id, lengths(list_list)),
    listnummer =
      purrr::map_chr(list_flat, \(x) as_chr_na(x$listnummer)),
    antal_roster_lista =
      purrr::map_int(list_flat, \(x) as_int_na(x$antalRoster)),
    antal_roster_med_personrost =
      purrr::map_int(
        list_flat,
        \(x) as_int_na(x$antalRosterMedPersonrost)
      )
  )

  # Personröster per lista ------------------------------------------------

  person_list <- purrr::map(
    list_flat,
    \(x) {
      if (is.null(x$personroster)) {
        list()
      } else {
        x$personroster
      }
    }
  )

  person_flat <- unlist(
    person_list,
    recursive = FALSE,
    use.names = FALSE
  )

  persondata <- tibble::tibble(
    list_id = rep(list_id, lengths(person_list)),
    kandidatnamn_lista =
      purrr::map_chr(person_flat, \(x) as_chr_na(x$namn)),
    kandidatnummer_pa_listan =
      purrr::map_int(
        person_flat,
        \(x) as_int_na(x$kandidatNummerPaListan)
      ),
    kandidatnummer =
      purrr::map_chr(
        person_flat,
        \(x) as_chr_na(x$kandidatNummer)
      ),
    antal_personroster =
      purrr::map_int(
        person_flat,
        \(x) as_int_na(x$antalPersonroster)
      )
  )

  # Summerade personröster per kandidat ----------------------------------

  summerad_list <- purrr::map(
    parti_flat,
    \(x) {
      if (is.null(x$summeradePersonroster)) {
        list()
      } else {
        x$summeradePersonroster
      }
    }
  )

  summerad_flat <- unlist(
    summerad_list,
    recursive = FALSE,
    use.names = FALSE
  )

  summeraddata <- tibble::tibble(
    parti_id = rep(parti_id, lengths(summerad_list)),
    kandidatnamn =
      purrr::map_chr(summerad_flat, \(x) as_chr_na(x$namn)),
    kandidatnummer =
      purrr::map_chr(
        summerad_flat,
        \(x) as_chr_na(x$kandidatnummer)
      ),
    antal_personroster =
      purrr::map_int(
        summerad_flat,
        \(x) as_int_na(x$antalPersonroster)
      )
  )

  # Gemensam metadata -----------------------------------------------------

  add_meta <- function(data) {
    data |>
      dplyr::mutate(
        valtillfalle = as_chr_na(raw$valtillfalle),
        valklass = as_chr_na(raw$valklass),
        rakningstillfalle = .normalisera_rakningstillfalle_2026(raw$rakningstillfalle),
        valtyp = as_chr_na(raw$valtyp),
        valdatum = as_chr_na(raw$valdatum),
        valdatum_fg = as_chr_na(raw$tidigareValdatum),
        test = as_lgl_na(raw$test),
        senaste_uppdateringstid =
          as_chr_na(raw$senasteUppdateringstid),
        antal_uppdateringar =
          as_int_na(raw$antalUppdateringar),
        antal_valdistrikt_raknade =
          as_int_na(raw$antalValdistriktRaknade),
        antal_valdistrikt_som_ska_raknas =
          as_int_na(raw$antalValdistriktSomSkaRaknas),
        geografiniva = "valdistrikt",
        .before = 1
      )
  }

  # Slutliga tabeller -----------------------------------------------------

  listroster <- listdata |>
    dplyr::left_join(
      partier,
      by = dplyr::join_by(parti_id)
    ) |>
    dplyr::left_join(
      distrikt,
      by = dplyr::join_by(vd_id)
    ) |>
    dplyr::select(-list_id, -parti_id, -vd_id) |>
    add_meta()

  personroster <- persondata |>
    dplyr::left_join(
      listdata,
      by = dplyr::join_by(list_id)
    ) |>
    dplyr::left_join(
      partier,
      by = dplyr::join_by(parti_id)
    ) |>
    dplyr::left_join(
      distrikt,
      by = dplyr::join_by(vd_id)
    ) |>
    dplyr::select(-list_id, -parti_id, -vd_id) |>
    add_meta()

  personroster_summerade <- summeraddata |>
    dplyr::left_join(
      partier,
      by = dplyr::join_by(parti_id)
    ) |>
    dplyr::left_join(
      distrikt,
      by = dplyr::join_by(vd_id)
    ) |>
    dplyr::select(-parti_id, -vd_id) |>
    add_meta()

  list(
    listroster = listroster,
    personroster = personroster,
    personroster_summerade = personroster_summerade
  )
}
