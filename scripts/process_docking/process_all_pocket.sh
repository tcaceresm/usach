#!/usr/bin/bash

# Simple script to process docking output for all 14 sites

############################################################
# Help
############################################################
Help() {
    echo "Script used to process AD output"
    echo "Syntax: process_output.sh [-h|d|o]"
    echo "To save a log file and also print the status, run: process_dlg.sh -d \$DIRECTORY | tee -a \$LOGFILE"
    echo "Options:"
    echo "h     Print help."
    echo "d     dlg files directory."
    echo "o     Output directory."
    echo "c     Clustering cutoff"
}

############################################################
# Process the input options. Add options as needed.        #
############################################################
# Get the options

while getopts ":hd:c:" option; do
    case $option in
        h)  # Print this help
            Help
            exit;;
        d)  # Enter the DLG output directory
            IPATH=$OPTARG;;
        c)  # Clustering cutoff
            CUTOFF=$OPTARG;;
        \?) # Invalid option
            echo "Error: Invalid option"
            exit;;
    esac
done

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

for i in {1..14}
do
    SITE_DLG=${IPATH}/sitio_${i}/
    OUTPUT_PATH_POCKET=${IPATH}/sitio_${i}/processed_output/

    if [[ ! -d ${OUTPUT_PATH_POCKET} ]]
    then
     mkdir ${OUTPUT_PATH_POCKET}
    fi

    echo "###################"
    echo "Doing for site ${i}"
    echo "###################"

    ${SCRIPT_PATH}/process_output.sh -d ${SITE_DLG} -o ${OUTPUT_PATH_POCKET} -c ${CUTOFF}

    echo "Done for site ${i}"
done
