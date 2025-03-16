#!/bin/bash

################################################
#       DLG --> SDF with meeko package         #
# Requires R
################################################

############################################################
# Help
############################################################
Help() {
    echo "Script used to process dlg output from (AD or vina CHECK)"
    echo "Syntax: process_dlg.sh [-h|d|o]"
    echo "Options:"
    echo "h     Print help."
    echo "d     DLG file path."
    echo "o     Processed DLG output directory."
}

while getopts ":hd:o:" option; do
    case $option in
        h)  # Print this help
            Help
            exit;;
        d)  # Enter the input directory
            DLG_FILE=$OPTARG;;
        o)  # Output directory
            OPATH=$OPTARG;;
        \?) # Invalid option
            echo "Error: Invalid option"
            exit;;
    esac
done

# check mk_export.py
if ! command -v mk_export.py &> /dev/null
then
    echo "Can't find mk_export.py script"
    exit 1
fi

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


LIGAND_NAME=$(basename ${DLG_FILE} .dlg)
LIGAND_SDF=${LIGAND_NAME}.sdf
OUTPUT_PATH="${OPATH}/${LIGAND_NAME}/sdf/"

echo "Converting ${DLG_FILE} to ${LIGAND_SDF}"

mkdir -p ${OUTPUT_PATH}

mk_export.py ${DLG_FILE} -s ${OUTPUT_PATH}/${LIGAND_SDF} --all_dlg_poses

echo "Converted ${LIGAND_PDBQT} to ${LIGAND_NAME}.sdf"

echo "Sorting SDF based on docking scores"

Rscript ${SCRIPT_PATH}/process_dlg.R ${OUTPUT_PATH}/${LIGAND_SDF} ${OUTPUT_PATH}

echo "Sorted!"