parse_rostfordelning_mandat_2026 <- function(raw) {

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

  ja_nej_logisk <- function(x) {
    x <- as_chr_na(x)

    dplyr::recode_values(
      tolower(x),
      "ja" ~ TRUE,
      "nej" ~ FALSE,
      default = NA
    )
  }

  parse_partirader <- function(rostfordelning) {

    if (is.null(rostfordelning)) {
      return(NULL)
    }

    giltiga <- rostfordelning$rosterPaverkaMandat

    partier <- giltiga$partiRoster |>
      purrr::map(\(x) {
        tibble::tibble(
          partibeteckning = as_chr_na(x$partibeteckning),
          partiforkortning = as_chr_na(x$partiforkortning),
          partikod = as_chr_na(x$partikod),
          fargkod = as_chr_na(x$fargkod),
          ordningsnummer = as_int_na(x$ordningsnummer),
          ovriga_partier = FALSE,
          over_sparr = ja_nej_logisk(x$deltaMandatfordelning),
          antal_roster = as_int_na(x$antalRoster),
          andel_roster = as_dbl_na(x$andelRoster),
          antal_roster_fg = as_int_na(x$antalRosterForegaendeVal),
          andel_roster_fg = as_dbl_na(x$andelRosterForegaendeVal),
          diff_antal_roster = as_int_na(x$forandringAntalRoster),
          diff_andel_roster = as_dbl_na(x$forandringAndelRoster)
        )
      }) |>
      purrr::list_rbind()

    ovriga <- tibble::tibble(
      partibeteckning = "\u00d6vriga partier",
      partiforkortning = NA_character_,
      partikod = NA_character_,
      fargkod = NA_character_,
      ordningsnummer = NA_integer_,
      ovriga_partier = TRUE,
      over_sparr = NA,
      antal_roster =
        as_int_na(giltiga$rosterOvrigaPartier$antalRoster),
      andel_roster =
        as_dbl_na(giltiga$rosterOvrigaPartier$andelRoster),
      antal_roster_fg =
        as_int_na(giltiga$rosterOvrigaPartier$antalRosterForegaendeVal),
      andel_roster_fg =
        as_dbl_na(giltiga$rosterOvrigaPartier$andelRosterForegaendeVal),
      diff_antal_roster =
        as_int_na(giltiga$rosterOvrigaPartier$forandringAntalRoster),
      diff_andel_roster =
        as_dbl_na(giltiga$rosterOvrigaPartier$forandringAndelRoster)
    )

    dplyr::bind_rows(partier, ovriga)
  }

  parse_omrade <- function(obj,
                           geografiniva,
                           valkretsnamn = NA_character_,
                           valkretskod = NA_character_) {

    if (is.null(obj$rostfordelning)) {
      return(NULL)
    }

    giltiga <- obj$rostfordelning$rosterPaverkaMandat
    ogiltiga <- obj$rostfordelning$rosterEjPaverkaMandat
    valomrade <- raw$valomrade

    parse_partirader(obj$rostfordelning) |>
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
        antal_rostberattigade_raknade =
          as_int_na(obj$antalRostberattigadeIRaknadeValdistrikt),

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
        fargkod,
        ordningsnummer,
        ovriga_partier,
        over_sparr,

        # Aktuellt resultat
        antal_roster,
        andel_roster,
        totalt_antal_roster =
          as_int_na(obj$totaltAntalRoster),
        antal_rostberattigade =
          as_int_na(obj$antalRostberattigade),
        valdel =
          as_dbl_na(obj$valdeltagande),
        giltiga_roster =
          as_int_na(giltiga$antalRoster),
        ogiltiga_roster =
          as_int_na(ogiltiga$antalRoster),
        andel_ogiltiga =
          as_dbl_na(ogiltiga$andelRosterAvTotaltAntalRoster),
        roster_ej_anmalt_deltagande =
          as_int_na(
            ogiltiga$rosterEjAnmaltDeltagande$antalRoster
          ),
        andel_ej_anmalt_deltagande =
          as_dbl_na(
            ogiltiga$rosterEjAnmaltDeltagande$
              andelRosterAvTotaltAntalRoster
          ),
        blanka_roster =
          as_int_na(ogiltiga$blankaRoster$antalRoster),
        andel_blanka =
          as_dbl_na(
            ogiltiga$blankaRoster$andelRosterAvTotaltAntalRoster
          ),
        ovriga_ogiltiga =
          as_int_na(ogiltiga$ovrigaOgiltiga$antalRoster),
        andel_ovriga_ogiltiga =
          as_dbl_na(
            ogiltiga$ovrigaOgiltiga$andelRosterAvTotaltAntalRoster
          ),

        # Föregående val
        antal_roster_fg,
        andel_roster_fg,
        totalt_antal_roster_fg =
          as_int_na(obj$totaltAntalRosterForegaendeVal),
        antal_rostberattigade_fg =
          as_int_na(obj$antalRostberattigadeForegaendeVal),
        valdel_fg =
          as_dbl_na(obj$valdeltagandeForegaendeVal),
        giltiga_roster_fg =
          as_int_na(giltiga$antalRosterForegaendeVal),
        ogiltiga_roster_fg =
          as_int_na(ogiltiga$antalRosterForegaendeVal),
        andel_ogiltiga_fg =
          as_dbl_na(
            ogiltiga$andelRosterAvTotaltAntalRosterForegaendeVal
          ),
        roster_ej_anmalt_deltagande_fg =
          as_int_na(
            ogiltiga$rosterEjAnmaltDeltagande$
              antalRosterForegaendeVal
          ),
        andel_ej_anmalt_deltagande_fg =
          as_dbl_na(
            ogiltiga$rosterEjAnmaltDeltagande$
              andelRosterAvTotaltAntalRosterForegaendeVal
          ),
        blanka_roster_fg =
          as_int_na(
            ogiltiga$blankaRoster$antalRosterForegaendeVal
          ),
        andel_blanka_fg =
          as_dbl_na(
            ogiltiga$blankaRoster$
              andelRosterAvTotaltAntalRosterForegaendeVal
          ),
        ovriga_ogiltiga_fg =
          as_int_na(
            ogiltiga$ovrigaOgiltiga$antalRosterForegaendeVal
          ),
        andel_ovriga_ogiltiga_fg =
          as_dbl_na(
            ogiltiga$ovrigaOgiltiga$
              andelRosterAvTotaltAntalRosterForegaendeVal
          ),

        # Differenser
        diff_antal_roster,
        diff_andel_roster,
        diff_totalt_antal_roster =
          as_int_na(obj$forandringTotaltAntalRoster),
        diff_antal_rostberattigade =
          as_int_na(obj$forandringAntalRostberattigade),
        diff_valdel =
          as_dbl_na(obj$forandringValdeltagande),
        diff_giltiga_roster =
          as_int_na(giltiga$forandringAntalRoster),
        diff_ogiltiga_roster =
          as_int_na(ogiltiga$forandringAntalRoster),
        diff_andel_ogiltiga =
          as_dbl_na(
            ogiltiga$forandringAndelRosterAvTotaltAntalRoster
          ),
        diff_roster_ej_anmalt_deltagande =
          as_int_na(
            ogiltiga$rosterEjAnmaltDeltagande$
              forandringAntalRoster
          ),
        diff_andel_ej_anmalt_deltagande =
          as_dbl_na(
            ogiltiga$rosterEjAnmaltDeltagande$
              forandringAndelRosterAvTotaltAntalRoster
          ),
        diff_blanka_roster =
          as_int_na(
            ogiltiga$blankaRoster$forandringAntalRoster
          ),
        diff_andel_blanka =
          as_dbl_na(
            ogiltiga$blankaRoster$
              forandringAndelRosterAvTotaltAntalRoster
          ),
        diff_ovriga_ogiltiga =
          as_int_na(
            ogiltiga$ovrigaOgiltiga$forandringAntalRoster
          ),
        diff_andel_ovriga_ogiltiga =
          as_dbl_na(
            ogiltiga$ovrigaOgiltiga$
              forandringAndelRosterAvTotaltAntalRoster
          ),

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
