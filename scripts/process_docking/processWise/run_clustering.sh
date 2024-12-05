#!/usr/bin/bash

############################################################
# Help
############################################################
Help() {
    echo "Perform clustering of a ligand poses based on rmsd matrix."
    echo "Syntax: run_clustering.sh [-h|c|d|n]"
    echo "Requires an already processed DLG file (process_dlg.sh)."
    echo "  The processed directory must be the same than "Processed DLG output directory" used by process_dlg.sh (-o flag)"
    echo "Also requires a rmsd matrix (rmsd_matrix.sh)."
    echo "Options:"
    echo "h     Print help"
    echo "c     RMSD cutoff."
    echo "d     Ligand Name."
    echo "i     Processed ligands' directory."
}

while getopts ":hc:d:i:" option; do
    case $option in
        h)  # Print this help
            Help
            exit;;
        c)  # RMSD cutoff
            CUTOFF=$OPTARG;;
        d)  # Enter the input directory
            LIGAND_NAME=$OPTARG;;
        i)  # Output directory
            PROCESSED_DIRECTORY=$OPTARG;;
        \?) # Invalid option
            echo "Error: Invalid option"
            exit;;
    esac
done

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


LIGAND_NAME=$(basename $LIGAND_NAME .dlg)

SDF_DIR="${PROCESSED_DIRECTORY}/${LIGAND_NAME}/sdf"
PDB_DIR="${PROCESSED_DIRECTORY}/${LIGAND_NAME}/pdb"

rmsd_df_path=${SDF_DIR}/${LIGAND_NAME}_RMSD_matrix.data
docking_scores=${PROCESSED_DIRECTORY}/${LIGAND_NAME}/docking_scores.csv
sdf_path=${SDF_DIR}/${LIGAND_NAME}_sorted_conformations.sdf
output_path=${SDF_DIR}/cluster/${CUTOFF}

mkdir -p ${output_path}

echo "Performing pose clustering of $LIGAND_NAME"

Rscript ${SCRIPT_PATH}/clustering.R $rmsd_df_path $docking_scores $CUTOFF $sdf_path $output_path $LIGAND_NAME
