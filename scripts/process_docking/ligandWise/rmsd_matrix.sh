#!/bin/bash

#####################################################
# Cálculo de la matriz de RMSD de poses de docking  #
#####################################################

############################################################
# Help
############################################################
Help() {
    echo "Script used to obtain RMSD matrix of docking poses. Molecules need to be the same"
    echo "Syntax: rmsd_matrix.sh [-h|d|f|o]"
    echo "Requires an already processed DLG file (process_dlg.sh)."
    echo "  The processed directory must be the same than "Processed DLG output directory" used by process_dlg.sh (-o flag)"
    echo "Also, requires SDF file of sorted files (sort_pdb.sh output)"
    echo "Options:"
    echo "h     Print help"
    echo "d     Ligand Name."
    echo "i     Processed ligands' directory."
}

while getopts ":hd:i:" option; do
    case $option in
        h)  # Print this help
            Help
            exit;;
        d)  # Enter the input directory
            LIGAND_NAME=$OPTARG;;
        i)  # Output directory
            PROCESSED_DIRECTORY=$OPTARG;;
        \?) # Invalid option
            echo "Error: Invalid option"
            exit;;
    esac
done

# Verifica si Open Babel está instalado
if ! command -v obabel &> /dev/null
then
    echo "Open Babel is not installed. Please install Open Babel and try again."
    exit 1
fi

LIGAND_NAME=$(basename ${LIGAND_NAME} .dlg)

SDF_DIR="${PROCESSED_DIRECTORY}/${LIGAND_NAME}/sdf"
RMSD_FILE="${SDF_DIR}/${LIGAND_NAME}_RMSD_matrix.data"

if [[ ! -f "${SDF_DIR}/${LIGAND_NAME}_sorted_conformations.sdf" ]]
then
    echo "SDF of sorted conformations not found."
    exit 1
fi


echo "Performing RMSD matrix calculation of ${LIGAND_NAME}"
obrms -x ${SDF_DIR}/${LIGAND_NAME}_sorted_conformations.sdf > "${RMSD_FILE}_tmp"
cat "${RMSD_FILE}_tmp" | awk '{$1=""}1' > "${RMSD_FILE}"
rm "${RMSD_FILE}_tmp"
