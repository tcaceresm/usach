#!/usr/bin/bash

# Simple script to perform docking of several ligands in different pockets

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
   echo "r     Receptor map file (fld) directory. All pocket folder should be inside this directory"
   echo "l     Ligands PDBQT"
   echo "o     Output directory"
   echo "n     N runs"
   
}

############################################################
# Process the input options. Add options as needed.        #
############################################################
# Get the options

while getopts ":hr:l:o:n:" option; do
   case $option in
      h) # Print this help
         Help
         exit;;
      l) # Enter the Ligands PDBQT output path
         LIGANDS_PDBQT_PATH=$OPTARG;;
      r) # Receptor FLD directory
         RECEPTOR_FLD=$OPTARG;;
      o) # Output path
         OUTPUT_PATH=$OPTARG;;
      n) # NRuns
         NRUNS=$OPTARG;;
     \?) # Invalid option
         echo "Error: Invalid option"
         exit;;
   esac
done

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

for i in {1..14}
do
    RECEPTOR_FLD_POCKET=${RECEPTOR_FLD}/sitio_${i}/
    OUTPUT_PATH_POCKET=${OUTPUT_PATH}/sitio_${i}

    echo "Doing for site ${i}"

    ${SCRIPT_PATH}/run_ad_gpu.sh -r ${RECEPTOR_FLD_POCKET} -l ${LIGANDS_PDBQT_PATH} -o ${OUTPUT_PATH_POCKET} -n 1000

    echo "Done for site ${i}"
done