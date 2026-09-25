.kandidatur_kalla <- function(ar) {
  if (ar == 2022L) {
    return(list(
      path = "parti/kandidaturer.zip",
      samling = "val2022",
      base_url = "https://data.val.se/filer/val2022"
    ))
  }
  if (ar == 2026L) {
    return(list(
      path = "parti/kandidaturer.csv",
      samling = "val2026",
      base_url = "https://data.val.se/filer/val2026"
    ))
  }
  stop("Ingen kandidaturk\u00e4lla f\u00f6r val\u00e5r ", ar, ".", call. = FALSE)
}

.verifierade_kandidatur_csv_md5 <- function(ar) {
  switch(as.character(ar),
    `2022` = "639daa9630a1f2554f1c6839473448ee",
    `2026` = "c30f47a4ea28da2d926e0e186477a98b",
    character()
  )
}

.namnvalsedlar_kompletta <- function(csv_file, ar) {
  tolower(unname(tools::md5sum(csv_file))) %in%
    .verifierade_kandidatur_csv_md5(ar)
}
