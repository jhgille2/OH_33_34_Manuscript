#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param LiteratureData
#' @param NewQTL
#' @param buffer
add_past_literature <- function(LiteratureData = ReadData$OldQTL, NewQTL =
                                Clean_New_QTL, buffer = 5) {

  # A function that takes a chromosome, start and end position, and finds QTL 
  # from the literature table that fall within that range +/- some buffer
  LiteratureFilter <- function(LiteratureTable = LiteratureData, LG = "D2", Min_Consensus = 11.4, Max_Consensus = 13.8, buffer = 5){
    LiteratureTable %>% 
      filter(chr == LG, 
             Start >= Min_Consensus - buffer, 
             End <= Max_Consensus + buffer)
  }
  
  
  AddedLiterature <- NewQTL %>% 
    ungroup() %>%
    # Select just the columns that are used by the function
    select(LG, Min_Consensus, Max_Consensus) %>%
    # Apply the function to this dataframe (use the columns to supply arguments to the function)
    mutate(PastLit = pmap(., LiteratureFilter)) %>% 
    # Join back to the original data to add QTL names
    left_join(NewQTL) %>% 
    # Unnest the literature columns
    unnest(PastLit) %>%
    relocate(qtl_name) %>% 
    # Rename some solumns to identify the ones from the past literature
    rename(Start_Literature_cM = Start, 
           End_Literature_cM   = End, 
           QTL_Literature_Name = QTL) %>% 
    select(-one_of("chr"))

  return(AddedLiterature)
}
