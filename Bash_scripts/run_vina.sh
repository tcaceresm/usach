#!/usr/bin/bash


############################################################
# Help                                                     #
############################################################
Help()
{
   # Display Help

   echo "Syntax: [-hrlco]"
   echo "To save a log file and also print the status, run: bash prepare_odbqt.sh -d \$DIRECTORY | tee -a \$LOGFILE"
   echo "Options:"
   echo "h     Print help"
   echo "r     Receptor PDBQT file"
   echo "l     Ligands PDBQT"
   echo "c     Configuration file. It should contain grid box information, Num_modes and exhaustiveness"
   echo "o     Output directory"
   
}

############################################################
# Process the input options. Add options as needed.        #
############################################################
# Get the options

while getopts ":hr:l:c:o:" option; do
   case $option in
      h) # Print this help
         Help
         exit;;
      r) # Receptor PDBQT file
         RECEPTOR_PDBQT=$OPTARG;;
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

declare -a LIGANDS_PDBQT=($(ls ${LIGANDS_PDBQT_PATH}))
declare -a LIGANDS=($(sed "s/.sdf//g" <<< "${LIGANDS_PDBQT[*]}"))


for LIGAND  in "${LIGANDS[@]}"
 do
  echo "Docking ${ligand}"
  /home/pc-usach-cm/Documentos/autodock_vina_1_1_2_linux_x86/bin/vina --config ${CONFIG_FILE} --ligand ${LIGANDS_PDBQT_PATH}/${LIGAND} --out ${OUTPUT_PATH}/${LIGAND}
 done

echo "Done!"
