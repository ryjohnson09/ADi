#####################################################
# Name: EAEC_linear_plot_PanEC_IgA_v15.R
# Author: Ryan Johnson
# Date Created: 9 September 2018
# Purpose: Visulize the normalized spot signals from
#  acute to convalescent using the PanEC_IgA data
#####################################################

## Libraries -----------------------------------------------------

library(tidyverse)
library(plotly)

## Read in Data --------------------------------------------------

PanEC_IgA <- read_csv("data/processed/PanEC_IgA_IVTT_RawData_tidy.csv")


## Reformat Data ------------------------------------------------------

PanEC_IgA_spread <- PanEC_IgA %>%
  
  # Select for ONLY EAEC infected patients
  filter(EAEC_both == "yes") %>%
  
  # Extract columns of interest
  select(ID, Description, Patients, visit, norm_value) %>%
  
  # Merge the ID and Description columns
  unite(col = "ID_Description", sep = "_", c("ID", "Description")) %>%
  
  # Spread so that norm_values are split by visit
  spread(visit, norm_value)

## Split Data ----------------------------------------------------------
one_v_four <- PanEC_IgA_spread %>%
  select(-`5`) %>%
  filter(!is.na(`4`)) %>%
  mutate(mean_diff = abs(`1` - `4`)) %>%
  group_by(ID_Description) %>%
  mutate(mean_diff = abs(mean(`1`) - mean(`4`))) %>%
  arrange(desc(mean_diff))

one_v_five <- PanEC_IgA_spread %>%
  select(-`4`) %>%
  filter(!is.na(`5`)) %>%
  group_by(ID_Description) %>%
  mutate(mean_diff = abs(mean(`1`) - mean(`5`))) %>%
  arrange(desc(mean_diff))

## Plot Visit 1 vs 5 ---------------------------------------------------

top_num_mean_diff <- unique(one_v_five$ID_Description)[1:5]

pick <- function(condition){
  function(d) d %>% filter_(condition)
}

PanEC_IgA_plot <- ggplot(data = one_v_five, aes(x = `1`, y = `5`)) +
  #geom_smooth(method = "lm") +
  geom_point(alpha = 0.6, size = 2) +
  geom_point(data = pick(~ID_Description %in% top_num_mean_diff), 
             aes(color = factor(ID_Description, levels = top_num_mean_diff))) +
  facet_wrap(~Patients) +
  labs(title = "PanEC IgA - EAEC Infected Patients: Visit 1 vs Visit 5",
       y = "Visit 5 Normalized Value",
       x = "Visit 1 Normalized Value",
       color = "Top 5 Points with largest mean\nchange from visit 1 to visit 5",
       subtitle = "Taq + Culture used to determine EAEC presence") +
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

PanEC_IgA_plot

## Save Plots -----------------------------------------------------------
ggsave(plot = PanEC_IgA_plot, "results/figures/EAEC_linear_PanEC_IgA_v15.png", width = 14, height = 8)
