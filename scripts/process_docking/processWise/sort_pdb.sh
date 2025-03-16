#!/bin/bash

##########################################################################
# Sort  ligands' conformations in a PDB file based on binding energy     #
##########################################################################

############################################################
# Help
############################################################
Help() {
    echo "Sort ligands' conformations in PDB file based on binding energy"
    echo "Syntax: sort_pdb.sh [-h|d|f|o]"
    echo "To save a log file and also print the status, run: ordenar_pdb.sh -d \$DIRECTORY | tee -a \$LOGFILE"
    echo "Options:"
    echo "h     Print help"
    echo "d     dlg files directory."
    echo "o     Ouput directory."
}

while getopts ":hd:i:f:o:" option; do
    case $option in
        h)  # Print this help
            Help
            exit;;
        d)  # Enter the input directory
            IPATH=$OPTARG;;
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

for DLG_FILE in "$IPATH"/*.dlg; do

    LIGAND_PDBQT=$(basename $DLG_FILE .dlg)
    LIGAND_NAME=$(basename $LIGAND_PDBQT .pdbqt)
    echo "Doing for $LIGAND_NAME"    

    # Archivo temporal para almacenar los valores de energía y los nombres de conformaciones
    CONFORMATIONS_DIR="${OPATH}/${LIGAND_NAME}/pdb"
    ENERGY_FILE="${OPATH}/${LIGAND_NAME}/pdb/docking_energies.txt"
    PDB_FILE=${CONFORMATIONS_DIR}/$LIGAND_NAME.pdb
        
    # Crear un directorio temporal para almacenar las conformaciones
    mkdir -p $CONFORMATIONS_DIR

    # Split pdb file, obtain energy values  

    awk -v energy_file=${ENERGY_FILE} -v conformation_dir=${CONFORMATIONS_DIR} '
    /MODEL/ {
        molecule = $0 "\n"
        run = $2
        out = (conformation_dir "/model_" run ".pdb")
        }
    /Estimated Free Energy of Binding/ {
        molecule = (molecule $0 "\n")
        #energy = sprintf("%.2f", $8); (molecule $0 "\n")
        split($0, fields, "=")
        split(fields[2], energy, " ")
        energia = sprintf("%.2f", energy[1])
        }
    /ENDMDL/ {
        molecule = (molecule $0 "\n")
        print molecule > out
        close(out)
        print (energia, run) > energy_file
    }

    !(/MODEL/ || /Estimated Free Energy of Binding/ || /ENDMDL/) {
        molecule = molecule $0 "\n"
    }
    ' $PDB_FILE


    if test -f "$ENERGY_FILE"; then
        :
    else
        echo "Energy File not generated!. Please check ${LIGAND_NAME}"
        
    fi

    # Ordenar las conformaciones por energía
    sort -n $ENERGY_FILE -o $ENERGY_FILE

    # Crear un archivo final con las conformaciones ordenadas
    SORTED_FILE="$CONFORMATIONS_DIR/${LIGAND_NAME}_sorted_conformations.pdb"
    > $SORTED_FILE

    # Leer el archivo de energías y concatenar las conformaciones ordenadas
    best_pose=true
    best_pose_name=
    while IFS= read -r line; do
        model_num=$(echo "$line" | awk '{print $2}')
        cat "$CONFORMATIONS_DIR/model_$model_num.pdb" >> $SORTED_FILE

        if $best_pose
        then
            cat "$CONFORMATIONS_DIR/model_$model_num.pdb" > "$CONFORMATIONS_DIR/${LIGAND_NAME}_best_pose.pdb"
            best_pose=false
        fi
    done < $ENERGY_FILE

    echo "Sorted PDB!"

    # Limpiar archivos temporales
    rm -rf $CONFORMATIONS_DIR/model_*.pdb

    # Obtener SDF con poses ordenadas

    echo "Generating sorted SDF file based on sorted PDB"
    obabel -ipdb "$CONFORMATIONS_DIR/${LIGAND_NAME}_sorted_conformations.pdb" -osdf -O"${OPATH}/${LIGAND_NAME}/sdf/${LIGAND_NAME}_sorted_conformations.sdf"
    obabel -ipdb "$CONFORMATIONS_DIR/${LIGAND_NAME}_best_pose.pdb" -osdf -O"${OPATH}/${LIGAND_NAME}/sdf/${LIGAND_NAME}_best_pose.sdf"

done
