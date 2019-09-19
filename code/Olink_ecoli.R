###############################################
# Title: Olink_ecoli.R
# Author: Ryan Johnson
# Date Created: 29 July 2019
# Puropse: Parse through the Olink proteins and 
#  see if EAEC specific trends emerge.
###############################################

## Libraries ------------------------------------------
library(tidyverse)
library(ggrepel)


## Read in Data ---------------------------------------
treat <- suppressWarnings(suppressMessages(read_csv("data/processed/TrEAT_Clinical_Metadata_tidy.csv")))
olink <- suppressWarnings(suppressMessages(read_csv("data/processed/Olink_tidy.csv")))

# Filter treat for only Olink patients
treat <- treat %>%
  filter(STUDY_ID %in% olink$subject_ID)

# Remove missing proteins
olink <- olink %>%
  filter(protein != "BDNF") %>% # absent
  filter(protein != "IL-1 alpha") # negative values?


## Set up Choices -------------------------------------
proteins <- unique(olink$protein)
matched <- TRUE
visits <- c("Visit_1", "Visit_4")
detection_method <- "both"
pathogen_of_interest <- "EAEC"
volcano_comparison <- "Visit_14"

column_for_grouping <- paste0(pathogen_of_interest, "_", detection_method)


## Filter Data -----------------------------------------

# Matched Samples by Visit
olink_matched <-
  if(matched){
    matched_subjects <- olink %>% 
      select(subject_ID, visit) %>% 
      filter(visit %in% visits) %>% 
      unique() %>% 
      group_by(subject_ID) %>% 
      filter(n() == length(visits)) %>% 
      pull(subject_ID) %>% 
      unique()
    
    olink %>% 
      filter(visit %in% visits) %>% 
      filter(subject_ID %in% matched_subjects) %>% 
      filter(protein %in% proteins)

  } else if(!matched){
    olink %>%
      filter(visit %in% visits) %>% 
      filter(protein %in% proteins)
  } else {
    stop("Error in filtering for matched patients")
  }


## Calculate Change ------------------------------------

# Determine change from visit 1 to visit 4/5
# olink_matched_change <- 
#   if(all(c("Visit_1", "Visit_4", "Visit_5") %in% visits)){
#     olink_matched %>% 
#       spread(visit, olink_value) %>% 
#       mutate(Visit_14 = Visit_4 - Visit_1) %>% 
#       mutate(Visit_15 = Visit_5 - Visit_1) %>%
#       mutate(Visit_45 = Visit_5 - Visit_4)
#   } else if(all(c("Visit_1", "Visit_5") %in% visits)){
#     olink_matched %>% 
#       spread(visit, olink_value) %>% 
#       mutate(Visit_15 = Visit_5 - Visit_1)
#   } else if(all(c("Visit_1", "Visit_4") %in% visits)){
#     olink_matched %>% 
#       spread(visit, olink_value) %>% 
#       mutate(Visit_14 = Visit_4 - Visit_1)
#   } else {
#     stop("Error when calculating change in signal value")
#   }


## Add in TrEAT DB ------------------------------------

# Merge in treat
olink_treat <- olink_matched %>% 
  left_join(., treat, by = c("subject_ID" = "STUDY_ID"))

# Filter for columns of interest
olink_treat_select <- olink_treat %>% 
  select(colnames((olink_matched)), column_for_grouping) %>% 
  filter(!is.na(!!as.name(column_for_grouping)))

my_categories <- unique(olink_treat_select[[column_for_grouping]])


## Create stats for volcano plot ----------------------
olink_stat <- olink_treat_select %>%
  group_by(!!as.name(column_for_grouping), protein, visit) %>%
  summarise(values = list(olink_value)) %>%
  spread(visit, values) %>% 
  ungroup()

# Compute Statistics 
olink_stat_full <- olink_stat %>%
  
  group_by(protein, !!as.name(column_for_grouping)) %>% 
  
  # Counts
  mutate(count.1 = length(unlist(!!as.name(visits[1])))) %>%
  mutate(count.2 = length(unlist(!!as.name(visits[2])))) %>%
  
  # Mean
  mutate(!!paste0("mean_", visits[1]) := mean(unlist(!!as.name(visits[1])))) %>%
  mutate(!!paste0("mean_", visits[2]) := mean(unlist(!!as.name(visits[2])))) %>%
  mutate(mean_diff = !!as.name(paste0("mean_", visits[2])) - 
                     !!as.name(paste0("mean_", visits[1]))) %>%
  
  # St Dev
  mutate(!!paste0("sd_", visits[1]) := sd(unlist(!!as.name(visits[1])))) %>%
  mutate(!!paste0("sd_", visits[2]) := sd(unlist(!!as.name(visits[2])))) %>%
  
  # Filter out any proteins with minimal change from visit 1 to visit 4/5
  filter(mean_diff  != 0) %>% 
  
  # Filter out any values with negative means
  filter(!!paste0("mean_", visits[1]) > 0) %>% 
  filter(!!paste0("mean_", visits[2]) > 0) %>%
  
  # T test
  mutate(p_value = t.test(unlist(!!as.name(visits[1])), unlist(!!as.name(visits[2])))$p.value)


## Plot -----------------------------------

# Get top reactive proteins
top_prots <- olink_stat_full %>% 
  filter(p_value < 0.05) %>% 
  arrange(p_value) %>% 
  #arrange(desc(mean_diff)) %>% 
  head()

# Plot (volcano)
olink_data_plot_volcano <- ggplot(data = olink_stat_full, aes(x = mean_diff, y = -log(p_value))) +
  geom_point(aes(color = !!as.name(column_for_grouping), size = 3, alpha = 0.7)) +
  geom_label_repel(aes(label = protein), data = top_prots) +
  geom_hline(yintercept = -log(0.05)) +
  geom_hline(yintercept = -log(0.1), linetype = "dashed") +
  ylab("-log(p_value)") +
  xlab("Mean Difference") +
  labs(subtitle = paste0(pathogen_of_interest, " - ", detection_method)) +
  # ggtitle(str_replace(basename(read_in_data), "_tidy.csv", "")) +
  theme(
    axis.title.x = element_text(size = 12),
    axis.title.y = element_text(size = 12),
    axis.text.x = element_text(size = 10),
    axis.text.y = element_text(size = 10)
  )

olink_data_plot_volcano







#############################################
## Mean values at visit 1 EAEC pos vs neg ------------

olink_stat_v1 <- olink_stat %>% 
  select(-Visit_5) %>% 
  group_by(protein) %>% 
  spread(EAEC_both, Visit_1) %>% 
  mutate(yes_mean = mean(unlist(yes))) %>% 
  mutate(no_mean = mean(unlist(no))) %>% 
  mutate(mean_diff = yes_mean - no_mean) %>% 
  
  # St Dev
  mutate(yes_sd = sd(unlist(yes))) %>%
  mutate(no_sd = sd(unlist(no))) %>%
  
  # Filter out any proteins with minimal change from visit 1 to visit 4/5
  filter(mean_diff  != 0) %>% 
  
  # Filter out any values with negative means
  filter(yes_mean > 0) %>% 
  filter(no_mean > 0) %>%
  
  # T test
  mutate(p_value = t.test(unlist(yes), unlist(no))$p.value)
  


# Plot V1 (bar)

olink_V1_plot_bar <- olink_stat_v1 %>% 
  select(-yes, -no, -mean_diff) %>% 
  group_by(protein) %>%
  gather(mean_type, means, -yes_sd, -no_sd, -p_value, -protein) %>% 
  filter(p_value < 0.05) %>% 
  ggplot(aes(x = protein, y = means, fill = mean_type)) +
  geom_bar(stat = "identity", position = position_dodge()) +
  scale_fill_discrete(name="Colonization\nStatus",
                      breaks=c("yes_mean", "no_mean"),
                      labels=c("Positive", "Negative")) +
  labs(title = "Visit1: EAEC Positive vs Negative",
       subtitle = "Proteins t-test p<0.05 shown",
       x = "Protein", 
       y = "Mean Visit 1 Value") +
  theme(
    plot.title = element_text(size = 18, face = "bold"),
    axis.title.x = element_text(size = 15),
    axis.title.y = element_text(size = 15),
    axis.text.x = element_text(size = 13),
    axis.text.y = element_text(size = 13)
  )

olink_V1_plot_bar




## Mean values at visit 5 EAEC pos vs neg ------------

olink_stat_v5 <- olink_stat %>% 
  select(-Visit_1) %>% 
  group_by(protein) %>% 
  spread(EAEC_both, Visit_5) %>% 
  mutate(yes_mean = mean(unlist(yes))) %>% 
  mutate(no_mean = mean(unlist(no))) %>% 
  mutate(mean_diff = yes_mean - no_mean) %>% 
  
  # St Dev
  mutate(yes_sd = sd(unlist(yes))) %>%
  mutate(no_sd = sd(unlist(no))) %>%
  
  # Filter out any proteins with minimal change from visit 1 to visit 4/5
  filter(mean_diff  != 0) %>% 
  
  # Filter out any values with negative means
  filter(yes_mean > 0) %>% 
  filter(no_mean > 0) %>%
  
  # T test
  mutate(p_value = t.test(unlist(yes), unlist(no))$p.value)



# Plot V5 (bar)

olink_V5_plot_bar <- olink_stat_v5 %>% 
  select(-yes, -no, -mean_diff) %>% 
  group_by(protein) %>%
  gather(mean_type, means, -yes_sd, -no_sd, -p_value, -protein) %>% 
  filter(p_value < 0.05) %>% 
  ggplot(aes(x = protein, y = means, fill = mean_type)) +
  geom_bar(stat = "identity", position = position_dodge())

olink_V5_plot_bar




## Mean values at visit 4 EAEC pos vs neg ------------

olink_stat_v4 <- olink_stat %>% 
  select(-Visit_1) %>% 
  group_by(protein) %>% 
  spread(EAEC_both, Visit_4) %>% 
  mutate(yes_mean = mean(unlist(yes))) %>% 
  mutate(no_mean = mean(unlist(no))) %>% 
  mutate(mean_diff = yes_mean - no_mean) %>% 
  
  # St Dev
  mutate(yes_sd = sd(unlist(yes))) %>%
  mutate(no_sd = sd(unlist(no))) %>%
  
  # Filter out any proteins with minimal change from visit 1 to visit 4/5
  filter(mean_diff  != 0) %>% 
  
  # Filter out any values with negative means
  filter(yes_mean > 0) %>% 
  filter(no_mean > 0) %>%
  
  # T test
  mutate(p_value = t.test(unlist(yes), unlist(no))$p.value)



# Plot V4 (bar)
olink_V4_plot_bar <- olink_stat_v4 %>% 
  select(-yes, -no, -mean_diff) %>% 
  group_by(protein) %>%
  gather(mean_type, means, -yes_sd, -no_sd, -p_value, -protein) %>% 
  filter(p_value < 0.05) %>% 
  ggplot(aes(x = protein, y = means, fill = mean_type)) +
  geom_bar(stat = "identity", position = position_dodge()) +
  scale_fill_discrete(name="Colonization\nStatus",
                      breaks=c("yes_mean", "no_mean"),
                      labels=c("Positive", "Negative")) +
  labs(title = "Visit4: EAEC Positive vs Negative",
       subtitle = "Proteins t-test p<0.05 shown",
       x = "Protein", 
       y = "Mean Visit 4 Value") +
  theme(
    plot.title = element_text(size = 18, face = "bold"),
    axis.title.x = element_text(size = 15),
    axis.title.y = element_text(size = 15),
    axis.text.x = element_text(size = 13),
    axis.text.y = element_text(size = 13)
  )

olink_V4_plot_bar

