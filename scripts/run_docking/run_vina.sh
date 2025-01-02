#!/usr/bin/bash


############################################################
# Help                                                     #
############################################################
Help()
{
   # Display Help

   echo "Syntax: NA"
   echo "Options:"
   echo "h     Print help"
   echo "l     Ligands PDBQT"
   echo "c     Configuration file. It should contain grid box information, Num_modes and exhaustiveness"
   echo "o     Output directory"
   
}

############################################################
# Process the input options. Add options as needed.        #
############################################################
# Get the options

while getopts ":h:l:c:o:" option; do
   case $option in
      h) # Print this help
         Help
         exit;;
      l) # Enter the Ligands PDBQT output path
         LIGANDS_PDBQT_PATH=$OPTARG;;
      c) # Vina configuration file
         CONFIG_FILE=$OPTARG;;
      o) # Output path
         OUTPUT_PATH=$OPTARG;;   
     \?) # Invalid option
         echo "Error: Invalid option"
         exit;;
   esac
done

LIGANDS_PDBQT=(${LIGANDS_PDBQT_PATH}/*.pdbqt)

mkdir -p ${OUTPUT_PATH}

for LIGAND in "${LIGANDS_PDBQT[@]}"
 do
  LIGAND=$(basename ${LIGAND} .pdbqt)
  echo "Docking ${LIGAND}"
  #/home/pc-usach-cm/Documentos/autodock_vina_1_1_2_linux_x86/bin/vina --config ${CONFIG_FILE} --ligand ${LIGANDS_PDBQT_PATH}/${LIGAND} --out ${OUTPUT_PATH}/${LIGAND} --log "${OUTPUT_PATH}/${LIGAND}.log"
  /home/pc-usach-cm/Documentos/gpu_autodockvina/Vina-GPU-2.1/AutoDock-Vina-GPU-2.1/AutoDock-Vina-GPU-2-1 --config ${CONFIG_FILE} --ligand ${LIGANDS_PDBQT_PATH}/${LIGAND}.pdbqt --out ${OUTPUT_PATH}/${LIGAND}.pdbqt --log "${OUTPUT_PATH}/${LIGAND}.log"
 done

echo "Done!"
