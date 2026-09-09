test_that("scalar helpers preserve missingness and types", {
  helpers <- list(as_chr_na, as_int_na, as_dbl_na, as_lgl_na)
  missing <- list(NA_character_, NA_integer_, NA_real_, NA)
  for (i in seq_along(helpers)) {
    for (input in list(NULL, list(), character(), NA)) {
      expect_identical(helpers[[i]](input), missing[[i]])
    }
  }
  expect_identical(as_chr_na(list(12L, 13L)), "12")
  expect_identical(as_int_na("12"), 12L)
  expect_identical(as_dbl_na("1.5"), 1.5)
  expect_identical(as_lgl_na(FALSE), FALSE)
  expect_identical(as_int_na(0L), 0L)
})

test_that("index parsing ignores malformed lines and preserves paths", {
  md5 <- paste(rep("A", 32), collapse = "")
  out <- parse_index_2026(c(
    paste(md5, "./s/rd/val_00_RD.zip"), "invalid", "", "abc ./bad.zip"
  ))
  expect_named(out, c("md5", "path"))
  expect_identical(out$md5, tolower(md5))
  expect_identical(out$path, "s/rd/val_00_RD.zip")
  expect_identical(vapply(out, typeof, character(1)), c(md5 = "character", path = "character"))
})

test_that("result file selection excludes summaries and preliminary files", {
  paths <- c("s/rd/val_00_RD.zip", "s/rf/val_01_RF.zip", "s/kf/val_0180_KF.zip",
             "p/rd/val_00_RD.zip", "s/kf/val_01_KF.zip", "s/rf/val_00_RF_summering.zip",
             "s/rd/val_00_RD.zip.bak")
  out <- .resultat_paths_2026(tibble::tibble(path = paths), c("RD", "RF", "KF"))
  expect_identical(out$path, paths[1:3])
  expect_identical(out$valtyp, c("RD", "RF", "KF"))
})
