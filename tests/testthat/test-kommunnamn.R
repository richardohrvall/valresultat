test_that("the internal municipality lookup is complete and canonical", {
  expect_identical(names(kommunnamn_2026), c("kommunkod", "kommunnamn"))
  expect_equal(nrow(kommunnamn_2026), 290L)
  expect_equal(dplyr::n_distinct(kommunnamn_2026$kommunkod), 290L)
  expect_false(anyNA(kommunnamn_2026))
  expect_true(all(grepl("^[0-9]{4}$", kommunnamn_2026$kommunkod)))
  kontroll <- c(
    "0180" = "Stockholm", "0184" = "Solna",
    "0980" = "Gotland", "2061" = "Smedjebacken"
  )
  expect_identical(
    setNames(kommunnamn_2026$kommunnamn, kommunnamn_2026$kommunkod)[names(kontroll)],
    kontroll
  )
})

test_that("municipality completion preserves rows, keys, codes and official names", {
  x <- tibble::tibble(
    id = c("a", "b", "c", "d", "e"),
    kommunkod = c("0180", "0184", "0980", "2061", "9999")
  )
  official <- c(
    "Stockholms kommun", "Solna stad", "Region Gotland",
    "Smedjebackens kommun", "Okänd kommun"
  )
  out <- .komplettera_kommunnamn_2026(x, official)
  expect_equal(nrow(out), nrow(x))
  expect_identical(out$id, x$id)
  expect_identical(out$kommunkod, x$kommunkod)
  expect_identical(
    out$kommunnamn,
    c("Stockholm", "Solna", "Gotland", "Smedjebacken", NA_character_)
  )
  expect_identical(out$kommunnamn_officiellt, official)
  expect_false(anyDuplicated(out$id) > 0L)
})

test_that("public tables use short municipality names without duplicate geography", {
  resultat <- fixture_public_resultat("KF", "kommun")
  kandidater_data <- make_kandidater_2026(fixture_kandidaturer()) |>
    dplyr::filter(valtyp == "KF")
  mandat_data <- tibble::tibble(
    valtyp = "KF", valomradeskod = "0180", valomradesnamn = "Omrade"
  ) |>
    .kort_kommunnamn_2026()
  personroster_data <- tibble::tibble(
    valtyp = "KF", valomradeskod = "0180",
    valomradesnamn = "Stockholms kommun"
  ) |>
    .kort_kommunnamn_2026()

  valomradestabeller <- list(kandidater_data, mandat_data, personroster_data)
  expect_true(all(vapply(
    valomradestabeller,
    function(x) identical(unique(x$valomradeskod), "0180") &&
      identical(unique(x$valomradesnamn), "Stockholm"),
    logical(1)
  )))
  expect_true(all(vapply(
    valomradestabeller,
    function(x) !any(c("kommunkod", "kommunnamn", "kommunnamn_officiellt") %in% names(x)),
    logical(1)
  )))
  expect_identical(unique(resultat$kommunkod), "0180")
  expect_identical(unique(resultat$kommunnamn), "Stockholm")
  expect_identical(unique(resultat$kommunnamn_officiellt), "Omrade")
})

test_that("non-municipal valomrade names are unchanged", {
  out <- tibble::tibble(
    valtyp = c("RD", "RF"), valomradeskod = c("00", "01"),
    valomradesnamn = c("Riket", "Region Stockholm")
  ) |>
    .kort_kommunnamn_2026()
  expect_identical(out$valomradesnamn, c("Riket", "Region Stockholm"))
  expect_false(any(c("kommunkod", "kommunnamn", "kommunnamn_officiellt") %in% names(out)))
})

test_that("multiple KF candidacy areas stay distinct from the elected area", {
  kandidaturer <- dplyr::filter(
    fixture_kandidaturer(), valtyp == "KF", giltig %in% TRUE
  )
  kandidaturer <- dplyr::bind_rows(
    kandidaturer,
    dplyr::mutate(
      kandidaturer,
      valomradeskod = "0184", valomradesnamn = "Solna stad",
      listnummer = "extra"
    )
  )
  kandidat <- make_kandidater_2026(kandidaturer)
  key_fore <- kandidat[c("kandidatnummer", "valtyp", "partikod")]
  expect_equal(nrow(kandidat), 1L)
  expect_identical(kandidat$valomradeskod, NA_character_)
  expect_identical(kandidat$valomradesnamn, NA_character_)
  expect_identical(kandidat$antal_valomraden, 2L)
  expect_true(kandidat$flera_valomraden)

  valda_data <- tibble::tibble(
    kandidatnummer = kandidat$kandidatnummer,
    valtyp = "KF", partikod = kandidat$partikod,
    valomradeskod = "0184", valomradesnamn = "Solna stad",
    valkretskod = NA_character_, valkretsnamn = NA_character_,
    invalsordning = 1L, valgrund_id = "M", valgrund_text = "Mandat",
    ersattargrupp = "1"
  )
  med_inval <- add_valda_to_kandidater_2026(kandidat, valda_data)
  expect_identical(med_inval$valomradeskod, NA_character_)
  expect_identical(med_inval$valomradesnamn, NA_character_)
  expect_identical(med_inval$invald_valomradeskod, "0184")
  expect_identical(med_inval$invald_valomradesnamn, "Solna")
  expect_identical(
    med_inval[c("kandidatnummer", "valtyp", "partikod")], key_fore
  )
  expect_false(any(c("kommunkod", "kommunnamn", "kommunnamn_officiellt") %in% names(med_inval)))
})
