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
   echo "  -h                   Print this help"
   echo "  -d DIRECTORY         Working directory."
   echo "  -y REPLICAS_START    (default=1). See example below."
   echo "  -n REPLICAS_END      Replicas. See example below."
   echo "  -c NUM_CORES         Number of threads to use."
   echo
   echo "Examples:"

}

# Default values
REPLICAS_START=1

############################################################
# Process the input options. Add options as needed.        #
############################################################
# Get the options
while getopts ":hd:n:y:c:" option; do
   case $option in
      h) # Print this help
         Help
         exit;;
      d) # Enter the MD Directory
         WD_PATH=$OPTARG;;
      n) # Replicas
         REPLICAS_END=$OPTARG;;
      y) # Replicas start
         REPLICAS_START=$OPTARG;;
      c) # Number of threads to use
         NUM_CORES=$OPTARG;;
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
LIGANDS_MOL2=("${WDPATH}/ligands/buried_pocket/"*.mol2)
#echo "${WDPATH}/ligands/buried_pocket/"*.mol2

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
    MMPBSA_rescoring_PATH=${WDPATH}/MD/${RECEPTOR}/proteinLigandMD/buried_pocket/${LIG}/setupMD/rep${REP}/mmpbsa_rescoring
    JOBS+=("${MMPBSA_rescoring_PATH} ${LIG_RESNUM} ${LIG} ${RST7_FILE}") #

  done

done

# Run in parallel
printf "%s\n" "${JOBS[@]}" | parallel -j $NUM_CORES --colsep ' ' ${SCRIPT_PATH}/score_only.sh -d {1} -n {2} -a {3} -c {4}