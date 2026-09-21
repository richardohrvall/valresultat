test_that("public functions reject invalid arguments before reading files", {
  local_mocked_bindings(
    .read_resultatindex_2026 = function(...) stop("Unexpected file access"),
    val_file = function(...) stop("Unexpected file access")
  )
  for (fun in list(kandidaturer, kandidater, personroster, valda, mandat, ersattare)) {
    expect_error(fun(ar = 2022), "2026")
    expect_error(fun(val = "EU"), "valtyp")
    expect_error(fun(source = "invalid"), "arg")
  }
  expect_error(mandat(rakning = "invalid"), "rakning")
  expect_error(mandat(niva = "invalid"), "geografisk")
  expect_null(.valtyper(NULL))
  expect_identical(.valtyper(c("rd", "KF", "rd")), c("RD", "KF"))
})

test_that("missing candidate columns and duplicate elections are rejected", {
  expect_error(make_kandidater_2026(tibble::tibble()), "kolumner saknas")
  expect_error(parse_kandidaturer_2026(tibble::tibble()), "kolumner saknas")
  expect_error(make_kandidater_2026(dplyr::mutate(fixture_kandidaturer(), giltig = FALSE)),
               "inga giltiga")
  expect_error(add_valda_to_kandidater_2026(
    fixture_kandidatnycklar(), dplyr::bind_rows(fixture_valda(), fixture_valda())
  ), "vald mer")
})

test_that("valda is a filtered candidate view", {
  local_mocked_bindings(kandidater = function(...) {
    expect_true(list(...)$resultat)
    tibble::tibble(kandidatnummer = c("1", "2", "3"), invald = c(TRUE, FALSE, NA))
  })
  expect_identical(valda()$kandidatnummer, "1")
})
