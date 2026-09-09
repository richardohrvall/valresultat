test_that("personval parser distinguishes absent and available empty lists", {
  absent <- list(valtyp = "RD", valomrade = list(kod = "00"))
  present <- absent
  present$valomrade$kvalificeradeForPersonvalLista <- list()
  unknown <- parse_personval_2026(absent)
  known <- parse_personval_2026(present)
  expect_false(attr(unknown, "personval_available"))
  expect_true(attr(known, "personval_available"))
  expect_equal(nrow(unknown), 0L)
  expect_identical(names(unknown), names(known))
  expect_type(unknown$kandidatnummer, "character")
  expect_type(unknown$antal_personroster, "integer")
  expect_type(unknown$andel_personroster, "double")
  expect_false(.valda_available_2026(absent))
  present$valomrade$valda <- list()
  expect_true(.valda_available_2026(present))
})

test_that("empty person vote tables retain typed schemas", {
  out <- parse_personroster_2026(list(valtyp = "RD", valdistrikt = list()))
  expect_named(out, c("listroster", "personroster", "personroster_summerade"))
  for (tab in out) {
    expect_equal(nrow(tab), 0L)
    expect_type(tab$partikod, "character")
    expect_false(any(vapply(tab, is.list, logical(1))))
    expect_true(all(c("kommunvalkretskod", "kommunvalkretsnamn") %in% names(tab)))
  }
  expect_type(out$listroster$antal_roster_lista, "integer")
  expect_type(out$personroster$antal_personroster, "integer")
  expect_type(out$personroster_summerade$kandidatnummer, "character")
})

test_that("personal votes reconcile across lists and district summaries", {
  raw <- list(valtyp = "RD", valdistrikt = list(list(
    valdistriktskod = "010101", rostfordelning = list(rosterPaverkaMandat = list(
      partiRoster = list(list(
        partikod = "A",
        listRoster = list(
          list(listnummer = "1", antalRoster = 10L, antalRosterMedPersonrost = 3L,
               personroster = list(list(kandidatNummer = "1", antalPersonroster = 3L))),
          list(listnummer = "2", antalRoster = 20L, antalRosterMedPersonrost = 4L,
               personroster = list(list(kandidatNummer = "1", antalPersonroster = 4L)))
        ),
        summeradePersonroster = list(list(kandidatnummer = "1", antalPersonroster = 7L))
      ))
    ))
  )))
  out <- parse_personroster_2026(raw)
  by_list <- dplyr::summarise(out$personroster, antal = sum(antal_personroster), .by = listnummer)
  expect_identical(by_list$antal, out$listroster$antal_roster_med_personrost)
  expect_identical(sum(out$personroster$antal_personroster),
                   out$personroster_summerade$antal_personroster)
  expect_identical(out$personroster_summerade$kandidatnummer, "1")
  expect_identical(out$personroster_summerade$valdistriktskod, "010101")
  expect_equal(nrow(dplyr::distinct(out$personroster, kandidatnummer, listnummer, valdistriktskod)), 2L)
})

test_that("municipal constituency names are consistent across result parsers", {
  district <- list(kommunvalkretsKod = "01", kommunvalkretsNamn = "Krets ett")
  votes <- parse_rostfordelning_2026(list(valtyp = "RD", valdistrikt = list(district)))
  expect_true(all(c("kommunvalkretskod", "kommunvalkretsnamn") %in% names(votes)))
  expect_true(all(votes$kommunvalkretskod == "01"))
  expect_true(all(votes$kommunvalkretsnamn == "Krets ett"))

  summaries <- parse_underordnad_summering_2026(list(valtyp = "RD", kommuner = list(list(
    kommunkod = "0180", kommunvalkretsar = list(list(kod = "01", namn = "Krets ett"))
  ))))
  constituency <- dplyr::filter(summaries, geografiniva == "kommunvalkrets")
  expect_identical(constituency$kommunvalkretskod, "01")
  expect_identical(constituency$kommunvalkretsnamn, "Krets ett")

  national <- parse_overordnad_summering_rf_2026(list(valtyp = "RF", helaLandet = list()))
  expect_identical(national$kommunvalkretskod, NA_character_)
  expect_identical(national$kommunvalkretsnamn, NA_character_)
  expect_identical(national$partibeteckning, "Övriga partier")
})
