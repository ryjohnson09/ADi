#####################################################
# Name: linear_plots.R
# Author: Ryan Johnson
# Date Created: 30 May 2019
# Purpose: Visulize the normalized spot signals from
#  acute to convalescent using the ADi data. 
#####################################################

## Libraries -----------------------------------------------------

library(tidyverse)

## Set Variable --------------------------------------------------
read_in_data <- "data/processed/PanEC_IgA_IVTT_tidy.csv"
detection_column <- "Norovirus_both"
visit_number <- c(1,5)


## Read in Data --------------------------------------------------

adi_data <- read_csv(read_in_data)
treat <- read_csv("data/processed/TrEAT_Clinical_Metadata_tidy.csv")


## Reformat Data ------------------------------------------------------

# Filter for visits of interest/remove LOP and PLA
adi_data_matched <- adi_data %>% 
  left_join(., treat, by = c("Patients" = "STUDY_ID")) %>% 
  filter(!Treatment %in% c("LOP", "PLA")) %>% 
  filter(visit %in% visit_number) %>% 
  group_by(Patients) %>% 
  filter(n_distinct(visit) == 2) %>% 
  ungroup()



adi_data_spread <- adi_data_matched %>%
  
  # Select for patients by culture
  filter(!!sym(detection_column) == "yes") %>%
  
  # Extract columns of interest
  select(ID, Description, Patients, visit, norm_value, LLS_severity, Impact_of_illness_on_activity_level) %>%
  
  # Add ecoli column
  mutate(ecoli = str_extract(ID, "E.+EC")) %>% 
  
  # Merge the ID and Description columns
  unite(col = "ID_Description", sep = "_", c("ID", "Description")) %>%
  
  # Spread so that norm_values are split by visit
  spread(visit, norm_value)

## Factor ----------------------------------
adi_data_spread$LLS_severity <- factor(adi_data_spread$LLS_severity, levels = c("mild", "moderate", "severe"))
adi_data_spread$Impact_of_illness_on_activity_level <- factor(adi_data_spread$Impact_of_illness_on_activity_level)



## Plot Visit 1 vs 5 ---------------------------------------------------

adi_plot <- ggplot(data = adi_data_spread, aes(x = `1`, y = `5`, color = ecoli)) +
  geom_point(alpha = 0.8, size = 2) +
  facet_wrap(~LLS_severity + Patients) +
  labs(title = str_replace(basename(read_in_data), "_tidy.csv", ""),
       y = "Visit 5 Normalized Value",
       x = "Visit 1 Normalized Value",
       subtitle = detection_column) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 14, face = "bold"),
    axis.title.x = element_text(size = 12),
    axis.title.y = element_text(size = 12),
    strip.text.x = element_text(size = 10),
    axis.text.x = element_text(size = 10),
    axis.text.y = element_text(size = 10),
    legend.title = element_text(size = 12)
  )

adi_plot
