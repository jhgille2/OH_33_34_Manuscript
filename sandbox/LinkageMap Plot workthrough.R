

# Read in and clean the linkage maps
Map_33 <- read_excel(tar_read(Pop33_LinkageMap)) %>% 
  rename(Name = SNP) %>% 
  select(LG, Pos, Name) %>% 
  mutate(Name = map_chr(Name, short_snp_name))

Map_34 <- read_excel(tar_read(Pop34_LinkageMap)) %>%
  select(chr.34, cm.34, marker.34) %>% 
  rename(Chr = chr.34, Pos = cm.34, Name = marker.34)
                      

# Read in and clean the preliminary qtl data
PreliminaryQTL <- read_excel(tar_read(PreliminaryQTL), sheet = "Both Pops QTL Combined") %>% 
  clean_names() %>% 
  rename(population = pop, 
         environment = env, 
         chromosome = chr) %>% 
  select(trait, chromosome, ci_c_m, peak, lod, pve_percent, environment, population)

# Read in and clean the final qtl data

# Columns to fill NAs with the last observed non-na value
FillCols <- c("trait", "qtl_name", "chromosome")

FinalQTL <- read_excel(tar_read(ManuscriptQTL)) %>% 
  clean_names() %>% 
  fill(all_of(FillCols)) %>% 
  mutate(trait = str_to_title(trait)) %>% 
  select(trait, chromosome, qtl_name, lod, pve_percent, environment, population)

# Join the preliminary qtl data to the final qtl data to add qtl confidence intervals to the final names
# and then reduce the data so that each qtl has a peak and range for plotting with LinkageMapView
MergedData <- left_join(FinalQTL, PreliminaryQTL, 
                        by = c("trait", "chromosome", "lod", "pve_percent", "environment", "population")) %>% 
  separate(ci_c_m, into = c("ci_begin", "ci_end"), sep = "-") %>% 
  group_by(population, trait, chromosome, qtl_name) %>% 
  summarise(si  = mean(peak), 
            so  = min(ci_begin), 
            ei  = mean(peak), 
            eo  = max(ci_end), 
            col = ifelse(trait == "Seed Oil Content", "blue", "red")) %>% 
  sample_n(1) %>% 
  ungroup() %>% 
  rename(qtl = qtl_name, 
         chr = chromosome) %>% 
  select(chr, qtl, so, si, ei, eo, col, population) %>% 
  mutate(across(c(so, si, ei, eo), as.numeric))
                       

# Seperate dataframes for each population
qtldf_pop33 <- MergedData %>% 
  dplyr::filter(population == 33) %>% 
  select(-population)

qtldf_pop34 <- MergedData %>% 
  dplyr::filter(population == 34) %>% 
  select(-population)


# A function to make a linkage map plot with the LinkageMapView package 
# that uses the linkage map and qtl dataframe for a given population. 
# Exports the pdf file to the path given in the "dest" argument
make_LinkageMap_image <- function(PopulationMap, qtl_df, dest){
  
  # Only print the linkage groups that actually have qtl on them
  chr_hasQTL <- unique(qtl_df$chr)
  
  PopulationMap %<>%
    dplyr::filter(Chr %in% chr_hasQTL)
  
  lmv.linkage.plot(mapthis  = PopulationMap, 
                   outfile  = dest, 
                   qtldf    = qtl_df)
  
}

make_LinkageMap_image(Map_33, qtldf_pop33, here("plots", "Pop33LinkageMap.pdf"))
