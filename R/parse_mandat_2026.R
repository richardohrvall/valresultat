.mandat_schema_2026 <- function() {
  tibble::tibble(
    valtillfalle = character(), valklass = character(),
    rakningstillfalle = character(), valtyp = character(),
    valdatum = character(), valdatum_fg = character(), test = logical(),
    senaste_uppdateringstid = character(), antal_uppdateringar = integer(),
    rapporteringstid = character(), antal_valdistrikt_raknade = integer(),
    antal_valdistrikt_som_ska_raknas = integer(), geografiniva = character(),
    valomradesnamn = character(), valomradeskod = character(),
    valkretsnamn = character(), valkretskod = character(),
    valomradessparr_procent = double(), valkretssparr_procent = double(),
    partibeteckning = character(), partiforkortning = character(),
    partikod = character(), antal_mandat = integer(),
    antal_fasta_mandat = integer(), antal_utjamningsmandat = integer(),
    totalt_antal_mandat = integer(), totalt_antal_fasta_mandat = integer(),
    totalt_antal_utjamningsmandat = integer(), antal_mandat_fg = integer(),
    antal_fasta_mandat_fg = integer(), antal_utjamningsmandat_fg = integer(),
    totalt_antal_mandat_fg = integer(), totalt_antal_fasta_mandat_fg = integer(),
    totalt_antal_utjamningsmandat_fg = integer(), diff_antal_mandat = integer(),
    status_jamforelse = character()
  )
}

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

  mandat_heltal <- function(x, namn) {
    if (is.null(x)) return(NA_integer_)
    if (length(x) == 1L && is.atomic(x) && is.na(x)) return(NA_integer_)
    if (!is.numeric(x) || length(x) != 1L || !is.finite(x) ||
        x < 0 || x != trunc(x) || x > .Machine$integer.max) {
      stop("Mandatf\u00e4ltet `", namn, "` ska vara ett icke-negativt heltal.",
           call. = FALSE)
    }
    as.integer(x)
  }

  total_mandat <- function(raw_total, komponenter, namn,
                           kontrollera_summa = TRUE) {
    total <- mandat_heltal(raw_total, namn)
    if (!is.na(total)) {
      if (kontrollera_summa && length(komponenter) > 0L &&
          !anyNA(komponenter) &&
          sum(as.double(komponenter)) != total) {
        stop("Mandattotalen `", namn, "` st\u00e4mmer inte med partiernas mandat.",
             call. = FALSE)
      }
      return(total)
    }
    if (!length(komponenter) || anyNA(komponenter)) return(NA_integer_)
    summa <- sum(as.double(komponenter))
    if (!is.finite(summa) || summa > .Machine$integer.max) return(NA_integer_)
    as.integer(summa)
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
          antal_mandat = mandat_heltal(x[["antalMandat"]], "antalMandat"),
          antal_fasta_mandat = mandat_heltal(x[["antalFastaMandat"]], "antalFastaMandat"),
          antal_utjamningsmandat =
            mandat_heltal(x[["antalUtjamningsmandat"]], "antalUtjamningsmandat"),
          antal_mandat_fg =
            mandat_heltal(x[["antalMandatForegaendeVal"]], "antalMandatForegaendeVal"),
          antal_fasta_mandat_fg =
            mandat_heltal(x[["antalFastaMandatForegaendeVal"]], "antalFastaMandatForegaendeVal"),
          antal_utjamningsmandat_fg =
            mandat_heltal(x[["antalUtjamningsMandatForegaendeVal"]], "antalUtjamningsMandatForegaendeVal"),
          diff_antal_mandat =
            as_int_na(x$forandringAntalMandat)
        )
      }) |>
      purrr::list_rbind()

    totalt_antal_mandat <- total_mandat(
      obj[["totaltAntalMandat"]], partier$antal_mandat, "totaltAntalMandat"
    )
    totalt_antal_fasta_mandat <- total_mandat(
      obj[["totaltAntalFastaMandat"]], partier$antal_fasta_mandat,
      "totaltAntalFastaMandat"
    )
    totalt_antal_utjamningsmandat <- total_mandat(
      obj[["totaltAntalUtjamningsMandat"]], partier$antal_utjamningsmandat,
      "totaltAntalUtjamningsMandat"
    )
    totalt_antal_mandat_fg <- total_mandat(
      obj[["totaltAntalMandatForegaendeVal"]], partier$antal_mandat_fg,
      "totaltAntalMandatForegaendeVal", kontrollera_summa = FALSE
    )
    totalt_antal_fasta_mandat_fg <- total_mandat(
      obj[["totaltAntalFastaMandatForegaendeVal"]], partier$antal_fasta_mandat_fg,
      "totaltAntalFastaMandatForegaendeVal", kontrollera_summa = FALSE
    )
    totalt_antal_utjamningsmandat_fg <- total_mandat(
      obj[["totaltAntalUtjamningsMandatForegaendeVal"]],
      partier$antal_utjamningsmandat_fg,
      "totaltAntalUtjamningsMandatForegaendeVal", kontrollera_summa = FALSE
    )

    partier |>
      dplyr::transmute(
        # Val
        valtillfalle = as_chr_na(raw$valtillfalle),
        valklass = as_chr_na(raw$valklass),
        rakningstillfalle = .normalisera_rakningstillfalle_2026(raw$rakningstillfalle),
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

  dplyr::bind_rows(.mandat_schema_2026(), valomrade, valkretsar)
}
