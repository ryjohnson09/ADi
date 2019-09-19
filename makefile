# List all targes by typing make list
.PHONY: list
list:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$' | xargs -n 1



# Process TaqMan data for visit 1 and visit 5
# Depends on:	data/raw/Taqman_results.xlsx
#		code/process_taq_adi.R
# Produces:	data/processed/Taq_tidy.csv
data/processed/Taq_tidy.csv : data/raw/Taqman_results.xlsx\
			      code/process_taq_adi.R
	R -e "source('code/process_taq_adi.R', echo=T)"



# Create Clinical Metadata Table Extracted from TrEAT DB
# Depends on:   data/raw/TrEAT_Merge_ESBL_2018.09.13_v2.XLSX
#               data/raw/TrEAT_Merge_DataDictionary_2018.06.27.XLSX
#		data/raw/Dataset_ETEC_IgA_IVTT.AG/Data/ETEC_IgA_IVTT_RawData.csv
#               code/Create_Clin_Metadata.R
#		data/processed/Taq_tidy.csv
# Produces:     data/processed/TrEAT_Clinical_Metadata_tidy.csv
data/processed/TrEAT_Clinical_Metadata_tidy.csv : data/raw/Dataset_ETEC_IgA_IVTT.AG/Data/ETEC_IgA_IVTT_RawData.csv\
                                                  data/raw/TrEAT_Merge_ESBL_2018.09.13_v2.XLSX\
                                                  data/raw/TrEAT_Merge_DataDictionary_2018.06.27.XLSX\
						  data/processed/Taq_tidy.csv\
                                                  code/Create_Clin_Metadata.R
	R -e "source('code/Create_Clin_Metadata.R', echo=T)"


# Analyze and process PURIFIED.PROTEIN data sets
# Depends on:	data/raw/Dataset_IgA_PURIFIED.PROTEIN/Data/IgA_PurifiedProtein_RawData.csv
#		data/raw/Dataset_IgG_PURIFIED.PROTEIN/Data/IgG_PurifiedProtein_RawData.csv
#		code/PURIFIED.PROTEIN_to_tidy.R
# Produces:	data/processed/IgG_PurifiedProtein_RawData_tidy.csv
#		data/processed/IgA_PurifiedProtein_RawData_tidy.csv
data/processed/IgG_PurifiedProtein_RawData_tidy.csv\
data/processed/IgA_PurifiedProtein_RawData_tidy.csv : data/raw/Dataset_IgG_PURIFIED.PROTEIN/Data/IgG_PurifiedProtein_RawData.csv\
						      data/raw/Dataset_IgA_PURIFIED.PROTEIN/Data/IgA_PurifiedProtein_RawData.csv\
						      code/PURIFIED.PROTEIN_to_tidy.R
	R -e "source('code/PURIFIED.PROTEIN_to_tidy.R', echo=T)"

# Analyze and process IVTT data sets
# Depends on:	data/raw/Dataset_ETEC_IgA_IVTT.AG/Data/ETEC_IgA_IVTT_RawData.csv
#		data/raw/Dataset_ETEC_IgG_IVTT.AG/Data/ETEC_IgG_IVTT_RawData.csv
#		data/raw/Dataset_PanEC_IgA_IVTT.AG/Data/PanEC_IgA_IVTT_RawData.csv
#		data/raw/Dataset_PanEC_IgG_IVTT.AG/Data/PanEC_IgG_IVTT_RawData.csv
#		code/IVTT_to_tidy.R
# Produces:	data/processed/ETEC_IgA_IVTT_tidy.csv
#		data/processed/ETEC_IgG_IVTT_tidy.csv
#		data/processed/PanEC_IgA_IVTT_tidy.csv
#		data/processed/PanEC_IgG_IVTT_tidy.csv
data/processed/ETEC_IgA_IVTT_tidy.csv\
data/processed/ETEC_IgG_IVTT_tidy.csv\
data/processed/PanEC_IgA_IVTT_tidy.csv\
data/processed/PanEC_IgG_IVTT_tidy.csv : data/raw/Dataset_ETEC_IgA_IVTT.AG/Data/ETEC_IgA_IVTT_RawData.csv\
			                 data/raw/Dataset_ETEC_IgG_IVTT.AG/Data/ETEC_IgG_IVTT_RawData.csv\
			                 data/raw/Dataset_PanEC_IgA_IVTT.AG/Data/PanEC_IgA_IVTT_RawData.csv\
			                 data/raw/Dataset_PanEC_IgG_IVTT.AG/Data/PanEC_IgG_IVTT_RawData.csv\
			                 code/IVTT_to_tidy.R
	R -e "source('code/IVTT_to_tidy.R', echo=T)"


# Convert raw Olink data to tidy format
# Depends on:   data/raw/20170276_Henry_M_Jackson_Foundation-Ventura_NPX_LOD_Updated_and_Revised_2.26.18.xlsx
#               code/Process_Raw_Olink.R
# Produces:     data/processed/Olink_tidy.csv
data/processed/Olink_tidy.csv : data/raw/20170276_Henry_M_Jackson_Foundation-Ventura_NPX_LOD_Updated_and_Revised_2.26.18.xlsx\
                                code/Process_Raw_Olink.R
	R -e "source('code/Process_Raw_Olink.R', echo=T)"
