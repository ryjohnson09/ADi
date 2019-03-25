#####################################################
# Title: PURIFIED.PROTEIN_to_tidy.R
# Purpose: Convert raw PURIFIED.PROTEIN ADi data to 
#          normalized tidy format
# Created: 27 July 2018
#####################################################

library(tidyverse)


## Function for processing PP data -----------------------------------
PURIFIED.PROTEIN_to_tidy <- function(PP_raw_data){
  
  # Make sure data is in csv format
  ifelse(grepl("\\.csv$", PP_raw_data),
         PP_raw_data, stop("Data not CSV format"))
  
  
  # Read in the csv 
  PP <- read_csv(PP_raw_data)
  
  
  # Make data tidy (i.e. long)
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
  
  # Compute the norm_value
  PP %>%
    mutate(norm_value = log2(value))
}


# Run function on each PURIFIED.PROTEIN data set -------------------------------
PP_IgA <- PURIFIED.PROTEIN_to_tidy("data/raw/Dataset_IgA_PURIFIED.PROTEIN/Data/IgA_PurifiedProtein_RawData.csv")
PP_IgG <- PURIFIED.PROTEIN_to_tidy("data/raw/Dataset_IgG_PURIFIED.PROTEIN/Data/IgG_PurifiedProtein_RawData.csv")

# Write to data/processed
write_csv(x = PP_IgG, path = "data/processed/IgG_PurifiedProtein_RawData_tidy.csv")
write_csv(x = PP_IgA, path = "data/processed/IgA_PurifiedProtein_RawData_tidy.csv")
