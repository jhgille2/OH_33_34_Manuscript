#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param file
#' @param dest
save_merged <- function(data = LiteratureMerge, dest = here("data",
                        "LiteratureAdded.csv")) {

  write_csv(data, file = dest)

  return(dest)
}
