#!/bin/bash

#############################################################################
# Ordena las conformaciones de un archivo PDB en base a la energía de unión #
#############################################################################

############################################################
# Help
############################################################
Help() {
    echo "Syntax: ordenar_pdb.sh [-h|d|f|o]"
    echo "To save a log file and also print the status, run: ordenar_pdb.sh -d \$DIRECTORY | tee -a \$LOGFILE"
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
    
    # Archivo temporal para almacenar los valores de energía y los nombres de conformaciones
    CONFORMATIONS_DIR="${OPATH}/${LIGAND_NAME}/pdb"
    TEMP_FILE="${OPATH}/${LIGAND_NAME}/pdb/temp_energy_values.txt"
    PDB_FILE=${CONFORMATIONS_DIR}/$LIGAND_NAME.pdb
    
    # Crear un directorio temporal para almacenar las conformaciones
    mkdir -p $CONFORMATIONS_DIR

    # Limpiar el archivo temporal si existe
    > $TEMP_FILE

    # Variables para manejar las conformaciones
    model_num=""
    conformation=""
    energy=""

    # Leer el archivo PDB línea por línea
    while IFS= read -r line; do
        # Buscar el inicio de una nueva conformación
        if [[ "$line" =~ ^MODEL ]]; then
            model_num=$(echo "$line" | awk '{print $2}')
            conformation="$line"$'\n'
        elif [[ "$line" =~ ^ENDMDL ]]; then
            conformation+="$line"$'\n'
            # Guardar la conformación en un archivo temporal
            echo "$energy $model_num" >> $TEMP_FILE
            echo -e "$conformation" > "$CONFORMATIONS_DIR/model_$model_num.pdb"
            conformation=""
        elif [[ "$line" =~ ^REMARK.*Estimated\ Free\ Energy\ of\ Binding ]]; then
            energy=$(echo "$line" | awk '{print $8}')
            conformation+="$line"$'\n'
        else
            conformation+="$line"$'\n'
        fi
    done < "$PDB_FILE"

    # Ordenar las conformaciones por energía
    sort -n $TEMP_FILE -o $TEMP_FILE

    # Crear un archivo final con las conformaciones ordenadas
    SORTED_FILE="sorted_conformations.pdb"
    > $SORTED_FILE

    # Leer el archivo temporal y concatenar las conformaciones ordenadas
    while IFS= read -r line; do
        model_num=$(echo "$line" | awk '{print $2}')
        cat "$CONFORMATIONS_DIR/model_$model_num.pdb" >> $SORTED_FILE
    done < $TEMP_FILE

    # Mostrar el archivo ordenado
    # cat $SORTED_FILE

    # Limpiar archivos temporales
    rm -rf $TEMP_FILE $CONFORMATIONS_DIR

done