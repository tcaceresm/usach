#!/usr/bin/bash

############################################################
# Help
############################################################
Help() {
    echo "Syntax: cluster_docking.sh [-h|d|f|o]"
    echo "To save a log file and also print the status, run: cluster_docking.sh -d \$DIRECTORY | tee -a \$LOGFILE"
    echo "Options:"
    echo "h     Print help"
    echo "d     Input directory containing dlg folder. This is to obtain ligand names."
    echo "n     Name of the folder containing processed dlg files."
    echo "p     Path to Biomol2Clust."
}

while getopts ":hd:n:p:" option; do
    case $option in
        h)  # Print this help
            Help
            exit;;
        d)  # Enter the input directory
            IPATH=$OPTARG;;
        n)  # Processed dlg folder
            PROCESSED_DLG=$OPTARG;;
        p)  # Path to Biomol2Clust
            BIOMOL2CLUST_PATH=$OPTARG;;
        \?) # Invalid option
            echo "Error: Invalid option"
            exit;;
    esac
done


for DLG_FILE in "$IPATH"/*.dlg; do

    LIGAND_PDBQT=$(basename $DLG_FILE .dlg)
    LIGAND_NAME=$(basename $LIGAND_PDBQT .pdbqt)

    SDF_DIR="${IPATH}/${PROCESSED_DLG}/${LIGAND_NAME}/sdf"


    if ! [ -e ${SDF_DIR}/$LIGAND_NAME.sdf ]
    then
        echo "SDF file for $LIGAND_NAME does not exists"
        exit 1
    fi

    # Process SDF to use BioMol2Clust. It requires a M dG=value.
    sed -i 's/    Estimated Free Energy of Binding/M dG/g' ${SDF_DIR}/$LIGAND_NAME.sdf
    sed -i 's/\[=(1)+(2)+(3)-(4)\]//g' ${SDF_DIR}/$LIGAND_NAME.sdf

    # Output directory
    mkdir -p ${SDF_DIR}/cluster
    
    echo "Starting clustering with Biomol2Clust"
    python3 ${BIOMOL2CLUST_PATH}/main.py input=${SDF_DIR}/$LIGAND_NAME.sdf output=${SDF_DIR}/cluster

    if [ -f "${SDF_DIR}/cluster/RESULTS.txt"]; then
        echo "Clustering of $LIGAND_NAME passed succesfully"
    else
        echo "Clustering of $LIGAND_NAME failed"
    fi

done

echo "Done"