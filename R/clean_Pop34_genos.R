#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param GenoFile
#' @param PhenoFile
#' @param LinkageFile
clean_Pop34_genos <- function(GenoFile = Pop34_GenoFile, PhenoFile =
                              Pop34_PhenoFile, LinkageFile = Pop34_LinkageMap, 
                              dest = here("data", "Pop34_Pheno_csvsr.csv")) {

  # A helper function to convert long snp names to a shorter format without
  # alleles
  short_snp_name <- function(SNPName){
    SplitName <- str_split(SNPName, "_", simplify = TRUE)
    
    ShortName <- paste(SplitName[[1]], SplitName[[2]], sep = "_")
    
    return(ShortName)
  }
  
  # Read in the genotype, phenotype, and linkage map files
  geno      <- read_csv(GenoFile)
  PhenoData <- read_excel(PhenoFile, sheet = "pop_34")
  Pop34Map  <- read_excel(LinkageFile) %>% 
    select(marker.34, chr.34, cm.34) %>% 
    rename(Name = marker.34)
  
  Geno_clean <- geno %>% mutate(X2 = as.numeric(str_sub(Name, 3, 4)), 
                                X3 = map_chr(Name, function(x) str_split(x, "_", simplify = TRUE)[[2]]), 
                                Name = map_chr(Name, short_snp_name))  %>% 
    left_join(Pop34Map) %>% 
    relocate(chr.34, cm.34, .after = Name) %>% 
    select(-one_of(c("X2", "X3"))) %>% 
    dplyr::filter(!is.na(chr.34)) %>% 
    arrange(chr.34, cm.34) %>% 
    rename(Genotype = Name) %>% 
    as.data.frame()
  
  colnames(Geno_clean) <- str_remove(colnames(Geno_clean), "\\.GType")
  colnames(Geno_clean) <- str_replace(colnames(Geno_clean), "034", "34")
  
  parentA <- "HS7-4314 (1)"
  parentB <- "PI 253666A (1)"
  
  # The genotype vectors for each parent
  parentA_geno <- Geno_clean[, parentA]
  parentB_geno <- Geno_clean[, parentB]
  
  # What columns have phenotype data
  HasPheno <- colnames(Geno_clean)[4:ncol(Geno_clean)] %in% PhenoData$IND
  
  Geno_clean <- cbind(Geno_clean[, 1:3], Geno_clean[, 4:ncol(Geno_clean)][, HasPheno], Geno_clean[, c(parentA, parentB)])
  
  snpData <- Geno_clean[, 4:ncol(Geno_clean)]
  
  snpData[snpData == snpData[, parentA]] <- "A"
  snpData[snpData == snpData[, parentB]] <- "B"
  
  # A function to get the heterozygous genotypes from parent genotypes
  valid_heterozygotes <- function(){
    parentA_alleles <- map_chr(snpData[, parentA], function(x) str_sub(x, 1, 1))
    parentB_alleles <- map_chr(snpData[, parentB], function(x) str_sub(x, 1, 1))
    
    het1 <- paste0(parentA_alleles, parentB_alleles)
    het2 <- paste0(parentB_alleles, parentA_alleles)
    
    return(list(het1 = het1, het2 = het2))
  }
  
  allhets <- valid_heterozygotes()
  
  # Find all heterozygous cells
  snpData[snpData == allhets$het1] <- "H"
  snpData[snpData == allhets$het2] <- "H"
  
  # Replace "--" with NA
  snpData[snpData == "NC"] <- NA
  
  Geno_clean[, 4:ncol(Geno_clean)] <- snpData
  
  colnames(Geno_clean)[2:3] <- c("", "")
  
  # Export to a file
  write.table(Geno_clean, dest, sep = ",", row.names = FALSE)
  
  # Return the filepath to the export
  return(dest)

}
