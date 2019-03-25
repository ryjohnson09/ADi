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
