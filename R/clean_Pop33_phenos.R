#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param Phenotypes
#' @param dest
clean_Pop33_phenos <- function(Phenotypes = PhenoFile, dest = here("data",
                               "Pop33_Geno_csvs.csv")) {

  # Read in the phenotype file
  Pop33Pheno <- read_excel(Phenotypes, sheet = "pop_33")
  
  # Get the column names of the phenotypes so that they can be converted to numerics
  PhenoCols <- colnames(Pop33Pheno)[2:ncol(Pop33Pheno)]
  
  # Clean up the genotype names
  Pop33Pheno_Clean <- Pop33Pheno %>% 
    rename(Genotype = IND) %>% 
    mutate(Genotype = str_replace(Genotype, "X033\\.", "033-"), 
           across(all_of(PhenoCols), as.numeric))
  
  # Write the cleaned phenotypes to a csv file
  write_csv(Pop33Pheno_Clean, file = dest, na = "")
  
  # Return the file path that the data was saved to
  return(dest)
}
