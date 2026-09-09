parse_kandidaturer_2026 <- function(data) {

  required <- c(
    "valtyp",
    "valomradeskod",
    "valomradesnamn",
    "valkretskod",
    "valkretsnamn",
    "partibeteckning",
    "partiforkortning",
    "partikod",
    "valsedelsstatus",
    "listnummer",
    "valkretsbeteckning_pa_valsedeln",
    "ordning",
    "anmaldakandidater",
    "samtycke",
    "forklaring",
    "kandidatnummer",
    "namn",
    "alder_pa_valdagen",
    "kon",
    "folkbokforingskommun",
    "valsedelsuppgift",
    "antal_valsedlar_for_den_specifika_listan",
    "giltig"
  )

  missing <- setdiff(required, names(data))

  if (length(missing) > 0) {
    stop(
      "F\u00f6ljande f\u00f6rv\u00e4ntade kolumner saknas i kandidaturfilen: ",
      paste(missing, collapse = ", "),
      call. = FALSE
    )
  }

  ja_nej_logisk <- function(x) {
    dplyr::recode_values(
      stringr::str_to_upper(stringr::str_trim(x)),
      "J" ~ TRUE,
      "N" ~ FALSE,
      default = NA
    )
  }

  ja_nej_irrelevant <- function(x) {
    dplyr::recode_values(
      stringr::str_to_upper(stringr::str_trim(x)),
      "J" ~ "ja",
      "N" ~ "nej",
      "I" ~ "irrelevant",
      default = NA_character_
    )
  }

  data |>
    dplyr::transmute(
      valtillfalle = "2026",
      valtyp = dplyr::recode_values(
        stringr::str_to_upper(stringr::str_trim(valtyp)),
        "R" ~ "RF",
        default = stringr::str_to_upper(stringr::str_trim(valtyp))
      ),
      valomradeskod = stringr::str_trim(valomradeskod),
      valomradesnamn = dplyr::na_if(
        stringr::str_trim(valomradesnamn),
        ""
      ),
      valkretskod = stringr::str_trim(valkretskod),
      valkretsnamn = dplyr::na_if(
        stringr::str_trim(valkretsnamn),
        ""
      ),
      partibeteckning = dplyr::na_if(
        stringr::str_trim(partibeteckning),
        ""
      ),
      partiforkortning = dplyr::na_if(
        stringr::str_trim(partiforkortning),
        ""
      ),
      partikod = stringr::str_trim(partikod),
      valsedelsstatus = dplyr::na_if(
        stringr::str_to_upper(stringr::str_trim(valsedelsstatus)),
        ""
      ),
      listnummer = dplyr::na_if(stringr::str_trim(listnummer), ""),
      valkretsbeteckning_pa_valsedeln = dplyr::na_if(
        stringr::str_trim(valkretsbeteckning_pa_valsedeln),
        ""
      ),
      ordning = readr::parse_integer(ordning, na = c("", "NA")),
      anmalda_kandidater = ja_nej_logisk(anmaldakandidater),
      samtycke = ja_nej_irrelevant(samtycke),
      forklaring = ja_nej_irrelevant(forklaring),
      kandidatnummer = stringr::str_trim(kandidatnummer),
      namn,
      alder_pa_valdagen = readr::parse_integer(
        alder_pa_valdagen,
        na = c("", "NA")
      ),
      kon = dplyr::na_if(stringr::str_trim(kon), ""),
      folkbokforingskommun = dplyr::na_if(
        stringr::str_trim(folkbokforingskommun),
        ""
      ),
      valsedelsuppgift,
      antal_valsedlar_lista = readr::parse_integer(
        antal_valsedlar_for_den_specifika_listan,
        na = c("", "NA")
      ),
      giltig = ja_nej_logisk(giltig)
    )
}
