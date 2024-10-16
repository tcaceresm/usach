#!/usr/bin/bash

############################################################
# Help
############################################################
Help() {
    echo "Syntax: run_clustering.sh [-h|c|d|n]"
    echo "To save a log file and also print the status, run: run_clustering.sh -d \$DIRECTORY | tee -a \$LOGFILE"
    echo "Options:"
    echo "h     Print help"
    echo "c     RMSD cutoff."
    echo "d     dlg files directory."
    echo "o     Output directory."
}

while getopts ":hc:d:o:" option; do
    case $option in
        h)  # Print this help
            Help
            exit;;
        c)  # RMSD cutoff
            CUTOFF=$OPTARG;;
        d)  # Enter the input directory
            IPATH=$OPTARG;;
        o)  # Processed dlg folder
            PROCESSED_DLG=$OPTARG;;
        \?) # Invalid option
            echo "Error: Invalid option"
            exit;;
    esac
done

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


for DLG_FILE in "$IPATH"/*.dlg; do

    LIGAND_PDBQT=$(basename $DLG_FILE .dlg)
    LIGAND_NAME=$(basename $LIGAND_PDBQT .pdbqt)

    SDF_DIR="${PROCESSED_DLG}/${LIGAND_NAME}/sdf"
    PDB_DIR="${PROCESSED_DLG}/${LIGAND_NAME}/pdb"

    rmsd_df_path=${SDF_DIR}/${LIGAND_NAME}_RMSD_matrix.data
    docking_scores=${PDB_DIR}/${LIGAND_NAME}_scores.csv
    sdf_path=${SDF_DIR}/${LIGAND_NAME}_sorted_conformations.sdf
    output_path=${SDF_DIR}/cluster/${CUTOFF}

    mkdir -p ${output_path}

    echo "Performing pose clustering of $LIGAND_NAME"

    Rscript ${SCRIPT_PATH}/clustering.R $rmsd_df_path $docking_scores $CUTOFF $sdf_path $output_path $LIGAND_NAME
    

done