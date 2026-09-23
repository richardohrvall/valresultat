# Kör lokalt med VALRESULTAT_2022_INTEGRATION_DIR mot externa, oförändrade ZIP.
# Ordinarie testsuite behöver inga rådata och ingen nätåtkomst.
test_that("official 2022 D/M ZIPs retain keys, totals and public schemas", {
  root <- Sys.getenv("VALRESULTAT_2022_INTEGRATION_DIR", "")
  skip_if(!nzchar(root), "External 2022 ZIPs not configured")
  files <- c(
    "p/rd/Val_20220911_preliminar_00_RD.zip" = "078e4911d8706c9bdcd8f24c85de7200",
    "s/rd/Val_20220911_slutlig_00_RD.zip" = "a0f843ffb9a305e7bc84ecea5e57023a",
    "p/rf/Val_20220911_preliminar_01_RF.zip" = "94cb94e46dd295cbdf6ee85d834d8453",
    "s/rf/Val_20220911_slutlig_01_RF.zip" = "88178411c6c5f31514bed9416eb7beaf",
    "p/kf/Val_20220911_preliminar_0180_KF.zip" = "714ddd9bf194d0ee024c3c6213d9f317",
    "s/kf/Val_20220911_slutlig_0180_KF.zip" = "1534f4310d6a068260efedca6d26d001",
    "p/kf/Val_20220911_preliminar_0980_KF.zip" = "97a93c0f20fd8d08b4db2bfaed424b67",
    "s/kf/Val_20220911_slutlig_0980_KF.zip" = "d396bbcd319540acf134279e46b0775a"
  )
  index <- parse_index_2026(readLines(file.path(root, "index.md5"), warn = FALSE))
  for (path in names(files)) {
    file <- file.path(root, path)
    expect_true(file.exists(file), info = path)
    expect_identical(unname(tools::md5sum(file)), unname(files[[path]]), info = path)
    expect_identical(index$md5[match(path, index$path)], unname(files[[path]]), info = path)
    val <- sub(".*_([A-Z]{2})\\.zip$", "\\1", path)
    rakning <- if (startsWith(path, "p/")) "preliminar" else "slutlig"
    m_niva <- switch(val, RD = "riket", RF = "region", KF = "kommun")
    d_raw <- .read_valresultat_raw(file, "D", val, rakning,
                                   distrikt_context = TRUE, ar = 2022)
    m_raw <- .read_valresultat_raw(file, "M", val, rakning, ar = 2022)
    d_internal <- .parse_valresultat(d_raw, "D", val, "valdistrikt", rakning, path)
    m_internal <- .parse_valresultat(m_raw, "M", val, m_niva, rakning, path)
    d <- .valresultat_public_2026(d_internal, "valdistrikt", d_raw, ar = 2022L)
    m <- .valresultat_public_2026(m_internal, m_niva, m_raw, ar = 2022L)
    expect_identical(names(d_internal), names(.valresultat_schema()), info = path)
    expect_identical(names(m_internal), names(.valresultat_schema()), info = path)
    expect_identical(names(d), .valresultat_public_columns_2026("valdistrikt"), info = path)
    expect_identical(names(m), .valresultat_public_columns_2026(m_niva), info = path)
    expect_identical(unique(d$valar), 2022L, info = path)
    expect_identical(unique(m$valar), 2022L, info = path)
    expect_identical(length(unique(d$valdistriktskod)), length(d_raw$valdistrikt), info = path)
    expect_identical(length(unique(d$valdistriktskod[d$raknat])),
                     as.integer(d_raw$antalValdistriktRaknade), info = path)
    .valresultat_check_key(d, "valdistrikt")
    .valresultat_check_key(m, m_niva)
    expect_true(all(vapply(d, function(x) !is.list(x), logical(1))), info = path)
    expect_true(all(vapply(m, function(x) !is.list(x), logical(1))), info = path)
    expect_equal(sum(d$antal_roster[d$raknat], na.rm = TRUE),
                 sum(m$antal_roster, na.rm = TRUE), info = path)
    for (result in list(d, m)) {
      expect_equal(result$andel_roster,
                   result$antal_roster / result$giltiga_roster, info = path)
      expect_equal(result$andel_ogiltiga,
                   result$ogiltiga_roster / result$totalt_antal_roster,
                   info = path)
      expect_equal(result$andel_blanka,
                   result$blanka_roster / result$totalt_antal_roster,
                   info = path)
    }
    vanliga <- d$raknat & d$valdistriktstyp != "uppsamlingsdistrikt" &
      !is.na(d$antal_rostberattigade) & d$antal_rostberattigade > 0
    expect_equal(d$valdel[vanliga],
                 d$totalt_antal_roster[vanliga] / d$antal_rostberattigade[vanliga],
                 info = path)
    andelbar <- !is.na(m$antal_rostberattigade_raknade) &
      m$antal_rostberattigade_raknade > 0
    expect_equal(m$valdel[andelbar],
                 m$totalt_antal_roster[andelbar] /
                   m$antal_rostberattigade_raknade[andelbar], info = path)
    expect_true(all(is.na(d$antal_roster_fg)), info = path)
    expect_true(all(is.na(m$antal_roster_fg)), info = path)
  }
})
