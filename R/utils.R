##################################################
## Project: Pop 33 and 34 oil mapping manuscript
## Script purpose: Utiliy functions for the workflow
## Date: 2021-09-08
## Author: Jay Gillenwater
##################################################


# A helper function to convert long snp names to a shorter format without
# alleles
short_snp_name <- function(SNPName){
  SplitName <- str_split(SNPName, "_", simplify = TRUE)
  
  ShortName <- paste(SplitName[[1]], SplitName[[2]], sep = "_")
  
  return(ShortName)
}
