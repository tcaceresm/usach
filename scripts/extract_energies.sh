#!/usr/bin/bash

############################################################
# Help
############################################################
Help() {
    echo "Syntax: ordenar_pdb.sh [-h|d|f|o]"
    echo "To save a log file and also print the status, run: ordenar_pdb.sh -d \$DIRECTORY | tee -a \$LOGFILE"
    echo "Options:"
    echo "h     Print help"
    echo "d     Input directory containing dlg files."
}

while getopts ":hd:i:f:o:" option; do
    case $option in
        h)  # Print this help
            Help
            exit;;
        d)  # Enter the input directory
            IPATH=$OPTARG;;
        \?) # Invalid option
            echo "Error: Invalid option"
            exit;;
    esac
done

for DLG_FILE in "$IPATH"/*.dlg; do

    LIGAND_PDBQT=$(basename $DLG_FILE .dlg)
    LIGAND_NAME=$(basename $LIGAND_PDBQT .pdbqt)
    # Archivo temporal para almacenar los valores de energía y los nombres de conformaciones

    ENERGY_FILE="${IPATH}/data/${LIGAND_NAME}/pdb/temp_energy_values.txt"
    TMP_FILE="${IPATH}/data/${LIGAND_NAME}/pdb/tmp.txt"
    seq $(cat $ENERGY_FILE | wc -l) | sed -E "s/.+/${LIGAND_NAME}/" > $TMP_FILE

    paste -d ',' $ENERGY_FILE $TMP_FILE > "${IPATH}/data/${LIGAND_NAME}/pdb/${LIGAND_NAME}_scores.csv"
done