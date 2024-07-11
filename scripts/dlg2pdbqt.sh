#!/bin/bash

############################################
# Transformación de formato .dlg a .pdbqt  #
############################################

############################################################
# Help
############################################################
Help() {
    echo "Syntax: ordenar_pdb.sh [-h|d|f|o]"
    echo "To save a log file and also print the status, run: ordenar_pdb.sh -d \$DIRECTORY | tee -a \$LOGFILE"
    echo "Options:"
    echo "h     Print help"
    echo "d     Input directory containing dlg files."
    echo "f     Output directory."
}

while getopts ":hd:i:f:o:" option; do
    case $option in
        h)  # Print this help
            Help
            exit;;
        d)  # Enter the input directory
            IPATH=$OPTARG;;
        f)  # Output directory
            OPATH=$OPTARG;;
        \?) # Invalid option
            echo "Error: Invalid option"
            exit;;
    esac
done

for DLG_FILE in "$IPATH"/*.dlg; do

    LIGAND_PDBQT=$(basename $DLG_FILE .dlg)
    LIGAND_NAME=$(basename $LIGAND_PDBQT .pdbqt)

    echo "Converting $DLG_FILE to $LIGAND_PDBQT"

    # Archivo temporal para almacenar los valores de energía y los nombres de conformaciones
    PDBQT_DIR="${OPATH}/${LIGAND_NAME}/pdbqt"
    # Crear un directorio temporal para almacenar las conformaciones
    mkdir -p $PDBQT_DIR

    grep 'DOCKED' $DLG_FILE > $LIGAND_PDBQT
    grep -v 'FINAL DOCKED STATE' $LIGAND_PDBQT > temp.pdbqt && mv temp.pdbqt $LIGAND_PDBQT
    grep -v '^DOCKED: USER\s*_' $LIGAND_PDBQT > temp.pdbqt && mv temp.pdbqt $LIGAND_PDBQT
    grep -v '^DOCKED: USER\s*x\s*y\s*z' $LIGAND_PDBQT > temp.pdbqt && mv temp.pdbqt $LIGAND_PDBQT
    sed -i 's/DOCKED: //g' $LIGAND_PDBQT
    sed -i 's/USER/REMARK/g' $LIGAND_PDBQT
    grep -v 'MODEL' $LIGAND_PDBQT > temp.pdbqt && mv temp.pdbqt $LIGAND_PDBQT

    mv $LIGAND_PDBQT $PDBQT_DIR

    echo "Converted $DLG_FILE to $LIGAND_PDBQT"

done