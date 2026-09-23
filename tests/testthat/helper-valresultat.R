# Små handbyggda källobjekt; inga rådata eller nätanrop.
fixture_resultat_2022 <- function(val, kalla, rakning = "slutlig") {
  raw <- fixture_resultatraw(val, kalla, rakning)
  raw$valtillfalle <- "Val_20220911"
  raw$valklass <- raw$valdatum <- raw$tidigareValdatum <- raw$test <- NULL
  if (kalla == "D") {
    context <- attr(raw, "valresultat_distrikt_context")
    context$mandat <- fixture_resultat_2022(val, "M", rakning)
    context$summering <- NULL
    attr(raw, "valresultat_distrikt_context") <- context
    for (i in seq_along(raw$valdistrikt)) {
      raw$valdistrikt[[i]]$kommunvalkretsKod <- NULL
      raw$valdistrikt[[i]]$kommunvalkretsNamn <- NULL
    }
  }
  .normalisera_resultat_2022(raw)
}

fixture_roster <- function(skala = 1, ovriga = NULL) {
  list(
    rosterPaverkaMandat = list(antalRoster = 10 * skala,
      partiRoster = list(
        list(partikod = "0001", partibeteckning = "Parti A", partiforkortning = "A",
             antalRoster = 6 * skala, andelRoster = 60, ordningsnummer = 1L, deltaMandatfordelning = "ja"),
        list(partikod = "0002", partibeteckning = "Parti B", partiforkortning = "B",
             antalRoster = 4 * skala, andelRoster = 40, ordningsnummer = 2L, deltaMandatfordelning = "nej")
      ), rosterOvrigaPartier = ovriga),
    rosterEjPaverkaMandat = list(antalRoster = 2 * skala, andelRosterAvTotaltAntalRoster = 100 / 6,
      blankaRoster = list(antalRoster = 2 * skala, andelRosterAvTotaltAntalRoster = 100 / 6),
      rosterEjAnmaltDeltagande = list(antalRoster = 0, andelRosterAvTotaltAntalRoster = 0),
      ovrigaOgiltiga = list(antalRoster = 0, andelRosterAvTotaltAntalRoster = 0))
  )
}

fixture_resultatomrade <- function(skala = 1) {
  list(namn = "Omrade", totaltAntalRoster = 12 * skala,
       antalRostberattigade = 20 * skala, valdeltagande = 60,
       valdeltagandeVallokal = 55, antalValdistriktRaknade = as.integer(2 * skala),
       antalValdistriktSomSkaRaknas = as.integer(2 * skala),
       antalRostberattigadeIRaknadeValdistrikt = 20 * skala,
       rapporteringsTid = "2026-09-14T10:00:00", senasteRapporteringstid = "2026-09-14T10:01:00",
       senasteUppdateringstid = "2026-09-14T10:02:00", rostfordelning = fixture_roster(skala))
}

fixture_resultatraw <- function(val = "RD", kalla = "M", rakning = "slutlig") {
  kod <- c(RD = "00", RF = "01", KF = "0180")[[val]]
  raw <- list(valtillfalle = "Test_2026", valklass = "ordinarie", valtyp = val,
              rakningstillfalle = rakning, valdatum = "2026-09-13", test = TRUE,
              senasteUppdateringstid = "2026-09-14T10:03:00", antalUppdateringar = 3L,
              antalValdistriktRaknade = 2L, antalValdistriktSomSkaRaknas = 2L)
  omrade <- fixture_resultatomrade()
  omrade$kod <- kod
  omrade$kommunkod <- "0180"
  omrade$lankod <- "01"
  kretsar <- lapply(c("01", "02"), function(k) {
    obj <- fixture_resultatomrade(0.5)
    obj$kod <- k
    obj$namn <- paste("Krets", k)
    obj$namnValkrets <- obj$namn
    obj
  })
  if (kalla == "M") {
    omrade$valkretsLista <- kretsar
    omrade$valomradessparrProcent <- 3
    raw$valomrade <- omrade
  } else if (kalla == "U") {
    omrade$kommunvalkretsar <- kretsar
    raw$kommuner <- list(omrade)
  } else if (kalla == "D") {
    raw$valdistrikt <- lapply(c("01800001", "01800002"), function(k) {
      obj <- fixture_resultatomrade(0.5)
      obj$valdistriktskod <- k
      obj$valdistriktstyp <- "valdistrikt"
      obj$kommunkod <- "0180"
      obj$lankod <- "01"
      obj$valomradeskod <- kod
      obj$kretskod <- "01"
      obj$kommunvalkretsKod <- "01"
      obj$kommunvalkretsNamn <- "Krets 01"
      obj
    })
  } else {
    lan <- omrade
    lan$kommuner <- list(omrade)
    raw$helaLandet <- omrade
    raw$helaLandet$lan <- list(lan)
  }
  if (kalla == "D") {
    attr(raw, "valresultat_distrikt_context") <- list(
      mandat = fixture_resultatraw(val, "M", rakning),
      summering = if (val %in% c("RD", "RF")) {
        fixture_resultatraw(val, "U", rakning)
      } else {
        NULL
      }
    )
  }
  raw
}

fixture_resultatpath <- function(val = "RD", kalla = "M", rakning = "slutlig") {
  kod <- if (kalla == "O") "OS" else c(RD = "00", RF = "01", KF = "0180")[[val]]
  paste0(if (rakning == "slutlig") "s" else "p", "/", tolower(val),
         "/Test_2026_", rakning, "_", kod, "_", val, ".zip")
}

fixture_parse_resultat <- function(val = "RD", niva = "riket", rakning = "slutlig", raw = NULL) {
  kalla <- .valresultat_kalla(val, niva)
  if (is.null(raw)) raw <- fixture_resultatraw(val, kalla, rakning)
  .parse_valresultat(raw, kalla, val, niva, rakning, fixture_resultatpath(val, kalla, rakning))
}

fixture_public_resultat <- function(
    val = "RD", niva = "riket", rakning = "slutlig", raw = NULL
) {
  kalla <- .valresultat_kalla(val, niva)
  if (is.null(raw)) raw <- fixture_resultatraw(val, kalla, rakning)
  harmoniserat <- .parse_valresultat(
    raw, kalla, val, niva, rakning, fixture_resultatpath(val, kalla, rakning)
  )
  .valresultat_public_2026(harmoniserat, niva, raw)
}
