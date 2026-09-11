.mandat_nivamatris_2026 <- function() {
  tibble::tribble(
    ~valtyp, ~geografiniva,
    "RD", "riket", "RD", "riksdagsvalkrets",
    "RF", "region", "RF", "regionvalkrets",
    "KF", "kommun", "KF", "kommunvalkrets"
  )
}

.mandat_par_2026 <- function(val, niva) {
  val <- if (is.null(val)) c("RD", "RF", "KF") else val
  matris <- dplyr::filter(.mandat_nivamatris_2026(), valtyp %in% val)
  if (is.null(niva)) return(matris)
  .check_text(niva, "niva", flera = TRUE)
  ok <- unique(.mandat_nivamatris_2026()$geografiniva)
  okanda <- setdiff(niva, ok)
  if (length(okanda)) stop("Ok\u00e4nd geografisk niv\u00e5: ", paste(okanda, collapse = ", "), ".", call. = FALSE)
  saknas <- setdiff(unique(niva), matris$geografiniva)
  if (length(saknas)) {
    stop("Niv\u00e5n ", paste(saknas, collapse = ", "),
         " st\u00f6ds inte f\u00f6r vald valtyp.", call. = FALSE)
  }
  dplyr::filter(matris, geografiniva %in% niva)
}

.mandat_public_schema_2026 <- function() {
  dplyr::mutate(.mandat_schema_2026(), antal_tomma_stolar = integer())
}

#' Mandat
#'
#' Hämtar mandatfördelningen.
#'
#' @param ar Valår. För närvarande stöds 2026.
#' @param val En eller flera valtyper: `"RD"`, `"RF"` eller `"KF"`.
#'   `NULL` ger alla.
#' @param rakning Exakt en räkning: `"slutlig"` eller `"preliminar"`.
#' @param niva En eller flera geografiska nivåer. RD stöder `"riket"` och
#'   `"riksdagsvalkrets"`, RF `"region"` och `"regionvalkrets"`, och KF
#'   `"kommun"` och `"kommunvalkrets"`. `NULL` ger alla relevanta nivåer.
#' @param source Datakälla: `"auto"`, `"local"` eller `"remote"`.
#' @param data_dir Lokal rotmapp för rådata.
#' @param update Om `TRUE`, uppdateras lokala arbetskopior.
#' @param archive Om `TRUE`, sparas även daterade snapshots.
#' @param progress Visa progressindikator.
#' @return En tibble där en rad avser val, räkning, geografisk nivå och
#'   område samt parti. Områdestotaler upprepas på partirader och nivåerna
#'   ska inte summeras tillsammans. Saknade totalsummor är `NA` när någon
#'   mandatkomponent är okänd. `antal_tomma_stolar` är `NA` utan verifierat
#'   underlag och explicit noll bevaras.
#' @examples
#' \dontrun{mandat(val = "RD", source = "local", data_dir = "mitt_arkiv")}
#' @seealso [valda()], [ersattare()], [valresultat-package]
#' @export
mandat <- function(
    ar = 2026,
    val = NULL,
    rakning = c("slutlig", "preliminar"),
    niva = NULL,
    source = c("auto", "local", "remote"),
    data_dir = NULL,
    update = FALSE,
    archive = FALSE,
    progress = interactive()
) {

  source <- .check_public_args(
    ar, "mandat", source, data_dir, update, archive, progress
  )
  if (missing(rakning)) rakning <- "slutlig"
  .check_text(rakning, "rakning")
  if (!rakning %in% c("slutlig", "preliminar")) {
    stop("Ok\u00e4nd rakning; ange slutlig eller preliminar.", call. = FALSE)
  }
  val <- .valtyper(val)
  par <- .mandat_par_2026(val, niva)
  val <- unique(par$valtyp)

  index <- .read_resultatindex_2026(
    source = source,
    data_dir = data_dir,
    update = update,
    archive = archive
  )

  prefix <- dplyr::recode_values(
    rakning,
    "slutlig" ~ "s",
    "preliminar" ~ "p"
  )

  paths <- purrr::map_dfr(
    val,
    \(valtyp) {

      pattern <- dplyr::recode_values(
        valtyp,
        "RD" ~ paste0("^", prefix, "/rd/.*_00_RD\\.zip$"),
        "RF" ~ paste0("^", prefix, "/rf/.*_[0-9]{2}_RF\\.zip$"),
        "KF" ~ paste0("^", prefix, "/kf/.*_[0-9]{4}_KF\\.zip$")
      )

      index |>
        dplyr::filter(stringr::str_detect(path, pattern)) |>
        dplyr::transmute(
          valtyp = valtyp,
          path
        )
    }
  )

  saknade_val <- setdiff(val, unique(paths$valtyp))
  if (length(saknade_val)) {
    stop(
      "Hittade ingen mandatfil f\u00f6r: ", paste(saknade_val, collapse = ", "), ".",
      call. = FALSE
    )
  }
  filkod <- sub(".*_([^_]+)_[A-Z]{2}\\.zip$", "\\1", paths$path)
  if (anyDuplicated(paste(paths$valtyp, filkod))) {
    stop("Dubbla mandatfiler f\u00f6r samma filidentitet.", call. = FALSE)
  }

  parsed <- purrr::map(
    paths$path,
    \(path) {

      file <- .resultat_file_2026(
        path = path, source = source, data_dir = data_dir,
        update = update, archive = archive
      )

      raw <- read_raw_json_zip_2026(
        file,
        type = "mandatfordelning"
      )

      if (!identical(as_chr_na(raw$valtyp), paths$valtyp[[match(path, paths$path)]]) ||
          !identical(as_chr_na(raw$rakningstillfalle), rakning)) {
        stop("Mandatfilens valtyp eller r\u00e4kning st\u00e4mmer inte med fils\u00f6kv\u00e4gen.", call. = FALSE)
      }

      mandat_data <- parse_mandat_2026(raw)

      tomma_stolar <- parse_tomma_stolar_2026(raw)

      if (nrow(tomma_stolar) > 0) {
        mandat_data <- mandat_data |>
          dplyr::left_join(
            tomma_stolar,
            by = dplyr::join_by(
              valtyp,
              geografiniva,
              valomradeskod,
              valkretskod,
              partikod
            )
          )
      } else {
        mandat_data <- mandat_data |>
          dplyr::mutate(
            antal_tomma_stolar = NA_integer_
          )
      }

      mandat_data
    },
    .progress = progress
  ) |>
    purrr::list_rbind() |>
    dplyr::inner_join(par, by = dplyr::join_by(valtyp, geografiniva))

  parsed <- dplyr::bind_rows(.mandat_public_schema_2026(), parsed)
  nyckel <- c("valtillfalle", "valtyp", "rakningstillfalle", "geografiniva",
              "valomradeskod", "valkretskod", "partikod")
  obligatoriska <- setdiff(nyckel, "valkretskod")
  if (nrow(parsed) && (anyNA(parsed[obligatoriska]) || anyDuplicated(parsed[nyckel]))) {
    stop("Mandatresultatet har saknad eller dubblerad nyckel.", call. = FALSE)
  }
  parsed
}
