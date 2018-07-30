#####################################################
# Name: IVTT_stats.R
# Author: Ryan Johnson
# Date Created: 27 July 2018
# Purpose: Compare any two groups (eg. Visit 1 vs 4)
#          and calculate statistics for each protein
#          for the IVTT ADi tidy normalized data
# Example:
#    IVTT_stats(dataset = "ETEC_IgG_IVTT_tidy.csv",
#               group_column = "visit",
#               group_variables = c(1,4))
#####################################################

library(tidyselect)

IVTT_stats <- function(dataset, # ADi dataset in tidy format
                      group_column, # eg. visit
                      group_variables){ # Values in group column to compare c(1,4)
  
  group_column <- as.name(group_column)
  
  ## Read in ADi Data set -------------------------------------------------
  if(is.character(dataset)){
    ADi_dataset <- read_csv(dataset)
  } else {
    ADi_dataset <- dataset
  }
  
  
  
  # Rename grouping variables
  var1 <- paste0(toString(group_column), ".", group_variables[1])
  var2 <- paste0(toString(group_column), ".", group_variables[2])
  
  # Select only columns of interest
  ADi_dataset1 <- ADi_dataset %>%
    select(ID, Description, Patients, norm_value, !!group_column) %>%
    
    # merge together ID and Description
    unite(col = "ID_Description", c("ID", "Description")) %>%
    
    # filter for only groups of interest
    filter(!!group_column %in% group_variables) %>%
    
    # Rename values in group_column to ensure they are strings
    mutate(!!group_column := ifelse(!!group_column == group_variables[1], var1, var2))

  
  
  # Group by group_column
  ADi_stat <- ADi_dataset1 %>%
    group_by(!!group_column, ID_Description) %>%
    summarise(values = list(norm_value)) %>%
    spread(!!group_column, values)

  
  # Compute Statistics
  ADi_stat1 <- ADi_stat %>%
    group_by(ID_Description) %>%
    
    # Counts
    mutate(count.1 = length(unlist(!!as.name(var1)))) %>%
    mutate(count.2 = length(unlist(!!as.name(var2)))) %>%
    
    # Mean
    mutate(mean1 = mean(unlist(!!as.name(var1)))) %>%
    mutate(mean2 = mean(unlist(!!as.name(var2)))) %>%
    mutate(mean_diff = mean2 - mean1) %>%
    
    # T test
    mutate(p_value = t.test(unlist(!!as.name(var1)), unlist(!!as.name(var2)))$p.value) %>%
    
    # Remove list columns
    select(-!!as.name(var1), -!!as.name(var2))
  
  ADi_stat1
} 
