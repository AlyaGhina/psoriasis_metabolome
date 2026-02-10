#Tutorial: https://cran.r-project.org/web/packages/ukbnmr/vignettes/ukbnmr.html#:~:text=library(ukbnmr)%20library(data,sample_qc_flags%20%3C%2D%20extract_sample_qc_flags(exported)

# On terminal
#dx download "exported_121225.csv"

# Install ukbnmr package
remotes::install_github("sritchie73/ukbnmr", dependencies = TRUE, build_vignettes = TRUE)

# Get command line arguments
args <- commandArgs(trailingOnly = TRUE)
input_file <- args[1]

# Load the package
library(ukbnmr)
library(data.table)
library(dplyr)

# Load the dataset
exported <- fread(input_file)

# Remove technical variation
processed <- remove_technical_variation(exported)

# Saving results
fwrite(processed$biomarkers, file="nmr_biomarker_data_full.csv")
fwrite(processed$biomarker_qc_flags, file="nmr_biomarker_qc_flags_full.csv")
fwrite(processed$sample_processing, file="nmr_sample_qc_flags_full.csv")
fwrite(processed$log_offset, file="nmr_biomarker_log_offset_full.csv")
fwrite(processed$outlier_plate_detection, file="outlier_plate_info_full.csv")

# Slice to select only non-derived biomarkers
nmr_info_df <- as.data.frame(nmr_info) # Getting the nmr_info from ukbnmr package
non_derived_biomarker <- nmr_info_df$Biomarker[nmr_info_df$Type == "Non-derived"] #Create a list of non-derived biomarkers

cols_to_extract <- c("eid", non_derived_biomarker)

non_derived_biomarker_df <- processed$biomarkers %>% select(all_of(cols_to_extract))
non_derived_biomarker_qc_flags_df <- processed$biomarker_qc_flags %>% select(all_of(cols_to_extract))

fwrite(non_derived_biomarker_df, file="nmr_biomarker_data_nonderived.csv")
fwrite(non_derived_biomarker_qc_flags_df, file="nmr_biomarker_qc_flags_nonderived.csv")

cat("R script for removing technical variations finished.")

# On terminal
#dx upload "nmr_biomarker_data_full.csv" "nmr_biomarker_qc_flags_full.csv" "nmr_sample_qc_flags_full.csv" "nmr_biomarker_log_offset_full.csv" "outlier_plate_info_full.csv"