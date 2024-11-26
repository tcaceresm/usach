#!/usr/bin/bash

############################################################
# Help
############################################################
Help() {
    echo "Syntax: extract_energies.sh [-h|d|f|o]"
    echo "To save a log file and also print the status, run: extract_energies.sh -d \$DIRECTORY | tee -a \$LOGFILE"
    echo "Options:"
    echo "h     Print help"
    echo "d     dlg file."
    echo "o     Output directory."
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

LIGAND_PDBQT=$(basename $DLG_FILE .dlg)
LIGAND_NAME=$(basename $LIGAND_PDBQT .pdbqt)
LIGAND_PDB_PATH=${OPATH}/${LIGAND_NAME}/pdb/
ENERGY_FILE="$LIGAND_PDB_PATH/docking_energies.txt"

sed -i 's/ /;/g' $ENERGY_FILE

TMP_FILE="$LIGAND_PDB_PATH/tmp.txt"

seq $(cat $ENERGY_FILE | wc -l) | sed -E "s/.+/${LIGAND_NAME}/" > $TMP_FILE

# Energies of single ligand

paste -d ';' $ENERGY_FILE $TMP_FILE > "$LIGAND_PDB_PATH/${LIGAND_NAME}_scores.csv"

rm $TMP_FILE

# All ligand energies
#cat "$LIGAND_PDB_PATH/${LIGAND_NAME}_scores.csv" >> $ALL_LIGAND_ENERGIES
