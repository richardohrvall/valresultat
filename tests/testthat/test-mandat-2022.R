mandat_2022_fixture <- function(val = "RD", rakning = "slutlig") {
  kod <- switch(val, RD = "00", RF = "01", KF = "0180")
  vk <- switch(val, RD = "01", RF = "0101", KF = "018001")
  parti <- list(partibeteckning = "Parti A", partiforkortning = "A",
                partikod = "A", antalMandat = 2L,
                antalFastaMandat = 2L, antalUtjamningsmandat = 0L)
  nod <- function(kod, namn) {
    list(kod = kod, namnValkrets = namn, antalValdistriktRaknade = 1L,
         antalValdistriktSomSkaRaknas = 1L,
         mandatfordelning = list(partiLista = list(parti)),
         valda = list(partiLedamoterLista = list(list(
           partikod = "A", ledamoter = list(list(kandidatnummer = "1"))
         ))))
  }
  omrade <- nod(kod, "Område")
  omrade$namn <- "Område"
  omrade$valkretsLista <- list(nod(vk, "Valkrets"))
  # I indelade valområden finns valda i valkretsen men inte på områdesnivån.
  omrade$valda <- NULL
  list(valtillfalle = "Val_2022", valtyp = val,
       rakningstillfalle = rakning, valomrade = omrade)
}

test_that("2022 mandate totals and historical missingness are typed", {
  raw <- mandat_2022_fixture()
  out <- parse_mandat_2026(raw)
  expect_identical(unique(out$totalt_antal_mandat), 2L)
  expect_identical(unique(out$antal_mandat), 2L)
  for (name in c("antal_mandat_fg", "antal_fasta_mandat_fg",
                 "antal_utjamningsmandat_fg", "totalt_antal_mandat_fg",
                 "totalt_antal_fasta_mandat_fg",
                 "totalt_antal_utjamningsmandat_fg", "diff_antal_mandat")) {
    expect_type(out[[name]], "integer")
    expect_true(all(is.na(out[[name]])), info = name)
  }
  raw$valomrade$mandatfordelning$partiLista[[1]]$antalMandat <- 0L
  expect_identical(parse_mandat_2026(raw)$antal_mandat[[1]], 0L)
  raw$valomrade$mandatfordelning$partiLista[[1]]$antalMandat <- NULL
  expect_true(is.na(parse_mandat_2026(raw)$totalt_antal_mandat[[1]]))
  raw$valomrade$mandatfordelning <- NULL
  expect_false(any(parse_mandat_2026(raw)$geografiniva == "riket"))
})

test_that("2022 empty chairs require complete elected members in the same node", {
  raw <- mandat_2022_fixture()
  out <- parse_tomma_stolar_2022(raw)
  expect_identical(out$geografiniva, "riksdagsvalkrets")
  expect_identical(out$antal_tomma_stolar, 1L)
  raw$valomrade$valkretsLista[[1]]$valda$partiLedamoterLista[[1]]$ledamoter[[2]] <-
    list(kandidatnummer = "2")
  expect_identical(parse_tomma_stolar_2022(raw)$antal_tomma_stolar, 0L)
  raw$valomrade$valkretsLista[[1]]$antalValdistriktRaknade <- 0L
  expect_equal(nrow(parse_tomma_stolar_2022(raw)), 0L)
  raw$valomrade$valkretsLista[[1]]$antalValdistriktRaknade <- 1L
  raw$valomrade$valkretsLista[[1]]$valda$partiLedamoterLista[[1]]$ledamoter[[3]] <-
    list(kandidatnummer = "3")
  expect_error(parse_tomma_stolar_2022(raw), "verstiger")
  raw$rakningstillfalle <- "preliminar"
  expect_equal(nrow(parse_tomma_stolar_2022(raw)), 0L)
})

test_that("mandates minus distinct elected reproduce explicit 2026 empty chairs", {
  raw <- mandat_2022_fixture()
  raw$valtillfalle <- "Val_2026"
  elected <- raw$valomrade$valkretsLista[[1]]$valda$partiLedamoterLista[[1]]
  elected$antalTommaStolar <- 1L
  raw$valomrade$valkretsLista[[1]]$valda$partiLedamoterLista[[1]] <- elected
  explicit <- parse_tomma_stolar_2026(raw)
  derived <- parse_tomma_stolar_2022(raw)
  expect_identical(derived$antal_tomma_stolar, explicit$antal_tomma_stolar)
  elected$ledamoter[[2]] <- list(kandidatnummer = "2")
  elected$antalTommaStolar <- 0L
  raw$valomrade$valkretsLista[[1]]$valda$partiLedamoterLista[[1]] <- elected
  expect_identical(parse_tomma_stolar_2022(raw)$antal_tomma_stolar,
                   parse_tomma_stolar_2026(raw)$antal_tomma_stolar)
})

test_that("mandat uses shared year selection and preserves the long contract", {
  paths <- function(ar) tibble::tibble(path = vapply(c("RD", "RF", "KF"),
    function(val) paste0("s/", tolower(val), "/Val_",
                         if (ar == 2022L) "20220911" else "2026",
                         "_slutlig_", switch(val, RD = "00", RF = "01", KF = "0180"),
                         "_", val, ".zip"), ""))
  local_mocked_bindings(
    .read_resultatindex = function(ar, ...) paths(ar),
    .resultat_file = function(ar, path, ...) path,
    .read_valresultat_raw = function(file, kalla, val, rakning, ...) {
      mandat_2022_fixture(val, rakning)
    },
    read_raw_json_zip_2026 = function(file, ...) {
      val <- sub(".*_([A-Z]{2})\\.zip$", "\\1", file)
      raw <- mandat_2022_fixture(val)
      raw$valtillfalle <- "Val_2026"
      raw$valomrade$valkretsLista[[1]]$valda <- NULL
      raw
    }
  )
  cases <- list(RD = c("riket", "riksdagsvalkrets"),
                RF = c("region", "regionvalkrets"),
                KF = c("kommun", "kommunvalkrets"))
  for (val in names(cases)) for (niva in cases[[val]]) {
    a <- mandat(ar = 2022, val = val, niva = niva, progress = FALSE)
    b <- mandat(ar = 2026, val = val, niva = niva, progress = FALSE)
    both <- mandat(ar = c(2022, 2026), val = val, niva = niva,
                   progress = FALSE)
    expect_identical(both, dplyr::bind_rows(a, b), info = paste(val, niva))
    expect_identical(names(both)[1:2], c("valtillfalle", "valar"))
    expect_type(both$valar, "integer")
    expect_identical(unique(both$valar), c(2022L, 2026L))
    expect_identical(mandat(ar = "alla", val = val, niva = niva,
                            progress = FALSE), both)
    expect_identical(mandat(fran = 2021, till = 2026, val = val, niva = niva,
                            progress = FALSE), both)
    expect_identical(mandat(ar = c(2026, 2022, 2026), val = val,
                            niva = niva, progress = FALSE),
                     dplyr::bind_rows(b, a))
  }
})

test_that("mandat rejects bad year and level before source access", {
  calls <- 0L
  local_mocked_bindings(.read_resultatindex = function(...) { calls <<- calls + 1L })
  expect_error(mandat(ar = c(2022, 2026), val = "RD", niva = "kommun"),
               "kommun")
  expect_error(mandat(ar = 2024, val = "RD"), "2022.*2026")
  expect_error(mandat(ar = 2022, fran = 2022), "ar.*fran")
  expect_equal(calls, 0L)
})
