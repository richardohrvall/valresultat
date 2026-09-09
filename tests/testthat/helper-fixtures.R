fixture_kandidaturer <- function() {
  tibble::tibble(
    valtillfalle = "2026",
    kandidatnummer = c("1", "1", "1", "1", "2", "3"),
    valtyp = c("RD", "RD", "RD", "KF", "RD", "RD"),
    partikod = c("A", "A", "B", "A", "A", "A"),
    valomradeskod = c("00", "00", "00", "0180", "00", "00"),
    valomradesnamn = c("Riket", "Riket", "Riket", "Kommun", "Riket", "Riket"),
    valkretskod = c("01", "02", "01", NA, "01", "01"),
    valkretsnamn = c("Krets 1", "Krets 2", "Krets 1", NA, "Krets 1", "Krets 1"),
    partibeteckning = c("Parti A", "Parti A", "Parti B", "Parti A", "Parti A", "Parti A"),
    partiforkortning = c("A", "A", "B", "A", "A", "A"),
    listnummer = as.character(seq_len(6)),
    namn = c("  Andersson, Anna ", "Anna Andersson alias", "Anna Andersson",
             "Anna Andersson", "Bo Berg", "Ogiltig Kandidat"),
    alder_pa_valdagen = c(40L, 40L, 40L, 40L, 50L, 60L),
    kon = c("K", "K", "K", "K", "M", "M"),
    folkbokforingskommun = "0180",
    giltig = c(TRUE, TRUE, TRUE, TRUE, TRUE, FALSE)
  )
}

fixture_kandidatnycklar <- function() {
  tibble::tibble(kandidatnummer = c("1", "2"), valtyp = "RD", partikod = "A")
}

fixture_valda <- function() {
  tibble::tibble(
    kandidatnummer = "1", valtyp = "RD", partikod = "A",
    valomradeskod = "00", valomradesnamn = "Riket",
    valkretskod = "01", valkretsnamn = "Krets 1",
    invalsordning = 1L, valgrund_id = "P", valgrund_text = "Personroster",
    ersattargrupp = "1"
  )
}

fixture_personroster <- function() {
  tibble::tibble(
    kandidatnummer = c("1", "1"), valtyp = "RD", partikod = "A",
    antal_personroster = c(3L, 4L)
  )
}

fixture_personval <- function(available = TRUE) {
  out <- tibble::tibble(
    kandidatnummer = "1", valtyp = "RD", partikod = "A",
    valomradeskod = "00", valkretskod = "01"
  )
  if (!available) out <- out[0, ]
  attr(out, "personval_available") <- available
  out
}
