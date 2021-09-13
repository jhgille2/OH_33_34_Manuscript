#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param PhenoFile
#' @param dest
clean_Pop34_phenos <- function(PhenoFile = Pop34_PhenoFile, dest = here("data",
                               "Pop34_Pheno_csvsr.csv")) {

  PhenoData <- read_excel(PhenoFile, sheet = "pop_34")
  
  PhenoData %<>% 
    rename(Genotype = IND) %>% 
    t()
  
  write.table(PhenoData, file = dest, row.names = TRUE, col.names = FALSE, sep = ",")
  
  return(dest)

}
