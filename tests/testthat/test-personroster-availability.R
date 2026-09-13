personrost_fixture <- function() {
  list(partikod = "A", antalRoster = 10L,
       summeradePersonroster = list(list(kandidatnummer = "1", antalPersonroster = 3L)),
       listRoster = list(list(listnummer = "1", antalRosterMedPersonrost = 3L,
         personroster = list(list(kandidatNummer = "1", antalPersonroster = 3L)))))
}
personrost_raw <- function() {
  list(valtyp = "RD", rakningstillfalle = "slutlig",
       antalValdistriktRaknade = 2L, antalValdistriktSomSkaRaknas = 2L,
       valdistrikt = lapply(c("01", "02"), function(k) list(
         valdistriktskod = k, kommunkod = "0180", valomradeskod = "00", valdistriktstyp = "valdistrikt",
         rostfordelning = list(rosterPaverkaMandat = list(partiRoster = list(personrost_fixture()))))))
}
test_that("raw absent, null and empty arrays have different information states", {
  p <- personrost_fixture()
  expect_true(.personrost_partistatus(p))
  p$summeradePersonroster[[1]]$kandidatnummer <- 1L
  p$listRoster[[1]]$personroster[[1]]$kandidatNummer <- 1L
  expect_true(.personrost_partistatus(p))
  expect_identical(.personrost_partistatus(NULL), NA)
  p$summeradePersonroster <- NULL
  expect_identical(.personrost_partistatus(p), NA)
  p$listRoster <- NULL
  expect_false(.personrost_partistatus(p))
  p["summeradePersonroster"] <- list(NULL)
  expect_false(.personrost_partistatus(p))
  p$listRoster <- list()
  expect_false(.personrost_partistatus(p))
  p$summeradePersonroster <- list()
  expect_identical(.personrost_partistatus(p), NA)
  p$antalRoster <- 0L
  expect_true(.personrost_partistatus(p))
  p$antalRoster <- NULL
  expect_identical(.personrost_partistatus(p), NA)
  p <- personrost_fixture()
  p$summeradePersonroster <- list()
  p$listRoster[[1]]$personroster <- list()
  p$listRoster[[1]]$antalRosterMedPersonrost <- 0L
  expect_true(.personrost_partistatus(p))
  p$listRoster[[1]]$personroster <- NULL
  expect_identical(.personrost_partistatus(p), NA)
})
test_that("invalid types, duplicate identities and contradictory totals remain unknown", {
  for (x in list(NA_integer_, -1L, 1.5, "3", Inf, NULL, c(1L, 2L))) {
    p <- personrost_fixture()
    p$summeradePersonroster[[1]]["antalPersonroster"] <- list(x)
    expect_identical(.personrost_partistatus(p), NA)
  }
  for (change in list(
    function(p) {p$listRoster <- c(p$listRoster, p$listRoster); p},
    function(p) {p$summeradePersonroster <- c(p$summeradePersonroster, p$summeradePersonroster); p},
    function(p) {p$listRoster[[1]]$personroster <- rep(p$listRoster[[1]]$personroster, 2); p},
    function(p) {p$listRoster[[1]]$antalRosterMedPersonrost <- 4L; p},
    function(p) {p$summeradePersonroster[[1]]$antalPersonroster <- 4L; p},
    function(p) {p$listRoster <- "bad"; p},
    function(p) {p$summeradePersonroster <- list(kandidatnummer = "1"); p},
    function(p) {p$listRoster[[1]]$listnummer <- NULL; p}
  )) expect_identical(.personrost_partistatus(change(personrost_fixture())), NA)
  p <- personrost_fixture()
  p$summeradePersonroster[[2]] <- list(kandidatnummer = "2", antalPersonroster = 0L)
  expect_true(.personrost_partistatus(p))
  p$listRoster[[2]] <- p$listRoster[[1]]
  p$listRoster[[2]]$listnummer <- "2"
  p$summeradePersonroster[[1]]$antalPersonroster <- 6L
  expect_true(.personrost_partistatus(p))
})
test_that("area completeness requires every district and party and completed counting", {
  raw <- personrost_raw()
  expect_true(.personrostunderlag_2026(raw, "00")$status$personroster_available)
  for (change in list(
    function(r) {r$antalValdistriktRaknade <- 1L; r},
    function(r) {r$antalValdistriktSomSkaRaknas <- 3L; r},
    function(r) {r$valdistrikt[[2]] <- r$valdistrikt[[1]]; r},
    function(r) {r$valdistrikt[[2]]$valomradeskod <- "01"; r},
    function(r) {r$valdistrikt[[2]]$rostfordelning$rosterPaverkaMandat$partiRoster <- list(); r},
    function(r) {r$rakningstillfalle <- "preliminär"; r},
    function(r) {r$antalValdistriktRaknade <- NULL; r},
    function(r) {r$valdistrikt[[2]]$rostfordelning$rosterPaverkaMandat$partiRoster[[1]]$summeradePersonroster <- NULL; r}
  )) {
    out <- .personrostunderlag_2026(change(raw), "00")
    expect_identical(out$status$personroster_available, NA)
    expect_equal(nrow(out$roster), 0L)
  }
  for (i in 1:2) {
    raw$valdistrikt[[i]]$rostfordelning$rosterPaverkaMandat$partiRoster <- list(list(partikod = "A"))
  }
  raw$antalValdistriktRaknade <- 0L
  expect_false(.personrostunderlag_2026(raw, "00")$status$personroster_available)
  raw$rakningstillfalle <- "preliminär"
  expect_false(.personrostunderlag_2026(raw, "00")$status$personroster_available)
  expect_identical(.personrost_status(logical()), NA)
  expect_identical(.personrost_status(c(TRUE, FALSE)), NA)
})
test_that("candidate totals require all valid areas, and missing candidate rows become zero only then", {
  u <- .personrostunderlag_2026(personrost_raw(), "00")
  cand <- tibble::tibble(kandidatnummer = c("1", "2"), valtyp = "RD", partikod = "A", valomradeskod = "00", giltig = TRUE)
  out <- .personrosttotaler_2026(cand, u$status, u$roster)
  expect_identical(out$antal_personroster_totalt, c(6L, 0L))
  for (s in c(FALSE, NA)) {
    state <- u$status
    state$personroster_available <- s
    expect_identical(.personrosttotaler_2026(cand, state, u$roster)$antal_personroster_totalt, c(NA_integer_, NA_integer_))
  }
  cand2 <- dplyr::bind_rows(cand, dplyr::mutate(cand, valomradeskod = "01"))
  expect_true(all(is.na(.personrosttotaler_2026(cand2, u$status, u$roster)$antal_personroster_totalt)))
  both <- dplyr::bind_rows(u$status, dplyr::mutate(u$status, valomradeskod = "01"))
  votes <- dplyr::bind_rows(u$roster, dplyr::mutate(u$roster, valomradeskod = "01"))
  expect_identical(.personrosttotaler_2026(cand2, both, votes)$antal_personroster_totalt, c(12L, 0L))
  cand2$giltig[cand2$valomradeskod == "01"] <- FALSE
  expect_identical(.personrosttotaler_2026(cand2, u$status, votes)$antal_personroster_totalt, c(6L, 0L))
  expect_equal(nrow(.personrosttotaler_2026(cand[0, ], u$status, u$roster)), 0L)
  votes$antal_personroster[1] <- NA_integer_
  expect_identical(.personrosttotaler_2026(cand, u$status, votes)$antal_personroster_totalt, c(NA_integer_, 0L))
})

test_that("JSON empty arrays and objects are assessed before flattening", {
  parse <- function(x) jsonlite::fromJSON(x, simplifyVector = FALSE)
  expect_true(.personrost_partistatus(parse('{"antalRoster":0,"summeradePersonroster":[],"listRoster":[]}')))
  expect_false(.personrost_partistatus(parse('{"summeradePersonroster":null,"listRoster":[]}')))
  expect_identical(.personrost_partistatus(parse('{"summeradePersonroster":{},"listRoster":[]}')), NA)
})

test_that("legacy internal helper cannot invent zero from unverified or contradictory rows", {
  votes <- fixture_personroster()
  expect_true(all(is.na(add_personroster_to_kandidater_2026(
    fixture_kandidatnycklar(), votes, fixture_personval())$antal_personroster_totalt)))
  attr(votes, "personroster_available") <- dplyr::mutate(fixture_kandidatnycklar(), personroster_available = TRUE)
  expect_identical(add_personroster_to_kandidater_2026(fixture_kandidatnycklar(), votes,
    fixture_personval())$antal_personroster_totalt, c(7L, 0L))
  votes$antal_personroster[1] <- NA_integer_
  expect_identical(add_personroster_to_kandidater_2026(fixture_kandidatnycklar(), votes,
    fixture_personval())$antal_personroster_totalt, c(NA_integer_, 0L))
})

test_that("RF and KF without personal vote structures return NA, regardless of ordinary votes", {
  for (val in c("RF", "KF")) {
    raw <- personrost_raw()
    raw$valtyp <- val
    for (i in seq_along(raw$valdistrikt)) {
      raw$valdistrikt[[i]]$rostfordelning$rosterPaverkaMandat$partiRoster <- list(
        list(partikod = "A", antalRoster = 100L, listRoster = list(list(listnummer = "1"))))
    }
    u <- .personrostunderlag_2026(raw, "00")
    expect_false(u$status$personroster_available)
    cand <- tibble::tibble(kandidatnummer = "1", valtyp = val, partikod = "A", valomradeskod = "00", giltig = TRUE)
    expect_identical(.personrosttotaler_2026(cand, u$status, u$roster)$antal_personroster_totalt, NA_integer_)
    raw$valdistrikt[[1]]$rostfordelning$rosterPaverkaMandat$partiRoster <- list(personrost_fixture())
    mixed <- .personrostunderlag_2026(raw, "00")
    expect_identical(mixed$status$personroster_available, NA)
    expect_equal(nrow(mixed$roster), 0L)
  }
})
