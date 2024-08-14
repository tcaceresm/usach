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
    echo "To save a log file and also print the status, run: rmsd_matrix.sh -d \$DIRECTORY | tee -a \$LOGFILE"
    echo "Options:"
    echo "h     Print help"
    echo "d     Input directory containing dlg files."
    echo "o     Output directory."
}

while getopts ":hd:o:" option; do
    case $option in
        h)  # Print this help
            Help
            exit;;
        d)  # Enter the input directory
            IPATH=$OPTARG;;
        o)  # Output directory
            OPATH=$OPTARG;;
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

for DLG_FILE in "$IPATH"/*.dlg
do
    LIGAND_PDBQT=$(basename $DLG_FILE .dlg)
    LIGAND_NAME=$(basename $LIGAND_PDBQT .pdbqt)
    
    SDF_DIR="${OPATH}/${LIGAND_NAME}/sdf"
    RMSD_FILE="${OPATH}/${LIGAND_NAME}/sdf/${LIGAND_NAME}_RMSD_matrix.data"
    
    echo "Performing RMSD matrix calculation of ${LIGAND_NAME}"
    obrms -x ${SDF_DIR}/${LIGAND_NAME}_sorted_conformations.sdf > ${RMSD_FILE}

done
