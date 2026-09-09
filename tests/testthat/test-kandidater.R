test_that("candidate table preserves its key and excludes invalid candidacies", {
  out <- make_kandidater_2026(fixture_kandidaturer())
  expect_equal(nrow(out), 4L)
  expect_equal(nrow(dplyr::distinct(out, kandidatnummer, valtyp, partikod)), nrow(out))
  expect_false("3" %in% out$kandidatnummer)
  expect_false(any(vapply(out, is.list, logical(1))))
  expect_type(out$kandidatnummer, "character")
  expect_type(out$alder_pa_valdagen, "integer")
  expect_type(out$namn_varierar, "logical")
  anna <- dplyr::filter(out, kandidatnummer == "1", valtyp == "RD", partikod == "A")
  expect_identical(anna$namn, "Anna Andersson")
  expect_true(anna$namn_varierar)
  expect_identical(anna$antal_valkretsar, 2L)
  expect_identical(anna$antal_listor, 2L)
  expect_identical(anna$valkretskod, NA_character_)
  expect_true(anna$flera_partier)
  expect_true(anna$flera_valtyper)
  reversed <- make_kandidater_2026(fixture_kandidaturer()[6:1, ])
  expect_equal(dplyr::arrange(out, kandidatnummer, valtyp, partikod),
               dplyr::arrange(reversed, kandidatnummer, valtyp, partikod))
})

test_that("name normalisation preserves spelling and aliases", {
  expect_identical(.normalisera_kandidatnamn(c("  Berg, Bo  ", "Alias", "A, B, C", NA)),
                   c("Bo Berg", "Alias", "A, B, C", NA_character_))
})

test_that("personal election and elected status distinguish NA from FALSE", {
  candidates <- fixture_kandidatnycklar()
  unknown <- add_personroster_to_kandidater_2026(
    candidates, fixture_personroster(), fixture_personval(FALSE)
  )
  expect_identical(unknown$kvalificerad_personval, c(NA, NA))
  expect_identical(unknown$antal_personvalsomraden, c(NA_integer_, NA_integer_))
  known <- add_personroster_to_kandidater_2026(
    candidates, fixture_personroster(), fixture_personval()
  )
  expect_identical(known$antal_personroster_totalt, c(7L, 0L))
  expect_identical(known$kvalificerad_personval, c(TRUE, FALSE))
  expect_identical(known$antal_personvalsomraden, c(1L, 0L))
  expect_identical(add_valda_to_kandidater_2026(candidates, fixture_valda()[0, ])$invald,
                   c(NA, NA))
  expect_identical(add_valda_to_kandidater_2026(candidates, fixture_valda())$invald,
                   c(TRUE, FALSE))
})

test_that("candidate result pipeline respects availability without network access", {
  for (available in c(FALSE, TRUE)) {
    local_mocked_bindings(
      .read_resultatindex_2026 = function(...) tibble::tibble(path = "s/rd/val_00_RD.zip"),
      .parse_kandidatresultat_fil_2026 = function(...) list(
        status = tibble::tibble(valtyp = "RD", valomradeskod = "00",
                               valda_available = available, personval_available = available),
        personroster = fixture_personroster(),
        personval = fixture_personval(available),
        valda = if (available) fixture_valda() else fixture_valda()[0, ]
      )
    )
    out <- .add_kandidatresultat_2026(
      fixture_kandidatnycklar(), fixture_kandidaturer(), "RD", progress = FALSE
    )
    expected <- if (available) c(TRUE, FALSE) else c(NA, NA)
    expect_identical(out$invald, expected)
    expect_identical(out$kvalificerad_personval, expected)
    expect_identical(out$antal_personroster_totalt, c(7L, 0L))
    expect_equal(nrow(out), 2L)
    expect_false(any(vapply(out, is.list, logical(1))))
  }
})
