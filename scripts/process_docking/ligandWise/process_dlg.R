
# Idea --------------------------------------------------------------------

# El output de AD4 en conjunto con mk_export.py es un sdf con todas las poses.
#  1) Quiero ordenarlas desde la más afín a la menos afín (- --> +)
#  2) Obtener puntajes de cada pose

#  Args
#   1) SDF file
#  Output
#   2) Sorted SDF file
#   3) Docking scores

# Libraries ---------------------------------------------------------------

suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(ChemmineR))
suppressPackageStartupMessages(library(jsonlite))


# Arguments ---------------------------------------------------------------

args <- commandArgs()
ligand_sdf <- args[6]
output_path <- args[7]

ligand_name <- gsub("\\.sdf$", "", ligand_sdf)
ligand_name <- basename(ligand_name)

# Data --------------------------------------------------------------------

docking_output <- read.SDFset(sdfstr = ligand_sdf)

# sdfset[[1]] is the first molecule. The next indexing refers to data asociated
# to this molecule. Docking data is in 4th index in json format

# Processing --------------------------------------------------------------


free_energies <- data.frame(Pose=numeric(),
                            FreeEnergy=numeric())

for (pose in 1:length(docking_output)) {
  
  json_data <- fromJSON(docking_output[[pose]][[4]])
  free_energy <- json_data$free_energy
  free_energies[pose,] <- c(pose, free_energy)

}

sorted_docking_output <- free_energies[order(free_energies$FreeEnergy), ]

write.SDF(docking_output[sorted_docking_output$Pose],
          file = sprintf('%s/%s_sorted.sdf', output_path, ligand_name))
write.csv(x = sorted_docking_output,
          file = sprintf('%s/%s_docking_scores_sorted.csv', output_path, ligand_name),
          row.names = F)