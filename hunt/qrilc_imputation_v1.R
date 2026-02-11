# Load the metabolite dataset
df <- read.csv("/mnt/archive/phenotypes/hunt/2024-09-04_metabolomics_106337/HUNT3_metabolomics_adjusted_106337_pointdecimal.txt", sep = '\t')

ids <- df[, 1:2]
met <- df[, -(1:2)]  # select columns 3 onwards

# Change to numeric
met <- as.data.frame(sapply(met, as.numeric))

# Change all zeros to NAs
met <- as.data.frame(lapply(met, function(col) {
  if (is.numeric(col)) col[col == 0] <- NA
  col
}))

# Transform to make it closer to normal distribution
# (QRILC take from the normal distribution)
log_met <- log2(met)

# Get the QRILC function from https://github.com/cran/imputeLCMD/blob/master/R/impQRILC.R
# Impute the dataset
library(imputeLCMD)

imputed <- impute.QRILC(as.matrix(log_met))
imputed <- as.data.frame(imputed[[1]])

# Back-transform
imputed_back <- 2^imputed

# Transfer imputed values to the original dataset
met[is.na(met)] <- imputed_back[is.na(met)]

# Merge to ids back
imputed_full <- cbind(ids, met)

# Export the imputed dataset
write.csv(imputed_full, 'imputed_metabolomics.csv', row.names = FALSE)