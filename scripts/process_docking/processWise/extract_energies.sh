#!/usr/bin/bash

############################################################
# Help
############################################################
Help() {
    echo "Syntax: extract_energies.sh [-h|d|f|o]"
    echo "Requires an already processed DLG file (process_dlg.sh)."
    echo "  The processed directory must be the same than "Processed DLG output directory" used by process_dlg.sh (-o flag)"
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
            OPATH=$OPTARG;;
        \?) # Invalid option
            echo "Error: Invalid option"
            exit;;
    esac
done

LIGAND_NAME=$(basename ${LIGAND_NAME} .dlg)
LIGAND_PDB_PATH=${OPATH}/${LIGAND_NAME}/pdb/

ENERGY_FILE="$LIGAND_PDB_PATH/docking_energies.txt"

sed -i 's/ /;/g' $ENERGY_FILE

TMP_FILE="$LIGAND_PDB_PATH/tmp.txt"

seq $(cat $ENERGY_FILE | wc -l) | sed -E "s/.+/${LIGAND_NAME}/" > $TMP_FILE

# Energies of single ligand

paste -d ';' $ENERGY_FILE $TMP_FILE > "${OPATH}/docking_scores.csv"
paste -d ';' $ENERGY_FILE $TMP_FILE > "${LIGAND_PDB_PATH}/${LIGAND_NAME}_scores.csv"
rm $TMP_FILE

# All ligand energies
#cat "$LIGAND_PDB_PATH/${LIGAND_NAME}_scores.csv" >> $ALL_LIGAND_ENERGIES
