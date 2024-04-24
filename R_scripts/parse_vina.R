#################################################################################
# Script utilizado para procesar el output de vina. Cada archivo (en la carpeta #
# summary) tiene el nombre del PubChemCID y el N° del protomero (PubChemCID_pro-#
# tomer)                                                                        #
# Y el archivo contiene la energía de la mejor pose.                            #
#################################################################################

# Librerías ---------------------------------------------------------------


library(dplyr)


# Datos -------------------------------------------------------------------
# Summary files path
# Hinokiflavone
summary_files_path <- '~/Escritorio/tcaceres/docking/correlacion/to_docking/vina_out_hinakiflavone/summary/'
summary_files <- list.files(summary_files_path)


df_summaries <- as.data.frame(matrix(nrow=142, ncol=2))
colnames(df_summaries) <- c('PubChemCID_protomer', 'kcal/mol')

for (i in 1:length(summary_files)) {
  energy <- read.csv(paste0(summary_files_path,summary_files[i]), header = F)
  df_summaries[i,] <- c(summary_files[i], energy)
}


# Separación del PubChemCID y el n° protomero -----------------------------


split_column <- strsplit(as.character(df_summaries$PubChemCID_protomer), "_")
split_elements <- sapply(split_column, "[", 1)

# split column es una lista, donde cada componente es el PubChemCID y el N° protomero
# Al realizar lo siguiente, estamos obteniendo el PubChemCID por si solo y luego
# el numero de protomero por si solo.
df_summaries$PubChemCID <- sapply(split_column, "[", 1)
df_summaries$Protomer <- sapply(split_column, "[", 2)

# Ahora hago un drop de la primera columna, o me quedo con las columas 2-4
df_summaries <- df_summaries[, 2:4]

colnames(df_summaries) <- c('kcal/mol', 'PubChemCID', 'N_protomer')

df_summaries$PubChemCID <- as.integer(df_summaries$PubChemCID)
df_summaries$N_protomer <- as.integer(df_summaries$N_protomer)
# Unión de los datos de energía al DF original ----------------------------


hinokiflavone <- read.csv('~/Escritorio/tcaceres/docking/hinokiflavone_enumerate_processed.txt')

merged_df <- left_join(hinokiflavone, df_summaries, by=c('PubChemCID', 'N_protomer'))
