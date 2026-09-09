parse_tomma_stolar_2026 <- function(raw) {

  valtyp <- as_chr_na(raw$valtyp)
  valomrade <- raw$valomrade

  geografiniva_valomrade <- dplyr::recode_values(
    valtyp,
    "RD" ~ "riket",
    "RF" ~ "region",
    "KF" ~ "kommun",
    default = NA_character_
  )

  geografiniva_valkrets <- dplyr::recode_values(
    valtyp,
    "RD" ~ "riksdagsvalkrets",
    "RF" ~ "regionvalkrets",
    "KF" ~ "kommunvalkrets",
    default = NA_character_
  )

  empty_tomma_stolar <- function() {
    tibble::tibble(
      valtyp = character(),
      geografiniva = character(),
      valomradeskod = character(),
      valkretskod = character(),
      partikod = character(),
      antal_tomma_stolar = integer()
    )
  }

  parse_niva <- function(
      valda,
      geografiniva,
      valkretskod = NA_character_
  ) {

    if (is.null(valda) ||
        is.null(valda$partiLedamoterLista) ||
        length(valda$partiLedamoterLista) == 0) {
      return(empty_tomma_stolar())
    }

    purrr::map_dfr(
      valda$partiLedamoterLista,
      \(parti) tibble::tibble(
        valtyp = valtyp,
        geografiniva = geografiniva,
        valomradeskod = as_chr_na(valomrade$kod),
        valkretskod = valkretskod,
        partikod = as_chr_na(parti$partikod),
        antal_tomma_stolar = as_int_na(parti$antalTommaStolar)
      )
    )
  }

  out_valomrade <- parse_niva(
    valda = valomrade$valda,
    geografiniva = geografiniva_valomrade
  )

  valkretsar <- valomrade$valkretsLista

  if (is.null(valkretsar) || length(valkretsar) == 0) {
    return(out_valomrade)
  }

  out_valkrets <- valkretsar |>
    purrr::map(
      \(vk) parse_niva(
        valda = vk$valda,
        geografiniva = geografiniva_valkrets,
        valkretskod = as_chr_na(vk$kod)
      )
    ) |>
    purrr::list_rbind()

  dplyr::bind_rows(
    out_valomrade,
    out_valkrets
  )
}
