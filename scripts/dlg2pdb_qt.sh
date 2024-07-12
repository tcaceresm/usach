#!/bin/bash

################################################
# Transformación de formato dlg a pdbqt y pdb  #
################################################

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
    LIGAND_PDB="$LIGAND_NAME.pdb"

    echo "Converting $DLG_FILE to $LIGAND_PDBQT and $LIGAND_PDB"
 
    # Crear un directorio temporal para almacenar los archivos
    PDBQT_DIR="${OPATH}/${LIGAND_NAME}/pdbqt"
    PDB_DIR="${OPATH}/${LIGAND_NAME}/pdb"
    SDF_DIR="${OPATH}/${LIGAND_NAME}/sdf"
    
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

    mkdir -p $PDB_DIR

    # Verifica si Open Babel está instalado
    if ! command -v obabel &> /dev/null
    then
        echo "Open Babel is not installed. Please install Open Babel and try again."
        exit 1
    fi

    obabel -ipdbqt ${PDBQT_DIR}/$LIGAND_PDBQT -opdb -O"${PDB_DIR}/$LIGAND_NAME.pdb"
    echo "Converted $LIGAND_PDBQT to $LIGAND_NAME.pdb"

    obabel -ipdbqt ${PDBQT_DIR}/$LIGAND_PDBQT -osdf -O"${SDF_DIR}/$LIGAND_NAME.sdf"
    echo "Converted $LIGAND_PDBQT to $LIGAND_NAME.sdf


done