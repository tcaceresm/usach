#!/usr/bin/bash

############################################################
# Help                                                     #
############################################################
Help()
{
   # Display Help

   echo "Syntax: [-h|d|e]"
   echo "To save a log file and also print the status, run: bash prepare_odbqt.sh -d \$DIRECTORY | tee -a \$LOGFILE"
   echo "Options:"
   echo "h     Print help"
   echo "d     Ligands SDF path"
   echo "e     Ligands PDBQT output path"
   
}

############################################################
# Process the input options. Add options as needed.        #
############################################################
# Get the options

while getopts ":hde:" option; do
   case $option in
      h) # Print this help
         Help
         exit;;
      d) # Enter the Ligands SDF directory path
         LIGANDS_SDF_PATH=$OPTARG;;
      e) # Enter the Ligands PDBQT output path
         LIGANDS_PDBQT_PATH=$OPTARG;;
     \?) # Invalid option
         echo "Error: Invalid option"
         exit;;
   esac
done

# This script path
SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Ligands SDF format
declare -a LIGANDS_SDF=($(ls ${LIGANDS_SDF_PATH}/))
# We replace .sdf with nothing. It's easier to add PDBQT extension.
declare -a LIGANDS=($(sed "s/.sdf//g" <<< "${LIGANDS_SDF[*]}"))


for LIGAND in "${LIGANDS[@]}"
   do
    echo "Converting ${LIGAND} to PDBQT format"
    /home/pc-usach-cm/.local/bin/mk_prepare_ligand.py -i '${LIGANDS_SDF_PATH}/${LIGAND}.sdf' -o "${LIGANDS_PDBQT_PATH}/${LIGAND}.pdbqt"
    echo "Done: ${LIGAND}"
   done
   
