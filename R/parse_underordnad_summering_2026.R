parse_underordnad_summering_2026 <- function(raw) {

  if (!as_chr_na(raw$valtyp) %in% c("RD", "RF")) {
    stop(
      "Parsern st\u00f6der endast underordnad summering f\u00f6r RD och RF.",
      call. = FALSE
    )
  }

  parse_partirader <- function(rostfordelning) {

    giltiga <- rostfordelning$rosterPaverkaMandat

    partirader <- giltiga$partiRoster |>
      purrr::map(\(x) {
        tibble::tibble(
          partibeteckning = as_chr_na(x$partibeteckning),
          partiforkortning = as_chr_na(x$partiforkortning),
          partikod = as_chr_na(x$partikod),
          fargkod = as_chr_na(x$fargkod),
          ordningsnummer = as_int_na(x$ordningsnummer),
          ovriga_partier = FALSE,
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

    dplyr::bind_rows(partirader, ovriga)
  }

  parse_omrade <- function(obj,
                           geografiniva,
                           lankod,
                           kommunnamn,
                           kommunkod,
                           kommunvalkretsnamn = NA_character_,
                           kommunvalkretskod = NA_character_) {

    if (!.rostfordelning_tillganglig_2026(obj)) return(NULL)

    giltiga <- obj$rostfordelning$rosterPaverkaMandat
    ogiltiga <- obj$rostfordelning$rosterEjPaverkaMandat

    parse_partirader(obj$rostfordelning) |>
      dplyr::transmute(
        # Val
        valtillfalle = as_chr_na(raw$valtillfalle),
        valklass = as_chr_na(raw$valklass),
        rakningstillfalle = .normalisera_rakningstillfalle_2026(raw$rakningstillfalle),
        valtyp = as_chr_na(raw$valtyp),
        valdatum = as_chr_na(raw$valdatum),
        valdatum_fg = as_chr_na(raw$tidigareValdatum),
        test = as_lgl_na(raw$test),

        # Rapportering
        senaste_uppdateringstid =
          as_chr_na(raw$senasteUppdateringstid),
        antal_uppdateringar =
          as_int_na(raw$antalUppdateringar),
        antal_valdistrikt_raknade =
          as_int_na(raw$antalValdistriktRaknade),
        antal_valdistrikt_som_ska_raknas =
          as_int_na(raw$antalValdistriktSomSkaRaknas),
        senaste_uppdateringstid_omrade =
          as_chr_na(obj$senasteUppdateringstid),
        rapporteringstid =
          as_chr_na(obj$senasteRapporteringstid),
        antal_valdistrikt_raknade_omrade =
          as_int_na(obj$antalValdistriktRaknade),
        antal_valdistrikt_som_ska_raknas_omrade =
          as_int_na(obj$antalValdistriktSomSkaRaknas),
        antal_rostberattigade_raknade =
          as_int_na(obj$antalRostberattigadeIRaknadeValdistrikt),

        # Geografi
        geografiniva = geografiniva,
        lannamn = NA_character_,
        lankod = lankod,
        kommunnamn = kommunnamn,
        kommunkod = kommunkod,
        kommunvalkretsnamn = kommunvalkretsnamn,
        kommunvalkretskod = kommunvalkretskod,

        # Parti
        partibeteckning,
        partiforkortning,
        partikod,
        fargkod,
        ordningsnummer,
        ovriga_partier,

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

  kommuner <- raw$kommuner |>
    purrr::map(\(kommun) {
      parse_omrade(
        kommun,
        geografiniva = "kommun",
        lankod = as_chr_na(kommun$lankod),
        kommunnamn = as_chr_na(kommun$namn),
        kommunkod = as_chr_na(kommun$kommunkod)
      )
    }) |>
    purrr::list_rbind()

  kommunvalkretsar <- raw$kommuner |>
    purrr::map(\(kommun) {

      kretser <- kommun$kommunvalkretsar

      if (is.null(kretser) || length(kretser) == 0) {
        return(NULL)
      }

      kretser |>
        purrr::map(\(krets) {
          parse_omrade(
            krets,
            geografiniva = "kommunvalkrets",
            lankod = as_chr_na(kommun$lankod),
            kommunnamn = as_chr_na(kommun$namn),
            kommunkod = as_chr_na(kommun$kommunkod),
            kommunvalkretsnamn = as_chr_na(krets$namn),
            kommunvalkretskod = as_chr_na(krets$kod)
          )
        }) |>
        purrr::list_rbind()
    }) |>
    purrr::compact() |>
    purrr::list_rbind()

  dplyr::bind_rows(
    kommuner,
    kommunvalkretsar
  )
}
