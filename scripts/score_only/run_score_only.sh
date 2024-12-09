#!/usr/bin/bash

set -euo pipefail

############################################################
# Help                                                     #
############################################################
Help()
{
   # Display Help
   echo "Usage: bash score_only.sh [-h] [-d DIRECTORY] [-n LIG_RESNUM] [-a LIG_NAME] [-c MINIMIZATION_FILE]"
   echo
   echo "AMBER Protein-Ligand Complex rst7 --> receptor.pdb and ligand.mol2."
   echo " --> Obtaing PDBQT's --> Compute AD4 Maps --> Get score of minimized pose"
   echo "--> redock ligand in minimized pocket."
   echo "All AD4 scripts are provided in this folder"
   echo "Requires AMBER cpptraj and a rst7 file (without water and ions) from minimization."
   echo
   echo "Options:"
   echo "  -h                    Print this help"
   echo "  -d DIRECTORY          Working directory."
   echo "  -l LOCATION           Docking site name. In this project, is either buried_pocket or sitio_catalitico."
   echo "  -c NUM_CORES          Number of threads to use."
   echo "  -y REPLICAS_START     (default=1). See example below."
   echo "  -n REPLICAS_END       Replicas. See example below."
   echo "  -p PROCESS_RST7       (default=1). Process rst7 from minimization in AMBER. Requires cpptraj".
   echo "  -f RST7_FILE          (default="min_no_ntr_noWAT.rst7"). RST7 filename."        
   echo "  -q OBTAIN_PDBQT       (default=1). Obtain PDBQTs of ligand and receptor."
   echo "  -m PREPARE_MAPS       (default=1). Calculate grid maps for AD4."
   echo "  -x RESCORE_REDOCKING  (default=1). Perform rescoring of minimized pose, and perform docking on minimized pocket."
   echo "  -k PROCESS_REDOCKING  (default=1). Process docking output of redocked poses."
   echo "  -t CUTOFF             (default=2.0). Cutoff employed for clustering of redocked poses."


   echo
   echo "Examples:"

}

# Default values
REPLICAS_START=1
LIGAND_RESNUMBER=2717
RST7_FILE="min_no_ntr_noWAT.rst7"
PROCESS_RST=1
OBTAIN_PDBQT=1
PREPARE_MAPS=1
RESCORE_and_REDOCKING=1
CUTOFF=2.0

############################################################
# Process the input options. Add options as needed.        #
############################################################
# Get the options
while getopts ":hd:l:c:n:y:p:f:q:m:x:k:t:" option; do
   case $option in
      h) # Print this help
         Help
         exit;;
      d) # Enter the MD Directory
         WD_PATH=$OPTARG;;
      l) # Docking location # THIS IS VERY SPECIFIC TO MY PROJECT
         LOCATION=$OPTARG;;
      c) # Number of threads to use
         NUM_CORES=$OPTARG;;         
      n) # Replicas
         REPLICAS_END=$OPTARG;;
      y) # Replicas start
         REPLICAS_START=$OPTARG;;
      p) # Process_RST7
         PROCESS_RST=$OPTARG;;
      f)  # Minimization file
         RST7_FILE=$OPTARG;;         
      q)  # Obtain PDBQT
         OBTAIN_PDBQT=$OPTARG;;
      m)  # Prepare maps for AD
         PREPARE_MAPS=$OPTARG;;
      x)  # Rescore and redocking
         RESCORE_and_REDOCKING=$OPTARG;;
      k)  # Process redocking
         PROCESS_REDOCKING=$OPTARG;;
      t)  # Clustering cutoff of redocking poses
         CUTOFF=$OPTARG;;
     \?) # Invalid option
         echo "Error: Invalid option"
         exit;;
   esac
done

############################################################
# Main
############################################################

#Ruta de la carpeta del script (donde se encuentra este script)
SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Ruta de la carpeta de trabajo. Es SCRIPT_PATH / WD_PATH
WDPATH=($(realpath $WD_PATH))

# Receptor
RECEPTOR_PDB=($(basename "${WDPATH}/receptor/"*.pdb))
if [[ ${#RECEPTOR_PDB[@]} -eq 0 ]]
then
    echo "Empty receptor folder."
    echo "Exiting."
    exit 1
fi

RECEPTOR=($(sed "s/.pdb//g" <<< "${RECEPTOR_PDB[*]}"))

# Ligandos analizados
LIGANDS_MOL2=("${WDPATH}/ligands/${LOCATION}_ligands/mol2_files/"*.mol2)
#echo "${WDPATH}/ligands/${LOCATION}/"*.mol2

if [[ ${#LIGANDS_MOL2[@]} -eq 0 ]]
then
    echo "Empty ligands folder."
    echo "Exiting."
    exit 1
fi

LIGANDS=($(sed "s/.mol2//g" <<< "${LIGANDS_MOL2[*]}"))

# Generate a list of all jobs
JOBS=()

for REP in $(seq ${REPLICAS_START} ${REPLICAS_END})
do
  for LIG in "${LIGANDS[@]}"
  do  

    LIG=$(basename "${LIG}")
    LIG_RESNUM=2717
    RST7_FILE="min_no_ntr_noWAT.rst7"
    # For each replica-ligand combination, prepare the job for parallel execution
    MMPBSA_rescoring_PATH=${WDPATH}/MD/${RECEPTOR}/proteinLigandMD/${LOCATION}/${LIG}/setupMD/rep${REP}/mmpbsa_rescoring
    JOBS+=("${MMPBSA_rescoring_PATH} ${LIG_RESNUM} ${LIG} ${PROCESS_RST} ${RST7_FILE} ${OBTAIN_PDBQT} ${PREPARE_MAPS} ${RESCORE_and_REDOCKING} ${PROCESS_REDOCKING} ${CUTOFF}" ) #

  done

done

# Run in parallel
printf "%s\n" "${JOBS[@]}" | parallel -j $NUM_CORES --colsep ' ' ${SCRIPT_PATH}/score_only.sh -d {1} -n {2} -a {3} -p {4} -f {5} -q {6} -m {7} -x {8} -k {9} -t {10}
#printf "%s\n" "${JOBS[@]}" 
