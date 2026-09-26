test_that("constituency count uses distinct valid geography, not lists", {
  kandidaturer <- fixture_kandidaturer()
  extra_lista <- dplyr::filter(kandidaturer, kandidatnummer == "1",
                                valtyp == "RD", partikod == "A",
                                valkretskod == "01")
  extra_lista$listnummer <- "extra"
  out <- make_kandidater_2026(dplyr::bind_rows(kandidaturer, extra_lista))
  en <- dplyr::filter(out, kandidatnummer == "2", valtyp == "RD")
  tva <- dplyr::filter(out, kandidatnummer == "1", valtyp == "RD",
                       partikod == "A")
  expect_identical(en$antal_valkretsar, 1L)
  expect_identical(tva$antal_valkretsar, 2L)
  expect_identical(tva$antal_listor, 3L)
  expect_true(is.na(tva$valkretskod) && is.na(tva$valkretsnamn))
  expect_identical(names(out)[match("valkretskod", names(out)) + 0:2],
                   c("valkretskod", "valkretsnamn", "antal_valkretsar"))
  expect_type(out$antal_valkretsar, "integer")
})

test_that("a nationwide ballot counts its 29 actual RD constituencies", {
  nationwide <- fixture_kandidaturer()[rep(1L, 29L), ]
  nationwide$kandidatnummer <- "helandet"
  nationwide$namn <- "Hela Landet"
  nationwide$valkretskod <- sprintf("%02d", seq_len(29))
  nationwide$valkretsnamn <- paste("Krets", seq_len(29))
  nationwide$listnummer <- "10001"
  nationwide$valkretsbeteckning_pa_valsedeln <- "HELA LANDET"
  out <- make_kandidater_2026(nationwide)
  expect_identical(out$antal_valkretsar, 29L)
  expect_identical(out$antal_listor, 1L)
  expect_true(is.na(out$valkretskod) && is.na(out$valkretsnamn))
})

test_that("an undivided KF technical code is counted once without invention", {
  gotland <- fixture_kandidaturer()[4, ]
  gotland$valomradeskod <- "0980"
  gotland$valomradesnamn <- "Gotland"
  gotland$valkretskod <- "098000"
  gotland$valkretsnamn <- "Gotland"
  out <- make_kandidater_2026(gotland)
  expect_identical(out$antal_valkretsar, 1L)
  expect_identical(out$valomradeskod, "0980")
  expect_identical(out$valkretskod, "098000")
  expect_identical(out$valkretsnamn, "Gotland")
})

test_that("constituency identity includes the election area", {
  first <- fixture_kandidaturer()[4, ]
  second <- first
  second$valomradeskod <- "0184"
  second$valomradesnamn <- "Solna"
  first$valkretskod <- second$valkretskod <- "00"
  first$valkretsnamn <- second$valkretsnamn <- "Teknisk krets"
  out <- make_kandidater_2026(dplyr::bind_rows(first, second))
  expect_identical(out$antal_valkretsar, 2L)
  expect_true(is.na(out$valkretskod) && is.na(out$valkretsnamn))
})

test_that("unknown candidacy constituency gives unknown count, not zero", {
  unknown <- fixture_kandidaturer()[4, ]
  unknown$valkretskod <- NA_character_
  unknown$valkretsnamn <- NA_character_
  out <- make_kandidater_2026(unknown)
  expect_identical(out$antal_valkretsar, NA_integer_)
  expect_identical(out$flera_valkretsar, NA)
})
