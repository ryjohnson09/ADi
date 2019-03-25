################################################
# Title: IVTT_to_tidy.R
# Purpose: Convert raw IVTT ADi data to 
#          normalized tidy format
# Created: 27 June 2018
################################################

library(tidyverse)

## Function to process IVTT data -------------------------------------
IVTT_to_tidy <- function(IVTT_raw_data){
  
  # Make sure data is in csv format
  ifelse(grepl("\\.csv$", IVTT_raw_data),
         IVTT_raw_data, stop("Data not CSV format"))
  
  
  # Read in the csv
  IVTT <- read_csv(IVTT_raw_data)
  
  
  # Make data tidy (i.e. long)
  IVTT <- IVTT %>%
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
  
  
  # Normalize the signal intensity 
  # Get sample medians for negative controls
  sample_neg_ctrl_medians <- IVTT %>%
    filter(ID == "Negative control") %>%
    group_by(Patients) %>%
    summarize(group_median_neg = median(value))
  
  # Add the group_median_neg column to data
  IVTT <- IVTT %>%
    full_join(., sample_neg_ctrl_medians, by = "Patients")
  
  # Compute the norm_value
  IVTT <- IVTT %>%
    mutate(norm_value = log2(value / group_median_neg)) %>%
    
    #remove the pre-computed averages (can calculate later) and negative controls
    filter(Patients != "Average") %>%
    filter(ID != "Negative control")
  
  
  # Set norm_values less than -2 to -2
  IVTT <- IVTT %>%
    mutate(norm_value = ifelse(norm_value <= -2, -2, norm_value))
}

## Run function on each IVTT data set ---------------------------------------------------------
ETEC_IgA <- IVTT_to_tidy("data/raw/Dataset_ETEC_IgA_IVTT.AG/Data/ETEC_IgA_IVTT_RawData.csv")
ETEC_IgG <- IVTT_to_tidy("data/raw/Dataset_ETEC_IgG_IVTT.AG/Data/ETEC_IgG_IVTT_RawData.csv")
PanEC_IgA <- IVTT_to_tidy("data/raw/Dataset_PanEC_IgA_IVTT.AG/Data/PanEC_IgA_IVTT_RawData.csv")
PanEC_IgG <- IVTT_to_tidy("data/raw/Dataset_PanEC_IgG_IVTT.AG/Data/PanEC_IgG_IVTT_RawData.csv")

## Write to data/processed -----------------------------------------------
write_csv(x = ETEC_IgA, path = "data/processed/ETEC_IgA_IVTT_tidy.csv")
write_csv(x = ETEC_IgG, path = "data/processed/ETEC_IgG_IVTT_tidy.csv")
write_csv(x = PanEC_IgA, path = "data/processed/PanEC_IgA_IVTT_tidy.csv")
write_csv(x = PanEC_IgG, path = "data/processed/PanEC_IgG_IVTT_tidy.csv")