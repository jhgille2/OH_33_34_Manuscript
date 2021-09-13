#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param Genotypes
#' @param Map
#' @param dest
clean_Pop33_genos <- function(Genotypes = Pop33_GenoFile, Map =
                              Pop33_LinkageMap, dest = here("data",
                              "Pop33_Geno_csvs.csv")) {

  # Read in the linkage map and rectangular SNP calls for Pop 33
  LinkageMap_Pop33 <- read_excel(Map)
  Genos_Pop33      <- read_excel(Genotypes, sheet = "JustCalls")
  
  # SNPs with a position on the linkage map
  HasMapPos <- colnames(Genos_Pop33)[2:ncol(Genos_Pop33)][colnames(Genos_Pop33)[2:ncol(Genos_Pop33)] %in% LinkageMap_Pop33$SNP]
  
  ColNameFilter <- c("Genotype", HasMapPos)
  
  Parent1Genos <- c("HS7-4314(1)", "HS7-4314(2)")
  Parent2Genos <- c("PI205085(1)", "PI205085(2)", "PI205085(3)")
  
  # Filter the columns (SNP names) to only those that have a position on the linkage map
  Genos_Pop33_reduced <- Genos_Pop33 %>% 
    select(all_of(ColNameFilter)) %>% 
    mutate(Genotype = ifelse(Genotype %in% Parent1Genos, "HS7-4314", 
                             ifelse(Genotype %in% Parent2Genos, "PI205085", Genotype))) %>% 
    group_by(Genotype) %>%
    sample_n(1) %>% 
    ungroup()
  
  # Transpode the linkage map so that it can be joined to the genotypes
  Transposed_LinkageMap <- LinkageMap_Pop33 %>% 
    column_to_rownames("SNP") %>% 
    t() %>% 
    as_tibble() %>% 
    mutate(Genotype = NA) %>% 
    relocate(Genotype) %>% 
    mutate(across(everything(), as.character))
  
  # COmbine the map data with the genotype data
  GenoFile <- bind_rows(Transposed_LinkageMap, Genos_Pop33_reduced)
  
  # Write the data to a csv file
  write_csv(GenoFile, dest, na = "")
  
  # Return the filepath where the file was saved to
  return(dest)
}
