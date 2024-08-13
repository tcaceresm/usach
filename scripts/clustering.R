
# Libraries ---------------------------------------------------------------

library(ChemmineR)
library(dplyr)


# Functions ---------------------------------------------------------------
process_data <- function(rmsd_df_path, scores_path) {
  
  rmsd_df <- read.csv(rmsd_df_path, header = F)[, 2:1001]
  rmsd_df <- cbind(data.frame(index=seq(nrow(rmsd_df))), rmsd_df)
  scores <- read.csv(scores_path, header = F)
  rmsd_df <- cbind(scores, rmsd_df)
  colnames(rmsd_df) <- c("Energia", "Run", "Nombre", "Index", seq(nrow(rmsd_df)))
  rmsd_matrix <- as.matrix(rmsd_df[, 5:1004])
  
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
      
        if (rmsd < cutoff) {
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



write_sdf_clusters <- function(rmsd_df, sdf_path, clusters, output_path){
  
  sdf_file <- ChemmineR::read.SDFset(sdf_path)

  
  # if cluster lenght is only 1, ill consider as "outliers"
  outliers <- NULL
  
  for (cluster_index in seq_along(clusters)) {
    
    cluster <- clusters[[cluster_index]]
    
    if (length(cluster) > 1) {
      print("ok")
      statistics <- rmsd_df %>% 
        filter(as.integer(Index) %in% cluster) %>% 
        summarise(N=n(),
                  meanEnergy=mean(Energia),
                  minEnergy=min(Energia),
                  sdEnergy=sd(Energia)) %>% round(., 3)
      
      print("ok")
      write.SDF(sdf_file[clusters[[cluster_index]]],
                file = sprintf('%s/cluster%s_size=%s_mean=%s_min=%s_std=%s.sdf',
                               output_path,cluster_index,statistics$N,statistics$meanEnergy,statistics$minEnergy,statistics$sdEnergy
                )
      )
      print("ok")
    } else {
      outliers <- append(outliers, cluster)
      
    }
  }
  
  statistics <- rmsd_df %>% 
    filter(as.integer(Index) %in% outliers) %>% 
    summarise(N=n(),
              meanEnergy=mean(Energia),
              minEnergy=min(Energia),
              sdEnergy=sd(Energia)) %>% round(., 3)
  
  
  write.SDF(sdf_file[outliers],
            file = sprintf('%s/outliers_size=%s_mean=%s_min=%s_std=%s.sdf',
                           output_path,statistics$N,statistics$meanEnergy,statistics$minEnergy, statistics$sdEnergy
            )
  )
}

# Miscellaneous -----------------------------------------------------------


# Ejemplo de uso
rmsd_df <- read.csv('./RMSD_matrix.data', header = F)[, 2:1001]
rmsd_df <- cbind(data.frame(index=seq(nrow(rmsd_df))), rmsd_df)
score <- read.csv('../pdb/Quercetina_scores.csv', header = F)
rmsd_df <- cbind(score, rmsd_df)
colnames(rmsd_df) <- c("Energia", "Run", "Nombre", "Index", seq(1000))


rmsd_matrix <- as.matrix(rmsd_df[,5:1004])

# Ejecutar la función
clusters <- cluster_docking(rmsd_matrix, cutoff = 7.0)


a <- process_data(rmsd_df_path = './RMSD_matrix.data', scores_path = '../pdb/Quercetina_scores.csv')
b <- cluster_docking(rmsd_matrix = a[[2]], cutoff = 5.0)
write_sdf_clusters(rmsd_df = a[[1]], 
                   sdf_path = './Quercetina_sorted_conformations.sdf',
                   clusters = b,
                   output_path = './cluster_tomi/')

# SDF ---------------------------------------------------------------------

sdf_sorted <- ChemmineR::read.SDFset('./Quercetina_sorted_conformations.sdf')

outliers <- NULL

for (cluster_index in seq_along(clusters)) {
  
  cluster <- clusters[[cluster_index]]
  
  if (length(cluster) > 1) {
    
  energia <- rmsd_df %>% 
    filter(as.integer(Index) %in% cluster) %>% 
    summarise(meanEnergy=mean(Energia),
              minEnergy=min(Energia),
              sdEnergy=sd(Energia)) %>% round(., 3)
  
  
  write.SDF(sdf_sorted[clusters[[cluster_index]]],
            file = sprintf('cluster%s_mean=%s_min=%s_std=%s.sdf',
                           cluster_index,energia$meanEnergy,energia$minEnergy, round(energia$sdEnergy, 3)
                           )
  )
  } else {
    outliers <- append(outliers, cluster)
    
  }
}

energia <- rmsd_df %>% 
  filter(as.integer(Index) %in% outliers) %>% 
  summarise(meanEnergy=mean(Energia),
            minEnergy=min(Energia),
            sdEnergy=sd(Energia)) %>% round(., 3)


write.SDF(sdf_sorted[outliers],
          file = sprintf('outliers_mean=%s_min=%s_std=%s.sdf',
                         energia$meanEnergy,energia$minEnergy, round(energia$sdEnergy, 3)
                        )
        )
