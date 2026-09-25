test_that("printed-ballot negatives follow CSV content, not year or path", {
  raw <- fixture_kandidaturer_raw()
  csv <- tempfile(fileext = ".csv")
  same_content <- tempfile(fileext = ".csv")
  on.exit(unlink(c(csv, same_content)), add = TRUE)
  readr::write_delim(raw, csv, delim = ";")
  file.copy(csv, same_content)
  verified_hash <- unname(tools::md5sum(csv))

  local_mocked_bindings(
    .verifierade_kandidatur_csv_md5 = function(ar) {
      if (ar == 2022L) verified_hash else character()
    }
  )
  expect_true(.namnvalsedlar_kompletta(csv, 2022L))
  expect_true(.namnvalsedlar_kompletta(same_content, 2022L))
  expect_false(.namnvalsedlar_kompletta(csv, 2026L))

  verified <- parse_kandidaturer_2026(
    raw, ar = 2022L,
    namnvalsedlar_kompletta = .namnvalsedlar_kompletta(csv, 2022L)
  )
  unknown <- parse_kandidaturer_2026(
    raw, ar = 2022L,
    namnvalsedlar_kompletta = .namnvalsedlar_kompletta(csv, 2026L)
  )
  expect_identical(verified$pa_namnvalsedel, c(TRUE, TRUE, FALSE, FALSE))
  expect_identical(unknown$pa_namnvalsedel, c(TRUE, TRUE, NA, NA))

  write("changed content", csv)
  expect_false(.namnvalsedlar_kompletta(csv, 2022L))
  expect_true(.namnvalsedlar_kompletta(same_content, 2022L))
})

test_that("only verified historical and current candidate CSV hashes give FALSE", {
  expect_identical(.verifierade_kandidatur_csv_md5(2022L),
                   "639daa9630a1f2554f1c6839473448ee")
  expect_identical(.verifierade_kandidatur_csv_md5(2026L),
                   "c30f47a4ea28da2d926e0e186477a98b")
  expect_false("a91645a8e6e6d35d897b645c2e360923" %in%
                 .verifierade_kandidatur_csv_md5(2022L))
  expect_false("4073efa71b60a13b46e4d1fd39794114" %in%
                 .verifierade_kandidatur_csv_md5(2022L))
})

test_that("registration municipality is data, never a candidacy key", {
  raw <- fixture_kandidaturer_raw()
  a <- parse_kandidaturer_2026(raw, ar = 2022L)
  raw$folkbokforingskommun <- " "
  b <- parse_kandidaturer_2026(raw, ar = 2022L)
  key <- c("valtyp", "valomradeskod", "valkretskod", "partikod",
           "listnummer", "ordning", "kandidatnummer")
  expect_identical(a[key], b[key])
  expect_identical(a$pa_namnvalsedel, b$pa_namnvalsedel)
  expect_true(all(is.na(b$folkbokforingskommun)))
})
