# Install pacman if it does not already exist
if(!require(pacman)){
  install.packages("pacman")
}

# Use pacman to load/install packaged
pacman::p_load(conflicted, 
               dotenv, 
               targets, 
               tarchetypes, 
               tidyverse, 
               rmarkdown, 
               LinkageMapView, 
               here, 
               readxl, 
               qtl, 
               janitor, 
               magrittr, 
               officer)

# Conflict preferences
conflict_prefer("filter", "dplyr")