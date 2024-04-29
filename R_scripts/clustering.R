# Script para calcular la matriz de similitud y realizar un clustering


# Librerias ---------------------------------------------------------------

library(dplyr)
library(ChemmineOB)
library(ChemmineR)


# Funciones ---------------------------------------------------------------

extract_DrugOBECFP4 <- function (molecules, type = c("smile", "sdf"))
{
  
  if (type == "smile") {
    if (length(molecules) == 1L) {
      molRefs = eval(parse(text = "ChemmineOB::forEachMol('SMILES', molecules, identity)"))
      fp = eval(parse(text = "ChemmineOB::fingerprint_OB(molRefs, 'ECFP4')"))
    }
    else if (length(molecules) > 1L) {
      fp = matrix(0L, nrow = length(molecules), ncol = 4096L)
      for (i in 1:length(molecules)) {
        molRefs = eval(parse(text = "ChemmineOB::forEachMol('SMILES', molecules[i], identity)"))
        fp[i, ] = eval(parse(text = "ChemmineOB::fingerprint_OB(molRefs, 'ECFP4')"))
      }
    }
  }
  return(fp)
}


# Datos -------------------------------------------------------------------

quercetin <- read.csv('~/Escritorio/tcaceres/docking/correlacion/to_docking/vina_out_quercetin/data.csv')
quercetin <- quercetin %>% filter(N_protomer == 1)

hinokiflavone <- read.csv('~/Escritorio/tcaceres/docking/correlacion/to_docking/vina_out_hinakiflavone/data.csv')
hinokiflavone <- hinokiflavone %>% filter(N_protomer == 1)

# Cálculo de Fingerprints y matriz de tanimoto -------------------------------------------------

fingerprints <- extract_DrugOBECFP4(hinokiflavone$SMILES, type = 'smile')
fpset <- as(fingerprints, "FPset")

n <- length(fpset)
similarity_matrix <- matrix(NA, nrow = n, ncol = n)

for (i in 1:n) {
  similarity_matrix[i, ] <- ChemmineR::fpSim(fpset[i], fpset, method='Tanimoto', sorted=FALSE)
}

# Calcular la distancia entre los elementos utilizando la matriz de similitud
distance_matrix <- as.dist(1 - similarity_matrix)

# Realizar clustering jerárquico
cluster_result <- hclust(distance_matrix, method = "complete")

# Cortar el dendrograma para obtener k clusters
k_clusters <- 5 # Cambia este valor al número de clusters que deseas mostrar
clusters <- cutree(cluster_result, k = k_clusters)

# Visualizar el dendrograma con los k clusters
plot(cluster_result, main = paste("Dendrograma con", k_clusters, "clusters"))
rect.hclust(cluster_result, k = k_clusters, border = 2)

clusters_data <- split(hinokiflavone, clusters)

for (i in 1:length(clusters_data)) {
    df <- as.data.frame(clusters_data[i])
    #write.csv(df, sprintf('~/Escritorio/tcaceres/docking/correlacion/to_docking/clusters_hinakiflavone/cluster%s.csv', i), row.names=F)
    print(cor(df[,3], df[,8], use = 'na'))
}

