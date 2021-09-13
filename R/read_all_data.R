#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param newQTL
#' @param oldQTL
#' @param conversionTable
read_all_data <- function(newQTL = Pop33_34_qtl, oldQTL = LiteratureTable,
                          conversionTable = QTL_Name_Conversion, consensus = ConsensusMap) {

  Pop33_34Data <- read_excel(newQTL, 
                             sheet = "Both Pops QTL Combined")
  
  LiteratureTable <- read_csv(oldQTL) %>% 
    select(LiteratureTitle, 
           QTL, 
           PubYear, 
           `LG(GmComposite2003)`, 
           `Start(cM)`, 
           `End(cM)`, 
           QTL_Type) %>% 
    rename(chr =`LG(GmComposite2003)`, 
           Start = `Start(cM)`, 
           End = `End(cM)`) %>% 
    distinct() %>% 
    mutate(Start = as.numeric(Start), 
           End   = as.numeric(End))
  
  Conversion <- read_csv(conversionTable)
  
  Consensus <- read_csv(consensus)
  
  results <- list("NewQTL"     = Pop33_34Data, 
                  "OldQTL"     = LiteratureTable, 
                  "Conversion" = Conversion, 
                  "Consensus"  = Consensus)

  return(results)
}
