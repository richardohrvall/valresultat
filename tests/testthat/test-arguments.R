test_that("public functions reject invalid arguments before reading files", {
  local_mocked_bindings(
    .read_resultatindex_2026 = function(...) stop("Unexpected file access"),
    val_file = function(...) stop("Unexpected file access")
  )
  for (fun in list(kandidaturer, kandidater, valda, mandat, ersattare)) {
    expect_error(fun(ar = 2022), "2026")
    expect_error(fun(val = "EU"), "Okänd valtyp")
    expect_error(fun(source = "invalid"), "arg")
  }
  expect_error(mandat(rakning = "invalid"), "arg")
  expect_error(mandat(niva = "invalid"), "Okänd geografisk nivå")
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
  ), "vald mer än en gång")
})

test_that("valda is a filtered candidate view", {
  local_mocked_bindings(kandidater = function(...) {
    expect_true(list(...)$resultat)
    tibble::tibble(kandidatnummer = c("1", "2", "3"), invald = c(TRUE, FALSE, NA))
  })
  expect_identical(valda()$kandidatnummer, "1")
})
