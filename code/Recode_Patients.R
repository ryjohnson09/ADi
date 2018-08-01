#########################################
# Name: Recode Patient Names
# Author: Ryan Johnson
# Date Created: 29 July 2018
# Purpose: Substitute patient names with 
#    incrementing numbers
#########################################

library(tidyverse)

ADi_datasets <- list.files(pattern = "RawData_tidy.csv")

for (ADi in ADi_datasets){
  # Read in dataset
  ADi_dataset <- read_csv(ADi)
  
  # Create recoding list
  recode_list <- setNames(seq(length(unique(ADi_dataset$Patients))), unique(ADi_dataset$Patients))

  # change patient ID's to numbers
  ADi_dataset_recode <- ADi_dataset %>%
    mutate(Patients = recode(Patients, !!!recode_list))
  
  # Write new file to current directory
  write_csv(ADi_dataset_recode, paste0("RECODED_", ADi))
}  

