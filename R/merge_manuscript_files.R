#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title

merge_manuscript_files <- function(Manuscript) {

  # Read in each of the .docx objects
  Manuscript_docx <- read_docx(here("doc", "Manuscript.docx"))
  
  # Merge with the phenotype table, correlation table, QTL table, and distribution plots
  
  
  Manuscript_docx %>% 
    body_add_docx(src = here("doc", "phenot_table.docx")) %>% 
    body_add_docx(src = here("doc", "corr_table.docx")) %>% 
    body_add_docx(src = here("doc", "distribution_table.docx")) %>% 
    print(target = here("doc", "Manuscript_final.docx"))
  
  return(here("doc", "Manuscript_final.docx"))
}
