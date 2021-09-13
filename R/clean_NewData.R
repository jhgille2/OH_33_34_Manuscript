#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param qtlData
#' @param ConsensusData
clean_NewData <- function(qtlData = ReadData$NewQTL, ConsensusData =
                          ReadData$Consensus) {
  
CleanedData <-   qtlData %>% 
                      # Split the flanking consensus marker column into two columns (one for each flanking marker)
                      separate(`consensus flanking markers`, 
                               into = c("FlankL", "FlankR"), 
                               sep = " - ") %>% 
                      # Pivot into a long format with one column for the consensus markers
                      pivot_longer(cols = c("FlankL", "FlankR")) %>% 
                      # Join with the consensus map data using the marker names
                      left_join(ConsensusData, by = c("value" = "Name")) %>% 
                      # Pivot back to a wide format
                      pivot_wider() %>% 
                      # Group by QTL name, linkage group, and population
                      group_by(`QTL Name`, LG.x) %>% 
                      # Get the minimum and maximum postion for each QTL on the linkage map
                      summarise(Min_Consensus = min(`Start cM`), Max_Consensus = max(`Stop cM`)) %>% 
                      rename(qtl_name = `QTL Name`, LG = LG.x)

return(CleanedData)
}
