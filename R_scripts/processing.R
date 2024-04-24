# Information -------------------------------------------------------------

# Script used to obtain smiles from PubChemCID.


# Libraries ---------------------------------------------------------------

#library(webchem)
library(dplyr)
library(PubChemR)
library(ChemmineR)
library(Rcpi)

# Funcion -----------------------------------------------------------------

get_smiles <- function(CIDs){
  compound_data <- PubChemR::get_compounds(CIDs)
  smiles <- NULL
  for (i in 1:length(compound_data)) {
    if (is.character(compound_data[[i]][[1]]$props[[20]]$value)) {
      smiles[i] <- compound_data[[i]][[1]]$props[[20]]$value
    }else{
      smiles[i] <- compound_data[[i]][[1]]$props[[19]]$value
    }
  } 
  return(smiles)
}
# Data --------------------------------------------------------------------
data_path <- '~/Escritorio/tcaceres/docking/correlacion/to_docking/'
hinokiflavone <- read.csv(paste0(data_path, 'hinokiflavone.csv'), sep = ';')
quercetin <- read.csv(paste0(data_path, 'quercetin.csv'), sep = ';')

colnames(hinokiflavone) <- c('CompoundName', 'PubChemCID', 'Relative_Inhibition_Rate')
colnames(quercetin) <- c('CompoundName', 'PubChemCID', 'Relative_Inhibition_Rate', 'STD_deviation', 'MIC(ug/mL)')

quercetin[quercetin == '-'] <-  NA


# PubChemCID to SMILES ----------------------------------------------------

hinokiflavone$SMILES <- get_smiles(hinokiflavone$PubChemCID)
quercetin$SMILES <- get_smiles(quercetin$PubChemCID)


# Save Data ---------------------------------------------------------------

write.csv(hinokiflavone, '~/Escritorio/tcaceres/docking/correlacion/to_docking/hinokiflavone_smiles.csv', row.names = F)
write.csv(quercetin, '~/Escritorio/tcaceres/docking/correlacion/to_docking/quercetin_smiles.csv', row.names = F)

#ahora que tengo los smiles, en MOE calculo el estado de protonación (enumerate),
# y genero los archivos hinokiflavone2dock.sdf y quercetin2dock.sdf
# esos archivos .sdf no los toco
# Ahora, guardo el archivo enumerate tambien como .csv, para obtener
# el pubchemcid y el n° protomero.


# Obtención de vector con PubChemCID y n° protomero -----------------------

hinokiflavone_enumerate <- read.csv('../hinokiflavone_enumerate.txt')
hinokiflavone_enumerate <- data.table::data.table(hinokiflavone_enumerate)
hinokiflavone_enumerate <- hinokiflavone_enumerate[, N_protomer := sequence(.N), by = c("PubChemCID")]
hinokiflavone_CID_protomer <- paste0(hinokiflavone_enumerate$PubChemCID, '_', hinokiflavone_enumerate$N_protomer)
write.csv(hinokiflavone_enumerate, '../hinokiflavone_enumerate_processed.txt', row.names = F)

quercetin_enumerate <- read.csv('~/Escritorio/tcaceres/docking/quercetin_enumerate.txt')
quercetin_enumerate <- data.table::data.table(quercetin_enumerate)
quercetin_enumerate <- quercetin_enumerate[, N_protomer := sequence(.N), by = c("PubChemCID")]
quercetin_CID_protomer <- paste0(quercetin_enumerate$PubChemCID, '_', quercetin_enumerate$N_protomer)
write.csv(quercetin_enumerate, '~/Escritorio/tcaceres/docking/quercetine_enumerate_processed.txt', row.names = F)

# SDF modification --------------------------------------------------------

# Spliteo los archivos, para tener un archivo sdf por cada ligando y protomero
sdf_data <- ChemmineR::read.SDFset('/home/tcaceres/Documents/USACH/experimental_data/to_docking/quercetin2dock.sdf')
ChemmineR::write.SDFsplit(x=sdf_data, filetag = 'Ligand', nmol=1) 
# 'nmol' defines the number of molecules to write to each file 

setwd('/home/tcaceres/Documents/USACH/experimental_data/to_docking/quercetin/')
file.rename(list.files('./'), to=sprintf('%s.sdf', quercetin_CID_protomer))
