parse_mandat_2026 <- function(raw) {

  valtyp <- as_chr_na(raw$valtyp)

  niva_valomrade <- dplyr::recode_values(
    valtyp,
    "RD" ~ "riket",
    "RF" ~ "region",
    "KF" ~ "kommun",
    default = "valomrade"
  )

  niva_valkrets <- dplyr::recode_values(
    valtyp,
    "RD" ~ "riksdagsvalkrets",
    "RF" ~ "regionvalkrets",
    "KF" ~ "kommunvalkrets",
    default = "valkrets"
  )

  sum_int_na <- function(x) {
    if (length(x) == 0 || all(is.na(x))) {
      NA_integer_
    } else {
      as.integer(sum(x, na.rm = TRUE))
    }
  }

  parse_omrade <- function(obj,
                           geografiniva,
                           valkretsnamn = NA_character_,
                           valkretskod = NA_character_) {

    if (
      is.null(obj$mandatfordelning) ||
      is.null(obj$mandatfordelning$partiLista) ||
      length(obj$mandatfordelning$partiLista) == 0
    ) {
      return(NULL)
    }

    valomrade <- raw$valomrade

    partier <- obj$mandatfordelning$partiLista |>
      purrr::map(\(x) {
        tibble::tibble(
          partibeteckning = as_chr_na(x$partibeteckning),
          partiforkortning = as_chr_na(x$partiforkortning),
          partikod = as_chr_na(x$partikod),
          antal_mandat = as_int_na(x$antalMandat),
          antal_fasta_mandat = as_int_na(x$antalFastaMandat),
          antal_utjamningsmandat =
            as_int_na(x$antalUtjamningsmandat),
          antal_mandat_fg =
            as_int_na(x$antalMandatForegaendeVal),
          antal_fasta_mandat_fg =
            as_int_na(x$antalFastaMandatForegaendeVal),
          antal_utjamningsmandat_fg =
            as_int_na(x$antalUtjamningsMandatForegaendeVal),
          diff_antal_mandat =
            as_int_na(x$forandringAntalMandat)
        )
      }) |>
      purrr::list_rbind()

    totalt_antal_mandat <- as_int_na(obj$totaltAntalMandat)
    if (is.na(totalt_antal_mandat)) {
      totalt_antal_mandat <- sum_int_na(partier$antal_mandat)
    }

    totalt_antal_fasta_mandat <- as_int_na(obj$totaltAntalFastaMandat)
    if (is.na(totalt_antal_fasta_mandat)) {
      totalt_antal_fasta_mandat <-
        sum_int_na(partier$antal_fasta_mandat)
    }

    totalt_antal_utjamningsmandat <-
      as_int_na(obj$totaltAntalUtjamningsMandat)
    if (is.na(totalt_antal_utjamningsmandat)) {
      totalt_antal_utjamningsmandat <-
        sum_int_na(partier$antal_utjamningsmandat)
    }

    totalt_antal_mandat_fg <-
      as_int_na(obj$totaltAntalMandatForegaendeVal)
    if (is.na(totalt_antal_mandat_fg)) {
      totalt_antal_mandat_fg <-
        sum_int_na(partier$antal_mandat_fg)
    }

    totalt_antal_fasta_mandat_fg <-
      as_int_na(obj$totaltAntalFastaMandatForegaendeVal)
    if (is.na(totalt_antal_fasta_mandat_fg)) {
      totalt_antal_fasta_mandat_fg <-
        sum_int_na(partier$antal_fasta_mandat_fg)
    }

    totalt_antal_utjamningsmandat_fg <-
      as_int_na(obj$totaltAntalUtjamningsMandatForegaendeVal)
    if (is.na(totalt_antal_utjamningsmandat_fg)) {
      totalt_antal_utjamningsmandat_fg <-
        sum_int_na(partier$antal_utjamningsmandat_fg)
    }

    partier |>
      dplyr::transmute(
        # Val
        valtillfalle = as_chr_na(raw$valtillfalle),
        valklass = as_chr_na(raw$valklass),
        rakningstillfalle = as_chr_na(raw$rakningstillfalle),
        valtyp = valtyp,
        valdatum = as_chr_na(raw$valdatum),
        valdatum_fg = as_chr_na(raw$tidigareValdatum),
        test = as_lgl_na(raw$test),

        # Rapportering
        senaste_uppdateringstid =
          as_chr_na(raw$senasteUppdateringstid),
        antal_uppdateringar =
          as_int_na(raw$antalUppdateringar),
        rapporteringstid =
          as_chr_na(obj$rapporteringsTid),
        antal_valdistrikt_raknade =
          as_int_na(obj$antalValdistriktRaknade),
        antal_valdistrikt_som_ska_raknas =
          as_int_na(obj$antalValdistriktSomSkaRaknas),

        # Geografi
        geografiniva = geografiniva,
        valomradesnamn = as_chr_na(valomrade$namn),
        valomradeskod = as_chr_na(valomrade$kod),
        valkretsnamn = valkretsnamn,
        valkretskod = valkretskod,

        # Spärrar
        valomradessparr_procent =
          as_dbl_na(valomrade$valomradessparrProcent),
        valkretssparr_procent =
          as_dbl_na(valomrade$valkretssparrProcent),

        # Parti
        partibeteckning,
        partiforkortning,
        partikod,

        # Mandat
        antal_mandat,
        antal_fasta_mandat,
        antal_utjamningsmandat,
        totalt_antal_mandat = totalt_antal_mandat,
        totalt_antal_fasta_mandat =
          totalt_antal_fasta_mandat,
        totalt_antal_utjamningsmandat =
          totalt_antal_utjamningsmandat,

        # Föregående val
        antal_mandat_fg,
        antal_fasta_mandat_fg,
        antal_utjamningsmandat_fg,
        totalt_antal_mandat_fg =
          totalt_antal_mandat_fg,
        totalt_antal_fasta_mandat_fg =
          totalt_antal_fasta_mandat_fg,
        totalt_antal_utjamningsmandat_fg =
          totalt_antal_utjamningsmandat_fg,

        # Differens
        diff_antal_mandat,

        status_jamforelse =
          as_chr_na(obj$statusJamforelse)
      )
  }

  valomrade <- parse_omrade(
    raw$valomrade,
    geografiniva = niva_valomrade
  )

  valkretsar <- raw$valomrade$valkretsLista |>
    purrr::map(\(valkrets) {
      parse_omrade(
        valkrets,
        geografiniva = niva_valkrets,
        valkretsnamn = as_chr_na(valkrets$namnValkrets),
        valkretskod = as_chr_na(valkrets$kod)
      )
    }) |>
    purrr::compact() |>
    purrr::list_rbind()

  dplyr::bind_rows(
    valomrade,
    valkretsar
  )
}
