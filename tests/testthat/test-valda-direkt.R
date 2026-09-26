test_that("direct elected path preserves candidate values and uses elected constituency", {
  kd <- dplyr::filter(fixture_kandidaturer(), valtyp == "RD") |>
    dplyr::mutate(oppen_lista = FALSE, pa_namnvalsedel = TRUE)
  kd$folkbokforingskommun[kd$kandidatnummer == "2"] <- NA_character_
  elected <- dplyr::bind_rows(
    dplyr::mutate(fixture_valda(), valkretskod = "02",
                  valkretsnamn = "Krets 2"),
    dplyr::mutate(fixture_valda(), kandidatnummer = "2",
                  invalsordning = 2L)
  )
  summerade <- tibble::tibble(
    kandidatnummer = c("1", "1", "2"), partikod = "A",
    personvalsomradeskod = c("01", "02", "01"),
    antal_personroster_omrade = c(3L, 4L, 5L)
  )
  omraden <- tibble::tibble(
    personvalsomradeskod = c("01", "02"),
    .personval_nod = list(NULL, NULL)
  )
  local_mocked_bindings(
    kandidaturer = function(...) kd,
    .read_resultatindex_2026 = function(...) tibble::tibble(
      path = "s/rd/Val_2026_slutlig_00_RD.zip"),
    .resultat_file_2026 = function(...) "mandat.zip",
    read_raw_json_zip_2026 = function(file, type) {
      expect_identical(type, "mandatfordelning")
      list(valtyp = "RD", valomrade = list(kod = "00"))
    },
    .personvalsomraden_mandat_2026 = function(...) omraden,
    .valda_mandat_komplett_2026 = function(...) TRUE,
    parse_valda_ersattare_2026 = function(...) list(valda = elected),
    .personval_partiroster_2026 = function(...) tibble::tibble(
      personvalsomradeskod = c("01", "02"), partikod = "A",
      antal_partiroster = c(10L, 10L)),
    .personroster_summerade_omrade_2026 = function(...) summerade,
    parse_personval_2026 = function(...) fixture_personval()
  )
  direct <- .valda_direkt_2026("local", NULL, FALSE, FALSE)
  base <- .kandidater_bas(kd, 2026L)
  full <- .add_kandidatresultat_fran_parsade_2026(base, kd, "RD", list(list(
    status = tibble::tibble(valtyp = "RD", valomradeskod = "00",
                            valda_available = TRUE, personval_available = TRUE),
    personrostomraden = dplyr::transmute(
      summerade, kandidatnummer, valtyp = "RD", partikod,
      antal_personroster = antal_personroster_omrade),
    personval = fixture_personval(), valda = elected
  ))) |> dplyr::filter(invald %in% TRUE)
  expect_identical(direct, full)
  expect_identical(direct$antal_personroster_totalt, c(7L, 5L))
  expect_identical(direct$kvalificerad_personval, c(TRUE, FALSE))
  expect_true(is.na(direct$folkbokforingskommun[[2]]))
  expect_true(is.na(direct$valkretskod[[1]]))
  corrected <- .valda_invaldsvalkrets_2026(direct)
  expect_identical(corrected$valkretskod, c("02", "01"))
  expect_identical(corrected$valkretsnamn, c("Krets 2", "Krets 1"))
  expect_identical(names(corrected), names(full))
  expect_identical(vapply(corrected, typeof, ""), vapply(full, typeof, ""))
})

test_that("direct path requires complete final mandate person votes", {
  listnode <- list(
    listnummer = "A-1", antalRoster = 10L,
    antalRosterMedPersonrost = 2L,
    personroster = list(list(kandidatNummer = "1", antalPersonroster = 2L))
  )
  partinode <- list(
    partikod = "A", antalRoster = 10L, listRoster = list(listnode),
    summeradePersonroster = list(list(kandidatnummer = "1",
                                    antalPersonroster = 2L))
  )
  node <- list(
    antalValdistriktRaknade = 1L, antalValdistriktSomSkaRaknas = 1L,
    rostfordelning = list(rosterPaverkaMandat = list(
      antalRoster = 10L, rosterOvrigaPartier = list(antalRoster = 0L),
      partiRoster = list(partinode)))
  )
  raw <- list(
    rakningstillfalle = "slutlig",
    valomrade = list(antalValdistriktRaknade = 1L,
                     antalValdistriktSomSkaRaknas = 1L)
  )
  area <- tibble::tibble(personval_available = TRUE,
                         .personval_nod = list(node))
  local_mocked_bindings(.valda_available_2026 = function(...) TRUE)
  expect_true(.valda_mandat_komplett_2026(raw, area))
  partial <- area
  partial$.personval_nod[[1]]$rostfordelning$rosterPaverkaMandat$
    partiRoster[[1]]$listRoster[[1]]$personroster <- NULL
  expect_false(.valda_mandat_komplett_2026(raw, partial))
  unknown <- area
  unknown$.personval_nod[[1]]$rostfordelning$rosterPaverkaMandat$
    partiRoster[[1]]$summeradePersonroster <- NULL
  expect_false(.valda_mandat_komplett_2026(raw, unknown))
  zero <- unknown
  zero$.personval_nod[[1]]$rostfordelning$rosterPaverkaMandat$
    partiRoster[[1]]$listRoster[[1]]$antalRosterMedPersonrost <- 0L
  zero$.personval_nod[[1]]$rostfordelning$rosterPaverkaMandat$
    partiRoster[[1]]$listRoster[[1]]$personroster <- list()
  expect_true(.valda_mandat_komplett_2026(raw, zero))
  raw$valomrade$antalValdistriktRaknade <- 0L
  expect_false(.valda_mandat_komplett_2026(raw, area))
})

test_that("valda falls back when the direct source is incomplete", {
  candidate <- tibble::tibble(kandidatnummer = c("1", "2"),
                              invald = c(TRUE, FALSE),
                              antal_valkretsar = c(29L, 1L))
  local_mocked_bindings(
    .valda_direkt_2026 = function(...) NULL,
    kandidater = function(...) candidate
  )
  expect_identical(valda(ar = 2026, val = "RD", progress = FALSE),
                   dplyr::filter(candidate, invald %in% TRUE) |>
                     dplyr::select(-antal_valkretsar))
})

test_that("valda uses the direct result without building all candidates", {
  elected <- tibble::tibble(
    kandidatnummer = "1", valtyp = "RD", invald = TRUE,
    antal_valkretsar = 29L,
    valkretskod = NA_character_, valkretsnamn = NA_character_,
    invald_valkretskod = "02", invald_valkretsnamn = "Krets 2"
  )
  local_mocked_bindings(
    .valda_direkt_2026 = function(...) elected,
    kandidater = function(...) stop("Full candidate path was used")
  )
  out <- valda(ar = 2026, val = "RD", progress = FALSE)
  expect_identical(out$valkretskod, "02")
  expect_identical(out$valkretsnamn, "Krets 2")
  expect_false("antal_valkretsar" %in% names(out))
})
