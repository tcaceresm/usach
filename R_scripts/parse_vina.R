library(dplyr)

# Summary files path
summary_files_path <- '~/Escritorio/tcaceres/docking/correlacion/to_docking/vina_out_hinakiflavone/summary/'
summary_files <- list.files(summary_files_path)


df <- as.data.frame(matrix(nrow=142, ncol=2))
colnames(df) <- c('PubChemCID_protomer', 'kcal/mol')
for (i in 1:length(summary_files)) {
  energy <- read.csv(paste0(summary_files_path,summary_files[i]), header = F)
  df[i,] <- c(summary_files[i], energy)
}

split_column <- strsplit(as.character(df$PubChemCID_protomer), "_")
split_elements <- sapply(split_column, "[", 1)

df$PubChemCID <- sapply(split_column, "[", 1)
df$Protomer <- sapply(split_column, "[", 2)

df <- df[, 2:4]
