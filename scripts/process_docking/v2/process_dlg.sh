#!/bin/bash

################################################
# Transformación de formato dlg a pdbqt y pdb  #
################################################

############################################################
# Help
############################################################
Help() {
    echo "Script used to process dlg output from AD or vina"
    echo "Syntax: process_dlg.sh [-h|d|o]"
    echo "To save a log file and also print the status, run: process_dlg.sh -d \$DIRECTORY | tee -a \$LOGFILE"
    echo "Options:"
    echo "h     Print help."
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

# Verifica si Open Babel está instalado
if ! command -v obabel &> /dev/null
then
    echo "Open Babel is not installed. Please install Open Babel and try again."
    exit 1
fi

LIGAND_PDBQT=$(basename ${DLG_FILE} .dlg)
LIGAND_NAME=$(basename ${LIGAND_PDBQT} .pdbqt)
LIGAND_PDB="${LIGAND_NAME}.pdb"

echo "Converting ${DLG_FILE} to ${LIGAND_PDBQT} and ${LIGAND_PDB}"

# Crear un directorio temporal para almacenar los archivos
PDBQT_DIR="${OPATH}/${LIGAND_NAME}/pdbqt"
PDB_DIR="${OPATH}/${LIGAND_NAME}/pdb"
SDF_DIR="${OPATH}/${LIGAND_NAME}/sdf"
MOL2_DIR="${OPATH}/${LIGAND_NAME}/mol2"

mkdir -p "${OPATH}/${LIGAND_NAME}"/{pdbqt,pdb,sdf,mol2}

# Process dlg
awk '
    $0 ~ /DOCKED/ &&
    $0 !~ /FINAL DOCKED STATE/ &&
    $0 !~ /^DOCKED: USER +_+/ &&
    $0 !~ /^DOCKED: USER *x *y *z/ &&
    $0 !~ /^DOCKED: MODEL/ {
        gsub(/^DOCKED: /, "")
        gsub(/^USER/, "REMARK")
        print
    }
' "${DLG_FILE}" > "${LIGAND_PDBQT}"

mv ${LIGAND_PDBQT} ${PDBQT_DIR}

echo "Converted ${DLG_FILE} to ${LIGAND_PDBQT}"

obabel -ipdbqt ${PDBQT_DIR}/${LIGAND_PDBQT} -opdb -O"${PDB_DIR}/${LIGAND_NAME}.pdb"
echo "Converted ${LIGAND_PDBQT} to ${LIGAND_NAME}.pdb"

obabel -ipdbqt ${PDBQT_DIR}/${LIGAND_PDBQT} -osdf -O"${SDF_DIR}/${LIGAND_NAME}.sdf"
echo "Converted ${LIGAND_PDBQT} to ${LIGAND_NAME}.sdf"

obabel -ipdbqt ${PDBQT_DIR}/${LIGAND_PDBQT} -omol2 -O"${MOL2_DIR}/${LIGAND_NAME}.mol2"
echo "Converted ${LIGAND_PDBQT} to ${LIGAND_NAME}.mol2"


