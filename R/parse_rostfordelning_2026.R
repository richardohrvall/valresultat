parse_rostfordelning_2026 <- function(raw) {

  vd <- raw$valdistrikt
  rapporterade <- vapply(
    vd,
    \(x) .rostfordelning_tillganglig_2026(x, "valdistrikt"),
    logical(1)
  )
  antal_raknade <- as_int_na(raw$antalValdistriktRaknade)
  antal_som_ska_raknas <- as_int_na(raw$antalValdistriktSomSkaRaknas)
  if (!is.na(antal_som_ska_raknas) && antal_som_ska_raknas != length(vd)) {
    stop("Antalet valdistrikt st\u00e4mmer inte med `antalValdistriktSomSkaRaknas`.",
         call. = FALSE)
  }
  if (!is.na(antal_raknade) && antal_raknade != sum(rapporterade)) {
    stop("Rapporterade valdistrikt st\u00e4mmer inte med `antalValdistriktRaknade`.",
         call. = FALSE)
  }
  vd <- vd[rapporterade]
  vd_id <- seq_along(vd)

  # Distriktsnivå ----------------------------------------------------------

  distrikt <- tibble::tibble(
    vd_id = vd_id,

    # Rapportering
    rapporteringstid =
      purrr::map_chr(vd, \(x) as_chr_na(x$rapporteringsTid)),

    # Geografi
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
      purrr::map_chr(vd, \(x) as_chr_na(x$kommunvalkretsKod)),

    # Aktuellt resultat
    totalt_antal_roster =
      purrr::map_int(vd, \(x) as_int_na(x$totaltAntalRoster)),
    antal_rostberattigade =
      purrr::map_int(vd, \(x) as_int_na(x$antalRostberattigade)),
    valdel =
      purrr::map_dbl(vd, \(x) as_dbl_na(x$valdeltagandeVallokal)),

    giltiga_roster =
      purrr::map_int(
        vd,
        \(x) as_int_na(
          x$rostfordelning$rosterPaverkaMandat$antalRoster
        )
      ),

    ogiltiga_roster =
      purrr::map_int(
        vd,
        \(x) as_int_na(
          x$rostfordelning$rosterEjPaverkaMandat$antalRoster
        )
      ),
    andel_ogiltiga =
      purrr::map_dbl(
        vd,
        \(x) as_dbl_na(
          x$rostfordelning$rosterEjPaverkaMandat$
            andelRosterAvTotaltAntalRoster
        )
      ),

    roster_ej_anmalt_deltagande =
      purrr::map_int(
        vd,
        \(x) as_int_na(
          x$rostfordelning$rosterEjPaverkaMandat$
            rosterEjAnmaltDeltagande$antalRoster
        )
      ),
    andel_ej_anmalt_deltagande =
      purrr::map_dbl(
        vd,
        \(x) as_dbl_na(
          x$rostfordelning$rosterEjPaverkaMandat$
            rosterEjAnmaltDeltagande$andelRosterAvTotaltAntalRoster
        )
      ),

    blanka_roster =
      purrr::map_int(
        vd,
        \(x) as_int_na(
          x$rostfordelning$rosterEjPaverkaMandat$
            blankaRoster$antalRoster
        )
      ),
    andel_blanka =
      purrr::map_dbl(
        vd,
        \(x) as_dbl_na(
          x$rostfordelning$rosterEjPaverkaMandat$
            blankaRoster$andelRosterAvTotaltAntalRoster
        )
      ),

    ovriga_ogiltiga =
      purrr::map_int(
        vd,
        \(x) as_int_na(
          x$rostfordelning$rosterEjPaverkaMandat$
            ovrigaOgiltiga$antalRoster
        )
      ),
    andel_ovriga_ogiltiga =
      purrr::map_dbl(
        vd,
        \(x) as_dbl_na(
          x$rostfordelning$rosterEjPaverkaMandat$
            ovrigaOgiltiga$andelRosterAvTotaltAntalRoster
        )
      ),

    # Föregående val
    totalt_antal_roster_fg =
      purrr::map_int(vd, \(x) as_int_na(x$totaltAntalRosterForegaendeVal)),
    antal_rostberattigade_fg =
      purrr::map_int(vd, \(x) as_int_na(x$antalRostberattigadeForegaendeVal)),
    valdel_fg =
      purrr::map_dbl(vd, \(x) as_dbl_na(x$valdeltagandeForegaendeVal)),

    giltiga_roster_fg =
      purrr::map_int(
        vd,
        \(x) as_int_na(
          x$rostfordelning$rosterPaverkaMandat$
            antalRosterForegaendeVal
        )
      ),

    ogiltiga_roster_fg =
      purrr::map_int(
        vd,
        \(x) as_int_na(
          x$rostfordelning$rosterEjPaverkaMandat$
            antalRosterForegaendeVal
        )
      ),
    andel_ogiltiga_fg =
      purrr::map_dbl(
        vd,
        \(x) as_dbl_na(
          x$rostfordelning$rosterEjPaverkaMandat$
            andelRosterAvTotaltAntalRosterForegaendeVal
        )
      ),

    roster_ej_anmalt_deltagande_fg =
      purrr::map_int(
        vd,
        \(x) as_int_na(
          x$rostfordelning$rosterEjPaverkaMandat$
            rosterEjAnmaltDeltagande$antalRosterForegaendeVal
        )
      ),
    andel_ej_anmalt_deltagande_fg =
      purrr::map_dbl(
        vd,
        \(x) as_dbl_na(
          x$rostfordelning$rosterEjPaverkaMandat$
            rosterEjAnmaltDeltagande$
            andelRosterAvTotaltAntalRosterForegaendeVal
        )
      ),

    blanka_roster_fg =
      purrr::map_int(
        vd,
        \(x) as_int_na(
          x$rostfordelning$rosterEjPaverkaMandat$
            blankaRoster$antalRosterForegaendeVal
        )
      ),
    andel_blanka_fg =
      purrr::map_dbl(
        vd,
        \(x) as_dbl_na(
          x$rostfordelning$rosterEjPaverkaMandat$
            blankaRoster$
            andelRosterAvTotaltAntalRosterForegaendeVal
        )
      ),

    ovriga_ogiltiga_fg =
      purrr::map_int(
        vd,
        \(x) as_int_na(
          x$rostfordelning$rosterEjPaverkaMandat$
            ovrigaOgiltiga$antalRosterForegaendeVal
        )
      ),
    andel_ovriga_ogiltiga_fg =
      purrr::map_dbl(
        vd,
        \(x) as_dbl_na(
          x$rostfordelning$rosterEjPaverkaMandat$
            ovrigaOgiltiga$
            andelRosterAvTotaltAntalRosterForegaendeVal
        )
      ),

    # Differenser
    diff_totalt_antal_roster =
      purrr::map_int(vd, \(x) as_int_na(x$forandringTotaltAntalRoster)),
    diff_antal_rostberattigade =
      purrr::map_int(vd, \(x) as_int_na(x$forandringAntalRostberattigade)),
    diff_valdel =
      purrr::map_dbl(vd, \(x) as_dbl_na(x$forandringValdeltagande)),

    diff_giltiga_roster =
      purrr::map_int(
        vd,
        \(x) as_int_na(
          x$rostfordelning$rosterPaverkaMandat$
            forandringAntalRoster
        )
      ),

    diff_ogiltiga_roster =
      purrr::map_int(
        vd,
        \(x) as_int_na(
          x$rostfordelning$rosterEjPaverkaMandat$
            forandringAntalRoster
        )
      ),
    diff_andel_ogiltiga =
      purrr::map_dbl(
        vd,
        \(x) as_dbl_na(
          x$rostfordelning$rosterEjPaverkaMandat$
            forandringAndelRosterAvTotaltAntalRoster
        )
      ),

    diff_roster_ej_anmalt_deltagande =
      purrr::map_int(
        vd,
        \(x) as_int_na(
          x$rostfordelning$rosterEjPaverkaMandat$
            rosterEjAnmaltDeltagande$forandringAntalRoster
        )
      ),
    diff_andel_ej_anmalt_deltagande =
      purrr::map_dbl(
        vd,
        \(x) as_dbl_na(
          x$rostfordelning$rosterEjPaverkaMandat$
            rosterEjAnmaltDeltagande$
            forandringAndelRosterAvTotaltAntalRoster
        )
      ),

    diff_blanka_roster =
      purrr::map_int(
        vd,
        \(x) as_int_na(
          x$rostfordelning$rosterEjPaverkaMandat$
            blankaRoster$forandringAntalRoster
        )
      ),
    diff_andel_blanka =
      purrr::map_dbl(
        vd,
        \(x) as_dbl_na(
          x$rostfordelning$rosterEjPaverkaMandat$
            blankaRoster$
            forandringAndelRosterAvTotaltAntalRoster
        )
      ),

    diff_ovriga_ogiltiga =
      purrr::map_int(
        vd,
        \(x) as_int_na(
          x$rostfordelning$rosterEjPaverkaMandat$
            ovrigaOgiltiga$forandringAntalRoster
        )
      ),
    diff_andel_ovriga_ogiltiga =
      purrr::map_dbl(
        vd,
        \(x) as_dbl_na(
          x$rostfordelning$rosterEjPaverkaMandat$
            ovrigaOgiltiga$
            forandringAndelRosterAvTotaltAntalRoster
        )
      ),

    status_jamforelse =
      purrr::map_chr(vd, \(x) as_chr_na(x$statusJamforelse))
  )

  # Vanliga partirader -----------------------------------------------------

  parti_list <- purrr::map(
    vd,
    \(x) x$rostfordelning$rosterPaverkaMandat$partiRoster
  )

  parti_flat <- unlist(
    parti_list,
    recursive = FALSE,
    use.names = FALSE
  )

  partier <- tibble::tibble(
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
      purrr::map_int(parti_flat, \(x) as_int_na(x$ordningsnummer)),
    ovriga_partier = FALSE,
    antal_roster =
      purrr::map_int(parti_flat, \(x) as_int_na(x$antalRoster)),
    andel_roster =
      purrr::map_dbl(parti_flat, \(x) as_dbl_na(x$andelRoster)),
    antal_roster_fg =
      purrr::map_int(parti_flat, \(x) as_int_na(x$antalRosterForegaendeVal)),
    andel_roster_fg =
      purrr::map_dbl(parti_flat, \(x) as_dbl_na(x$andelRosterForegaendeVal)),
    diff_antal_roster =
      purrr::map_int(parti_flat, \(x) as_int_na(x$forandringAntalRoster)),
    diff_andel_roster =
      purrr::map_dbl(parti_flat, \(x) as_dbl_na(x$forandringAndelRoster))
  )

  # Övriga partier --------------------------------------------------------

  ovriga_list <- purrr::map(
    vd,
    \(x) x$rostfordelning$rosterPaverkaMandat$rosterOvrigaPartier
  )

  ovriga <- tibble::tibble(
    vd_id = vd_id,
    partibeteckning = "\u00d6vriga partier",
    partiforkortning = NA_character_,
    partikod = NA_character_,
    fargkod = NA_character_,
    ordningsnummer = NA_integer_,
    ovriga_partier = TRUE,
    antal_roster =
      purrr::map_int(ovriga_list, \(x) as_int_na(x$antalRoster)),
    andel_roster =
      purrr::map_dbl(ovriga_list, \(x) as_dbl_na(x$andelRoster)),
    antal_roster_fg =
      purrr::map_int(ovriga_list, \(x) as_int_na(x$antalRosterForegaendeVal)),
    andel_roster_fg =
      purrr::map_dbl(ovriga_list, \(x) as_dbl_na(x$andelRosterForegaendeVal)),
    diff_antal_roster =
      purrr::map_int(ovriga_list, \(x) as_int_na(x$forandringAntalRoster)),
    diff_andel_roster =
      purrr::map_dbl(ovriga_list, \(x) as_dbl_na(x$forandringAndelRoster))
  )

  # Slutligt dataset ------------------------------------------------------

  dplyr::bind_rows(partier, ovriga) |>
    dplyr::arrange(vd_id, ovriga_partier, ordningsnummer) |>
    dplyr::left_join(distrikt, by = dplyr::join_by(vd_id)) |>
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
      rapporteringstid,

      # Geografi
      geografiniva = "valdistrikt",
      valdistriktsnamn,
      valdistriktstyp,
      valdistriktskod,
      kommunkod,
      lankod,
      valomradeskod,
      kretskod,
      kommunvalkretsnamn,
      kommunvalkretskod,

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
      totalt_antal_roster,
      antal_rostberattigade,
      valdel,
      giltiga_roster,
      ogiltiga_roster,
      andel_ogiltiga,
      roster_ej_anmalt_deltagande,
      andel_ej_anmalt_deltagande,
      blanka_roster,
      andel_blanka,
      ovriga_ogiltiga,
      andel_ovriga_ogiltiga,

      # Föregående val
      antal_roster_fg,
      andel_roster_fg,
      totalt_antal_roster_fg,
      antal_rostberattigade_fg,
      valdel_fg,
      giltiga_roster_fg,
      ogiltiga_roster_fg,
      andel_ogiltiga_fg,
      roster_ej_anmalt_deltagande_fg,
      andel_ej_anmalt_deltagande_fg,
      blanka_roster_fg,
      andel_blanka_fg,
      ovriga_ogiltiga_fg,
      andel_ovriga_ogiltiga_fg,

      # Differenser
      diff_antal_roster,
      diff_andel_roster,
      diff_totalt_antal_roster,
      diff_antal_rostberattigade,
      diff_valdel,
      diff_giltiga_roster,
      diff_ogiltiga_roster,
      diff_andel_ogiltiga,
      diff_roster_ej_anmalt_deltagande,
      diff_andel_ej_anmalt_deltagande,
      diff_blanka_roster,
      diff_andel_blanka,
      diff_ovriga_ogiltiga,
      diff_andel_ovriga_ogiltiga,

      status_jamforelse
    )
}
