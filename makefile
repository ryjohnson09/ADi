###############################################
#### List all targes by typing `make list` ####
###############################################

.PHONY: list
list:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$' | xargs -n 1





########################
#### Tidy Data Sets ####
########################


# Create Clinical Metadata Table Extracted from TrEAT DB
# Depends on:	data/raw/TrEAT_Merge_2018.06.27.XLSX
#               data/raw/TrEAT_Merge_DataDictionary_2018.06.27.XLSX
#               code/Create_Clin_Metadata.R
# Produces:     data/processed/TrEAT_Clinical_Metadata_tidy.csv
data/processed/TrEAT_Clinical_Metadata_tidy.csv : data/raw/TrEAT_Merge_2018.06.27.XLSX\
                                                  data/raw/TrEAT_Merge_DataDictionary_2018.06.27.XLSX\
                                                  code/Create_Clin_Metadata.R
	R -e "source('code/Create_Clin_Metadata.R', echo=T)"


# Normalizes the ETEC_IgG_IVTT ADi data and exports in tidy format
# Depends on:	data/raw/Dataset_ETEC_IgG_IVTT.AG/Data/ETEC_IgG_IVTT_RawData.csv
#		data/processed/TrEAT_Clinical_Metadata_tidy.csv
#		code/IVTT_to_tidy.R
# Produces:	data/processed/ETEC_IgG_IVTT_RawData_tidy.csv
data/processed/ETEC_IgG_IVTT_RawData_tidy.csv : data/raw/Dataset_ETEC_IgG_IVTT.AG/Data/ETEC_IgG_IVTT_RawData.csv\
						data/processed/TrEAT_Clinical_Metadata_tidy.csv\
						code/IVTT_to_tidy.R
	R -e "source('code/IVTT_to_tidy.R', echo=T); IVTT_to_tidy('data/raw/Dataset_ETEC_IgG_IVTT.AG/Data/ETEC_IgG_IVTT_RawData.csv')"


# Normalizes the ETEC_IgA_IVTT ADi data and exports in tidy format
# Depends on:   data/raw/Dataset_ETEC_IgA_IVTT.AG/Data/ETEC_IgA_IVTT_RawData.csv
#		data/processed/TrEAT_Clinical_Metadata_tidy.csv
#               code/IVTT_to_tidy.R
# Produces:     data/processed/ETEC_IgA_IVTT_RawData_tidy.csv
data/processed/ETEC_IgA_IVTT_RawData_tidy.csv : data/raw/Dataset_ETEC_IgA_IVTT.AG/Data/ETEC_IgA_IVTT_RawData.csv\
						data/processed/TrEAT_Clinical_Metadata_tidy.csv\
                                                code/IVTT_to_tidy.R
	R -e "source('code/IVTT_to_tidy.R', echo=T); IVTT_to_tidy('data/raw/Dataset_ETEC_IgA_IVTT.AG/Data/ETEC_IgA_IVTT_RawData.csv')"


# Normalizes the PanEC_IgA_IVTT ADi data and exports in tidy format
# Depends on:   data/raw/Dataset_PanEC_IgA_IVTT.AG/Data/PanEC_IgA_IVTT_RawData.csv
#               data/processed/TrEAT_Clinical_Metadata_tidy.csv
#               code/IVTT_to_tidy.R
# Produces:     data/processed/PanEC_IgA_IVTT_RawData_tidy.csv
data/processed/PanEC_IgA_IVTT_RawData_tidy.csv : data/raw/Dataset_PanEC_IgA_IVTT.AG/Data/PanEC_IgA_IVTT_RawData.csv\
                                                 data/processed/TrEAT_Clinical_Metadata_tidy.csv\
                                                 code/IVTT_to_tidy.R
	R -e "source('code/IVTT_to_tidy.R', echo=T); IVTT_to_tidy('data/raw/Dataset_PanEC_IgA_IVTT.AG/Data/PanEC_IgA_IVTT_RawData.csv')"


# Normalizes the PanEC_IgG_IVTT ADi data and exports in tidy format
# Depends on:   data/raw/Dataset_PanEC_IgG_IVTT.AG/Data/PanEC_IgG_IVTT_RawData.csv
#               data/processed/TrEAT_Clinical_Metadata_tidy.csv
#               code/IVTT_to_tidy.R
# Produces:     data/processed/PanEC_IgG_IVTT_RawData_tidy.csv
data/processed/PanEC_IgG_IVTT_RawData_tidy.csv : data/raw/Dataset_PanEC_IgG_IVTT.AG/Data/PanEC_IgG_IVTT_RawData.csv\
                                                 data/processed/TrEAT_Clinical_Metadata_tidy.csv\
                                                 code/IVTT_to_tidy.R
	R -e "source('code/IVTT_to_tidy.R', echo=T); IVTT_to_tidy('data/raw/Dataset_PanEC_IgG_IVTT.AG/Data/PanEC_IgG_IVTT_RawData.csv')"


# Normalizes the IgG_PURIFIED.PROTEIN ADi data and exports in tidy format
# Depends on:   data/raw/Dataset_IgG_PURIFIED.PROTEIN/Data/IgG_PurifiedProtein_RawData.csv
#               data/processed/TrEAT_Clinical_Metadata_tidy.csv
#               code/PURIFIED.PROTEIN_to_tidy.R
# Produces:     data/processed/IgG_PurifiedProtein_RawData_tidy.csv
data/processed/IgG_PurifiedProtein_RawData_tidy.csv : data/raw/Dataset_IgG_PURIFIED.PROTEIN/Data/IgG_PurifiedProtein_RawData.csv\
                                                      data/processed/TrEAT_Clinical_Metadata_tidy.csv\
                                                      code/PURIFIED.PROTEIN_to_tidy.R
	R -e "source('code/PURIFIED.PROTEIN_to_tidy.R', echo=T); PURIFIED.PROTEIN_to_tidy('data/raw/Dataset_IgG_PURIFIED.PROTEIN/Data/IgG_PurifiedProtein_RawData.csv')"


# Normalizes the IgA_PURIFIED.PROTEIN ADi data and exports in tidy format
# Depends on:   data/raw/Dataset_IgA_PURIFIED.PROTEIN/Data/IgA_PurifiedProtein_RawData.csv
#               data/processed/TrEAT_Clinical_Metadata_tidy.csv
#               code/PURIFIED.PROTEIN_to_tidy.R
# Produces:     data/processed/IgA_PurifiedProtein_RawData_tidy.csv
data/processed/IgA_PurifiedProtein_RawData_tidy.csv : data/raw/Dataset_IgA_PURIFIED.PROTEIN/Data/IgA_PurifiedProtein_RawData.csv\
                                                      data/processed/TrEAT_Clinical_Metadata_tidy.csv\
                                                      code/PURIFIED.PROTEIN_to_tidy.R
	R -e "source('code/PURIFIED.PROTEIN_to_tidy.R', echo=T); PURIFIED.PROTEIN_to_tidy('data/raw/Dataset_IgA_PURIFIED.PROTEIN/Data/IgA_PurifiedProtein_RawData.csv')"







####################
### Linear Plots ###
####################

# Create EAEC_linear_plot_PanEC_IgG_v15.png
# Depends on:	data/processed/PanEC_IgG_IVTT_RawData_tidy.csv
#		code/EAEC_linear_plot_PanEC_IgG_v15.R
# Produces:	results/figures/EAEC_linear_PanEC_IgG_v15.png
results/figures/EAEC_linear_PanEC_IgG_v15.png : data/processed/PanEC_IgG_IVTT_RawData_tidy.csv\
						code/EAEC_linear_plot_PanEC_IgG_v15.R
	R -e "source('code/EAEC_linear_plot_PanEC_IgG_v15.R', echo=T)"

# Create EAEC_linear_plot_PanEC_IgA_v15.png
# Depends on:   data/processed/PanEC_IgG_IVTT_RawData_tidy.csv
#               code/EAEC_linear_plot_PanEC_IgA_v15.R
# Produces:     results/figures/EAEC_linear_PanEC_IgA_v15.png
results/figures/EAEC_linear_PanEC_IgA_v15.png : data/processed/PanEC_IgA_IVTT_RawData_tidy.csv\
                                                code/EAEC_linear_plot_PanEC_IgA_v15.R
	R -e "source('code/EAEC_linear_plot_PanEC_IgA_v15.R', echo=T)"

# Create EAEC_linear_plot_PanEC_IgG_v15_culture.png
# Depends on:   data/processed/PanEC_IgG_IVTT_RawData_tidy.csv
#               code/EAEC_linear_plot_PanEC_IgG_v15_culture.R
# Produces:     results/figures/EAEC_linear_PanEC_IgG_v15_culture.png
results/figures/EAEC_linear_PanEC_IgG_v15_culture.png : data/processed/PanEC_IgG_IVTT_RawData_tidy.csv\
                                                	code/EAEC_linear_plot_PanEC_IgG_v15_culture.R
	R -e "source('code/EAEC_linear_plot_PanEC_IgG_v15_culture.R', echo=T)"

# Create EAEC_linear_plot_PanEC_IgA_v15_culture.png
# Depends on:   data/processed/PanEC_IgA_IVTT_RawData_tidy.csv
#               code/EAEC_linear_plot_PanEC_IgA_v15_culture.R
# Produces:     results/figures/EAEC_linear_PanEC_IgA_v15_culture.png
results/figures/EAEC_linear_PanEC_IgA_v15_culture.png : data/processed/PanEC_IgA_IVTT_RawData_tidy.csv\
                                                        code/EAEC_linear_plot_PanEC_IgA_v15_culture.R
	R -e "source('code/EAEC_linear_plot_PanEC_IgA_v15_culture.R', echo=T)"
