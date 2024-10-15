#!/bin/bash

###################################################
# Procesamiento del output de docking             #
# 1) dlg -> pdbqt y pdb                           #         
# 2) sort docking conformations based on affinity #
# 3) Obtain docking scores                        #
# 4) RMSD matrix                                  #
# 5) Clustering basado en RMSD                    #
###################################################

############################################################
# Help
############################################################
Help() {
    echo "Script used to process AD output"
    echo "Syntax: process_output.sh [-h|d|o]"
    echo "To save a log file and also print the status, run: process_dlg.sh -d \$DIRECTORY | tee -a \$LOGFILE"
    echo "Options:"
    echo "h     Print help."
    echo "d     dlg files directory."
    echo "o     Output directory."
}

while getopts ":hd:o:c:" option; do
    case $option in
        h)  # Print this help
            Help
            exit;;
        d)  # Enter the input directory
            IPATH=$OPTARG;;
        o)  # Output directory
            OPATH=$OPTARG;;
        c)  # Clustering cutoff
            CUTOFF=$OPTARG;;
        \?) # Invalid option
            echo "Error: Invalid option"
            exit;;
    esac
done

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


echo "
########################
# Processing dlg files #
########################
"

${SCRIPT_PATH}/process_dlg.sh -d ${IPATH} -o ${OPATH}

echo "Done processing dlg files!"


echo "
#########################
# Sorting conformations #
#########################
"
${SCRIPT_PATH}/sort_pdb.sh -d ${IPATH} -o ${OPATH}

echo "Done sorting conformations!"

echo "
#########################################
# Creating csv file with docking scores #
#########################################
"

${SCRIPT_PATH}/extract_energies.sh -d ${IPATH} -o ${OPATH}

echo "Done creating csv file with docking scores!"


echo "
###########################
# Calculating RMSD matrix #
###########################
"
${SCRIPT_PATH}/rmsd_matrix.sh -d ${IPATH} -o ${OPATH}

echo "Done calculating RMSD matrix"

echo "
#######################################
# Performing clustering based on RMSD #
#######################################
"

${SCRIPT_PATH}/run_clustering.sh -d ${IPATH} -o ${OPATH} -c $CUTOFF
