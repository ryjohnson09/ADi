#####################################################
# Title: PURIFIED.PROTEIN_to_tidy.R
# Purpose: Convert raw PURIFIED.PROTEIN ADi data to 
#          normalized tidy format
# Created: 27 July 2018
# Usage:
#     PURIFIED.PROTEIN_to_tidy("ETEC_IgG_IVTT.csv")
#####################################################

library(tidyverse)

PURIFIED.PROTEIN_to_tidy <- function(PP_raw_data){
  
  # Make sure data is in csv format
  ifelse(grepl("\\.csv$", PP_raw_data),
         PP_raw_data, stop("Data not CSV format"))
  
  
  ## Read in the csv ############################
  PP <- read_csv(PP_raw_data)
  
  
  # Make data tidy (i.e. long) ##################
  PP <- PP %>%
    gather(key = Patients, value = value, -ID, -Spot.Type, -Description) %>%
    
    # Remove Average Values
    filter(Patients != "Average") %>%
    
    # Add visit column
    mutate(visit = ifelse(grepl(x = Patients, pattern = "v1$"), 1, # visit 1
                   ifelse(grepl(x = Patients, pattern = "v4$"), 4, # visit 4
                   ifelse(grepl(x = Patients, pattern = "v5$"), 5, NA)))) %>% # visit 5
    
    # Add Visit type (acute vs convalescent)
    mutate(visit_type = ifelse(visit == 1, "acute", "convalescent")) %>%
    
    # Strip ending off of patient names
    mutate(Patients = gsub("\\.v\\d$", "", Patients))
  
  # Compute the norm_value ------------------------------------
  PP <- PP %>%
    mutate(norm_value = log2(value))
  
  # Merge in Clinical Metadata
  clin_data <- read_csv("data/processed/TrEAT_Clinical_Metadata_tidy.csv")
  
  PP <- PP %>%
    right_join(., clin_data, by = c("Patients" = "STUDY_ID"))
  
  # Write tidy normalized PP data to processed directory --------------------
  # Create new name for PP normalized tidy data
  tidy_PP_name <- sub('\\.csv$', '', basename(PP_raw_data))
  
  write_csv(PP, paste0("data/processed/", tidy_PP_name, "_tidy.csv"))
}