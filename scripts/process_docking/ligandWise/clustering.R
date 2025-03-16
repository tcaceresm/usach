# Libraries ---------------------------------------------------------------

library(ChemmineR)
library(dplyr)


# Functions ---------------------------------------------------------------
process_data <- function(rmsd_df_path, scores_path) {
  
  rmsd_df <- read.csv(rmsd_df_path, header = F)
  #rmsd_df <- rmsd_df[, 2:ncol(rmsd_df)]
  rmsd_df <- cbind(data.frame(index=seq(nrow(rmsd_df))), rmsd_df)
  scores <- read.csv(scores_path, header = F, sep = ";")
  rmsd_df <- cbind(scores, rmsd_df)
  colnames(rmsd_df) <- c("Energia", "Run", "Nombre", "Index", seq(nrow(rmsd_df)))
  rmsd_matrix <- as.matrix(rmsd_df[, 5:ncol(rmsd_df)])
  return (list(rmsd_df, rmsd_matrix))
}


cluster_docking <- function(rmsd_matrix, cutoff = 2.0) {
  
  clusters <- list()  # Lista para guardar los clusters
  
  # Iterar sobre las conformaciones ordenadas
  for (i in 1:(nrow(rmsd_matrix))) {
    
    rmsd_conformacion <- as.numeric(rmsd_matrix[i])
    
    added <- FALSE # Ya es parte del cluster?

    # Iterar sobre los clusters
    for (k in seq_along(clusters)) {

      cluster <- clusters[[k]] 
      
      # Comparar solo con la primera conformación del cluster (la semilla)
      seed <- cluster[1]
      
      rmsd <- rmsd_matrix[i, cluster[1]]

        if (rmsd <= cutoff) {
        clusters[[k]] <- c(cluster, i)
        added <- TRUE
        break
      }
    }
    
    if (!added) {
      # Si no se puede añadir a ningún cluster existente, crear uno nuevo
      clusters <- append(clusters, list(i))
    }
  }
  
  return(clusters)
}



write_sdf_clusters <- function(rmsd_df, sdf_path, clusters, output_path, ligand_name, cutoff){
  
  sdf_file <- ChemmineR::read.SDFset(sdf_path)

  
  # if cluster lenght is only 1, i'll consider as "outliers"
  outliers <- NULL
  
  for (cluster_index in seq_along(clusters)) {
    
    cluster <- clusters[[cluster_index]]
    
    if (length(cluster) > 1) {

      statistics <- rmsd_df %>% 
        filter(as.integer(Index) %in% cluster) %>% 
        summarise(N=n(),
                  meanEnergy=mean(Energia),
                  minEnergy=min(Energia),
                  sdEnergy=sd(Energia)) %>% round(., 3)
      write.csv(statistics, '~/Desktop/borrar.csv', row.names = F)
      
      write.SDF(sdf_file[clusters[[cluster_index]]],
                file = sprintf('%s/%s_cutoff=%s_cluster%s_size=%s_mean=%s_min=%s_std=%s.sdf',
                               output_path,ligand_name,cutoff,cluster_index,statistics$N,statistics$meanEnergy,statistics$minEnergy,statistics$sdEnergy
                              )   
                )

    } else {
      outliers <- append(outliers, cluster)
      
    }
  }
  if (length(outliers) != 0) {
    statistics <- rmsd_df %>% 
      filter(as.integer(Index) %in% outliers) %>% 
      summarise(N=n(),
                meanEnergy=mean(Energia),
                minEnergy=min(Energia),
                sdEnergy=sd(Energia)) %>% round(., 3)
    
    
    write.SDF(sdf_file[outliers],
              file = sprintf('%s/%s_cutoff=%s_outliers_size=%s_mean=%s_min=%s_std=%s.sdf',
                             output_path,ligand_name,cutoff,statistics$N,statistics$meanEnergy,statistics$minEnergy, statistics$sdEnergy
              )
    )
    
  }

}

## End of functions ##


# Rscript -----------------------------------------------------------------
# Arguments should be Ligand_RMSD_matrix.data path, docking scores (sorted) and a cutoff value
args <- commandArgs()

rmsd_df_path <- args[6]
docking_scores <- args[7]
cutoff <- as.numeric(args[8])
sdf_path <- args[9]
output_path <- args[10]
ligand_name <- args[11]

# Run Clustering ----------------------------------------------------------
# processed_data[1] rmsd_df and processed_data[2] rmsd_matrix
processed_data <- process_data(rmsd_df_path = rmsd_df_path, scores_path = docking_scores)

clusters <- cluster_docking(rmsd_matrix = processed_data[[2]], cutoff = cutoff)

write_sdf_clusters(rmsd_df = processed_data[[1]], 
                   sdf_path = sdf_path,
                   clusters = clusters,
                   output_path = output_path,
                   ligand_name = ligand_name,
                   cutoff = cutoff)
                   
print("Done clustering!")
