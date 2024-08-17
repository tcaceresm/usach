#!/usr/bin/bash

############################################################
# Help
############################################################
Help() {
    echo "Syntax: extract_energies.sh [-h|d|f|o]"
    echo "To save a log file and also print the status, run: extrac_eneries.sh -d \$DIRECTORY | tee -a \$LOGFILE"
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

ALL_LIGAND_ENERGIES=${IPATH}/data/docking_scores.csv
> $ALL_LIGAND_ENERGIES

for DLG_FILE in "$IPATH"/*.dlg; do

    LIGAND_PDBQT=$(basename $DLG_FILE .dlg)
    LIGAND_NAME=$(basename $LIGAND_PDBQT .pdbqt)
    LIGAND_PDB_PATH=${IPATH}/data/${LIGAND_NAME}/pdb/
    ENERGY_FILE="$LIGAND_PDB_PATH/docking_energies.txt"
    
    sed -i 's/ /;/g' $ENERGY_FILE

    TMP_FILE="$LIGAND_PDB_PATH/tmp.txt"
    
    seq $(cat $ENERGY_FILE | wc -l) | sed -E "s/.+/${LIGAND_NAME}/" > $TMP_FILE

    # Energies of single ligand

    paste -d ';' $ENERGY_FILE $TMP_FILE > "$LIGAND_PDB_PATH/${LIGAND_NAME}_scores.csv"

    rm $TMP_FILE
   
    # All ligand energies
    cat "$LIGAND_PDB_PATH/${LIGAND_NAME}_scores.csv" >> $ALL_LIGAND_ENERGIES

    
done
