## Load your packages, e.g. library(targets).
source("./packages.R")

## Load your R files
lapply(list.files("./R", full.names = TRUE), source)

## tar_plan supports drake-style targets and also tar_target()
tar_plan(

  ## Section: Raw input files for cross objects
  ##################################################
  
  # Population 33 genotypes
  tar_target(Pop33_GenoFile_raw, 
             here("data", "rqtl_files", "raw_input", "Pop33Genos.xlsx"), 
             format = "file"),
  
  # Population 34 genotypes
  tar_target(Pop34_GenoFile_raw, 
             here("data", "rqtl_files", "raw_input","OH34_geno.csv"), 
             format = "file"), 
  
  # Population 33 linkage map
  tar_target(Pop33_LinkageMap, 
             here("data", "rqtl_files", "raw_input","OH33_LinkageMap.xlsx"), 
             format = "file"),
  
  # Population 34 linkage map
  tar_target(Pop34_LinkageMap, 
             here("data", "rqtl_files", "raw_input","OH 34 Linkage Map.xlsx"), 
             format = "file"),
  
  # The phenotype file
  tar_target(PhenoFile, 
             here("data", "rqtl_files", "raw_input","FinalPhenos.xlsx"), 
             format = "file"),
  
  # The final QTL table included in the manuscript
  tar_target(ManuscriptQTL, 
             here("data", "manuscript_qtl_tables", "Manuscript_qtl_table.xlsx"), 
             format = "file"),
  
  # Preliminary QTL table with more detail on linkage map intervals for QTL
  tar_target(PreliminaryQTL, 
             here("data", "manuscript_qtl_tables", "QTL Tables - Tentative.xlsx"), 
             format = "file"),
  
  ## Section: Initial summary plots and tables
  ##################################################
  # tar_target(LinkageMapImages, 
  #            make_linkage_map_images(Pop33Map   = Pop33_LinkageMap, 
  #                                    Pop34Map   = Pop34_LinkageMap, 
  #                                    FinalQTL   = ManuscriptQTL, 
  #                                    InitialQTL = PreliminaryQTL), 
  #            format = "file"),
  
  
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

  ## Section: Finding past literature with QTL at the same loci
  ## as those found in the current study
  ##################################################
  
  # Input files
  # 1. QTL found in pops 33 and 34
  # 2. Past QTL with literature/other data
  # 3. Conversion table between LG names and numbers
  # 4. Consensus map with physical/genetic positions
  tar_target(Pop33_34_QTL, 
             here("data", "past_literature_files", "input", "qtl_tables.xlsx"), 
             format = "file"), 
  
  tar_target(LiteratureTable, 
             here("data", "past_literature_files", "input", "ProtOilYieldLit.csv"), 
             format = "file"), 
  
  tar_target(QTL_Name_Conversion, 
             "https://raw.githubusercontent.com/jhgille2/SoybaseData/master/SoybaseLGAssignments.csv", 
             format = "url"),
  
  tar_target(ConsensusMap, 
             "https://raw.githubusercontent.com/jhgille2/SoybaseData/master/ConsensusMapWithPositions.csv", 
             format = "url"),
  
  # Read in the files
  tar_target(ReadData, 
             read_all_data(newQTL = Pop33_34_QTL, 
                           oldQTL = LiteratureTable, 
                           conversionTable = QTL_Name_Conversion, 
                           consensus = ConsensusMap)),
  
  # Add Consensus map marker positions to the new QTL data
  tar_target(Clean_New_QTL, 
             clean_NewData(qtlData = ReadData$NewQTL, 
                           ConsensusData = ReadData$Consensus)), 
  
  # Join with the literature table to find which past QTL
  # have been found in similar regions
  tar_target(LiteratureMerge, 
             add_past_literature(LiteratureData = ReadData$OldQTL, 
                                 NewQTL = Clean_New_QTL, 
                                 buffer = 5)),
  
  # Write the merged file
  tar_target(SaveMergedFile, 
             save_merged(data = LiteratureMerge, dest = here("data", 
                                                             "past_literature_files", 
                                                             "output", 
                                                             "LiteratureAdded.csv")), 
             format = "file"),
  
  ## Section: Writeup documents
  ##################################################
  tar_render(Writeup, "doc/Writeup.Rmd"), 
  
  # render the manuscript and then combine it with the table/phenotype distribution table files
  tar_render(Manuscript, "doc/Manuscript.Rmd"), 
  
  tar_target(Merge_Manuscript, 
             merge_manuscript_files(Writeup), 
             format = "file")

)
