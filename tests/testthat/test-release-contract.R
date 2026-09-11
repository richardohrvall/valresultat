mandat_raw_fixture <- function(valtyp = "RD", kod = "00") {
  parti <- list(
    partibeteckning = "Parti A", partiforkortning = "A", partikod = "A",
    antalMandat = 1L, antalFastaMandat = 1L, antalUtjamningsmandat = 0L,
    antalMandatForegaendeVal = 1L, antalFastaMandatForegaendeVal = 1L,
    antalUtjamningsMandatForegaendeVal = 0L, forandringAntalMandat = 0L
  )
  list(
    valtillfalle = "2026", valklass = "Ordinarie", rakningstillfalle = "slutlig",
    valtyp = valtyp, valdatum = "2026-09-13", test = TRUE,
    valomrade = list(
      kod = kod, namn = "Omrade", antalValdistriktRaknade = 1L,
      antalValdistriktSomSkaRaknas = 1L,
      totaltAntalMandat = 1L, totaltAntalFastaMandat = 1L,
      totaltAntalUtjamningsMandat = 0L,
      totaltAntalMandatForegaendeVal = 1L,
      totaltAntalFastaMandatForegaendeVal = 1L,
      totaltAntalUtjamningsMandatForegaendeVal = 0L,
      mandatfordelning = list(partiLista = list(parti)), valkretsLista = list()
    )
  )
}

test_that("all public functions use the same basic argument validation", {
  no_io <- function(...) stop("Unexpected IO")
  local_mocked_bindings(.read_resultatindex_2026 = no_io, val_file = no_io)
  funs <- list(valresultat, mandat, kandidaturer, kandidater, valda, ersattare)
  for (fun in funs) {
    expect_error(fun(ar = "2026"), "2026")
    expect_error(fun(ar = 2026.5), "2026")
    expect_error(fun(ar = c(2026, 2026)), "2026")
    expect_error(fun(update = NA), "update")
    expect_error(fun(archive = 0), "archive")
    expect_error(fun(data_dir = c("a", "b")), "data_dir")
  }
  for (fun in list(valresultat, mandat, kandidater, valda, ersattare)) {
    expect_error(fun(progress = NA), "progress")
  }
  expect_error(kandidater(resultat = NA), "resultat")
  expect_error(kandidater(resultat = 1), "resultat")
  expect_error(kandidaturer(val = c("RD", NA)), "val")
})

test_that("mandate level matrix filters valid pairs rather than a Cartesian product", {
  expect_equal(nrow(.mandat_nivamatris_2026()), 6L)
  expect_identical(.mandat_par_2026(NULL, "kommun")$valtyp, "KF")
  expect_identical(.mandat_par_2026(c("RD", "KF"), "kommun")$valtyp, "KF")
  expect_error(.mandat_par_2026("RD", "kommun"), "st.*ds inte")
  expect_error(.mandat_par_2026(c("RD", "KF"), c("riket", "region")), "region")
})

test_that("mandat accepts a valid level selected from val NULL", {
  raw <- mandat_raw_fixture("KF", "0180")
  local_mocked_bindings(
    .read_resultatindex_2026 = function(...) tibble::tibble(
      path = "s/kf/Val_2026_slutlig_0180_KF.zip"
    ),
    .resultat_file_2026 = function(...) "fixture.zip",
    read_raw_json_zip_2026 = function(...) raw
  )
  out <- mandat(val = NULL, niva = "kommun", progress = FALSE)
  expect_identical(unique(out$valtyp), "KF")
  expect_identical(unique(out$geografiniva), "kommun")
  key <- c("valtillfalle", "valtyp", "rakningstillfalle", "geografiniva",
           "valomradeskod", "valkretskod", "partikod")
  expect_false(anyDuplicated(out[key]) > 0L)
  expect_identical(names(out), names(.mandat_public_schema_2026()))
  expect_identical(vapply(out, typeof, ""),
                   vapply(.mandat_public_schema_2026(), typeof, ""))
  expect_false(any(vapply(out, is.list, logical(1))))
})

test_that("mandate totals never turn incomplete components into partial sums", {
  pairs <- list(
    c("totaltAntalMandat", "antalMandat", "totalt_antal_mandat"),
    c("totaltAntalFastaMandat", "antalFastaMandat", "totalt_antal_fasta_mandat"),
    c("totaltAntalUtjamningsMandat", "antalUtjamningsmandat", "totalt_antal_utjamningsmandat"),
    c("totaltAntalMandatForegaendeVal", "antalMandatForegaendeVal", "totalt_antal_mandat_fg"),
    c("totaltAntalFastaMandatForegaendeVal", "antalFastaMandatForegaendeVal", "totalt_antal_fasta_mandat_fg"),
    c("totaltAntalUtjamningsMandatForegaendeVal", "antalUtjamningsMandatForegaendeVal", "totalt_antal_utjamningsmandat_fg")
  )
  for (p in pairs) {
    raw <- mandat_raw_fixture()
    totals <- c("totaltAntalMandat", "totaltAntalFastaMandat",
                "totaltAntalUtjamningsMandat", "totaltAntalMandatForegaendeVal",
                "totaltAntalFastaMandatForegaendeVal",
                "totaltAntalUtjamningsMandatForegaendeVal")
    for (nm in totals) raw$valomrade[[nm]] <- NULL
    parti2 <- raw$valomrade$mandatfordelning$partiLista[[1]]
    parti2$partikod <- "B"
    parti2[[p[2]]] <- NULL
    raw$valomrade$mandatfordelning$partiLista[[2]] <- parti2
    expect_true(all(is.na(parse_mandat_2026(raw)[[p[3]]])), info = paste(p, collapse = "/"))
  }
  raw <- mandat_raw_fixture()
  raw$valomrade$totaltAntalMandat <- 2L
  expect_error(parse_mandat_2026(raw), "st.*mmer inte")
  raw <- mandat_raw_fixture()
  raw$valomrade$mandatfordelning$partiLista[[1]]$antalMandat <- -1L
  expect_error(parse_mandat_2026(raw), "icke-negativt heltal")
  raw$valomrade$totaltAntalMandat <- 0L
  raw$valomrade$mandatfordelning$partiLista <- list()
  expect_identical(names(parse_mandat_2026(raw)), names(.mandat_schema_2026()))
})

test_that("elected and person-election availability has three states", {
  absent <- list(valtyp = "RD", rakningstillfalle = "slutlig",
                 valomrade = list(kod = "00"))
  expect_false(.valda_available_2026(absent))
  partial <- mandat_raw_fixture()
  partial$valomrade$valda <- list(partiLedamoterLista = list())
  partial$valomrade$antalValdistriktRaknade <- 0L
  expect_true(is.na(.valda_available_2026(partial)))

  complete <- mandat_raw_fixture()
  complete$valomrade$valda <- list(partiLedamoterLista = list(list(
    partikod = "A", antalTommaStolar = 0L,
    ledamoter = list(list(kandidatnummer = "1"))
  )))
  expect_true(.valda_available_2026(complete))
  expect_identical(parse_tomma_stolar_2026(complete)$antal_tomma_stolar, 0L)

  pv <- complete
  pv$valomrade$kvalificeradeForPersonvalLista <- list()
  expect_true(attr(parse_personval_2026(pv), "personval_available"))
  pv$valomrade$antalValdistriktRaknade <- 0L
  expect_true(is.na(attr(parse_personval_2026(pv), "personval_available")))
})

test_that("candidate status over several areas is unknown unless all are complete", {
  expect_true(.personrost_status(c(TRUE, TRUE)))
  expect_false(.personrost_status(c(FALSE, FALSE)))
  expect_true(is.na(.personrost_status(c(TRUE, FALSE))))
  expect_true(is.na(.personrost_status(c(TRUE, NA))))
})

test_that("ersattare has a stable public relationship schema and key", {
  raw <- mandat_raw_fixture()
  raw$valomrade$valda <- list(partiLedamoterLista = list(list(
    partikod = "A", antalTommaStolar = 0L,
    ledamoter = list(list(
      kandidatnummer = "1", namn = "Ledamot", ersattargrupp = "1",
      ersattareList = list(
        list(kandidatnummer = "2", namn = "Ett", ersattarordning = 1L),
        list(kandidatnummer = "3", namn = "Tva", ersattarordning = 2L)
      )
    ))
  )))
  local_mocked_bindings(
    .read_resultatindex_2026 = function(...) tibble::tibble(path = "s/rd/x_00_RD.zip"),
    .resultat_file_2026 = function(...) "fixture.zip",
    read_raw_json_zip_2026 = function(...) raw
  )
  out <- ersattare(val = "RD", progress = FALSE)
  expect_equal(nrow(out), 2L)
  key <- c("valtillfalle", "valtyp", "geografiniva", "valomradeskod",
           "valkretskod", "partikod", "ledamot_kandidatnummer",
           "ersattare_kandidatnummer", "ersattarordning")
  expect_false(anyDuplicated(out[key]) > 0L)
  expect_type(out$ersattarordning, "integer")
  expect_false(any(vapply(out, is.list, logical(1))))
})

test_that("the intended public namespace is fixed", {
  expect_setequal(getNamespaceExports("valresultat"),
                  c("valresultat", "mandat", "kandidaturer", "kandidater", "valda", "ersattare"))
})

test_that("candidacy parser preserves its public source-row schema", {
  raw <- tibble::tibble(
    valtyp = "RD", valomradeskod = "00", valomradesnamn = "Riket",
    valkretskod = "01", valkretsnamn = "Krets", partibeteckning = "Parti A",
    partiforkortning = "A", partikod = "A", valsedelsstatus = "G",
    listnummer = "1", valkretsbeteckning_pa_valsedeln = "Krets",
    ordning = "1", anmaldakandidater = "J", samtycke = "J", forklaring = "I",
    kandidatnummer = "1", namn = "Namn", alder_pa_valdagen = "40", kon = "K",
    folkbokforingskommun = "0180", valsedelsuppgift = "Uppgift",
    antal_valsedlar_for_den_specifika_listan = "10", giltig = "J"
  )
  out <- parse_kandidaturer_2026(raw)
  expect_identical(names(out), c(
    "valtillfalle", "valtyp", "valomradeskod", "valomradesnamn",
    "valkretskod", "valkretsnamn", "partibeteckning", "partiforkortning",
    "partikod", "valsedelsstatus", "listnummer",
    "valkretsbeteckning_pa_valsedeln", "ordning", "anmalda_kandidater",
    "samtycke", "forklaring", "kandidatnummer", "namn",
    "alder_pa_valdagen", "kon", "folkbokforingskommun", "valsedelsuppgift",
    "antal_valsedlar_lista", "giltig"
  ))
  expect_type(out$ordning, "integer")
  expect_type(out$anmalda_kandidater, "logical")
  expect_false(any(vapply(out, is.list, logical(1))))
})
