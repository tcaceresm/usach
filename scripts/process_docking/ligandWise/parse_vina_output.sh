#!/usr/bin/bash

############################################################
# Help                                                     #
############################################################
Help()
{
   # Display Help

   echo "Syntax: [-h|e]"
   echo "To save a log file and also print the status, run: bash prepare_odbqt.sh -d \$DIRECTORY | tee -a \$LOGFILE"
   echo "Options:"
   echo "h     Print help"
   echo "e     Vina Ligands PDBQT output path"
   echo "o     Summary Output file"
   
}

############################################################
# Process the input options. Add options as needed.        #
############################################################
# Get the options

while getopts ":he:o:" option; do
   case $option in
      h) # Print this help
         Help
         exit;;
      e) # Enter the Ligands PDBQT output path
         LIGANDS_PDBQT_PATH=$OPTARG;;
      o) # Summary output path
         SUMMARY_FILE_PATH=$OPTARG;;
     \?) # Invalid option
         echo "Error: Invalid option"
         exit;;
   esac
done

declare -a LIGANDS_PDBQT=($(ls ${LIGANDS_PDBQT_PATH}))
declare -a LIGANDS=($(sed "s/.pdbqt//g" <<< "${LIGANDS_PDBQT[*]}"))

for LIGAND in "${LIGANDS[@]}"
 do
  echo "Summary file path ${SUMMARY_FILE_PATH}"
  grep -i "result" -m 1 "${LIGANDS_PDBQT_PATH}/${LIGAND}.pdbqt" | awk '{print $4}'> "${SUMMARY_FILE_PATH}/${LIGAND}"

 done

echo "Done!"