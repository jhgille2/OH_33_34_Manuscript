## Load your packages, e.g. library(targets).
source("./packages.R")

## Load your R files
lapply(list.files("./R", full.names = TRUE), source)

## tar_plan supports drake-style targets and also tar_target()
tar_plan(

  ## Section: Raw input files
  ##################################################
  
  # Population 33 genotypes
  tar_target(Pop33_GenoFile_raw, 
             here("data", "Pop33Genos.xlsx"), 
             format = "file"),
  
  # Population 34 genotypes
  tar_target(Pop34_GenoFile_raw, 
             here("data", "OH34_geno.csv"), 
             format = "file"), 
  
  # Population 33 linkage map
  tar_target(Pop33_LinkageMap, 
             here("data", "OH33_LinkageMap.xlsx"), 
             format = "file"),
  
  # Population 34 linkage map
  tar_target(Pop34_LinkageMap, 
             here("data", "OH 34 Linkage Map.xlsx"), 
             format = "file"),
  
  # The phenotype file
  tar_target(PhenoFile, 
             here("data", "FinalPhenos.xlsx"), 
             format = "file"),
  
  # The final QTL table included in the manuscript
  tar_target(ManuscriptQTL, 
             here("data", "Manuscript_qtl_table.xlsx"), 
             format = "file"),
  
  # Preliminary QTL table with more detail on linkage map intervals for QTL
  tar_target(PreliminaryQTL, 
             here("data", "QTL Tables - Tentative.xlsx"), 
             format = "file"),
  
  ## Section: Initial summary plots and tables
  ##################################################
  tar_target(LinkageMapImages, 
             make_linkage_map_images(Pop33Map   = Pop33_LinkageMap, 
                                     Pop34Map   = Pop34_LinkageMap, 
                                     FinalQTL   = ManuscriptQTL, 
                                     InitialQTL = PreliminaryQTL), 
             format = "file"),
  
  
  ## Section: Data cleaning; preparing the input genotype/phenotype
  ## files for the pop 33 & 34 cross objects
  ##################################################
  
  # Convert the pop 33 linkage map/genotypes into a rqtl csvs file
  tar_target(Pop33GenoFile_cross, 
             clean_Pop33_genos(Genotypes = Pop33_GenoFile_raw, 
                               Map       = Pop33_LinkageMap, 
                               dest      = here("data", "Pop33_Geno_csvs.csv")), 
             format = "file"),
  
  # Clean up the genotype data for pop 34 and export it to a csvsr genotype file
  tar_target(Pop34GenoFile_cross, 
             clean_Pop34_genos(GenoFile    = Pop34_GenoFile_raw, 
                               PhenoFile   = PhenoFile, 
                               LinkageFile = Pop34_LinkageMap, 
                               dest        = here("data", "Pop34_Geno_csvsr.csv")), 
             format = "file"),
  
  # Clean up the genotype names in the pop33 phenotype file
  tar_target(Pop33PhenoFile_cross, 
             clean_Pop33_phenos(Phenotypes = PhenoFile, 
                                dest = here("data", "Pop33_Pheno_csvs.csv")), 
             format = "file"),
  
  # Clean up the phenotype data and export it to a csvsr phenotype file
  tar_target(Pop34PhenoFile_cross, 
             clean_Pop34_phenos(PhenoFile = PhenoFile, 
                                dest = here("data", "Pop34_Pheno_csvsr.csv")), 
             format = "file"),
  
  ## Section: Cross objects
  ##################################################
  tar_target(Pop33Cross,
             read.cross(format       = "csvs", 
                        genfile      = Pop33GenoFile_cross, 
                        phefile      = Pop33PhenoFile_cross, 
                        map.function = "kosambi", 
                        crosstype    = "riself") %>% jittermap()),
  
  # Read the genotype and phenotype files into a r/qtl cross
  tar_target(Pop34Cross, 
             read.cross(format    = "csvsr", 
                        genfile   = Pop34GenoFile_cross, 
                        phefile   = Pop34PhenoFile_cross, 
                        crosstype = "riself") %>% jittermap()),

  tar_render(Writeup, "doc/Writeup.Rmd")

)
