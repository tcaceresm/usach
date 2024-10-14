#!/bin/bash

############################################################
# Help
############################################################
Help() {
    echo "Script used to convert a lot of files using obabel"
    echo "Syntax: convert_obabel.sh [-h|d|i|f|o]"
    echo "To save a log file and also print the status, run: convert_obabel.sh -d \$DIRECTORY | tee -a \$LOGFILE"
    echo "Options:"
    echo "h     Print help"
    echo "d     Input directory."
    echo "i     Input format."
    echo "f     Output directory."
    echo "o     Output format."
}

while getopts ":hd:i:f:o:" option; do
    case $option in
        h)  # Print this help
            Help
            exit;;
        d)  # Enter the input directory
            IPATH=$OPTARG;;
        i)  # Input Format
            IFORMAT=$OPTARG;;
        f)  # Output directory
            OPATH=$OPTARG;;
        o)  # Output Format
            OFORMAT=$OPTARG;;
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

# Crea el directorio de salida si no existe
mkdir -p "$OPATH"

# Recorre todos los archivos en formato IFORMAT en el directorio de entrada
for input_file in "$IPATH"/*.$IFORMAT; do
    # Obtener el nombre del archivo sin la extensión
    base_name=$(basename "$input_file" ".$IFORMAT")
    # Ruta completa del archivo PDBQT de salida
    output_file="$OPATH/$base_name.$OFORMAT"
    # Convertir el archivo MOL2 a PDBQT usando Open Babel
    obabel -i$IFORMAT "$input_file" -o$OFORMAT -O "$output_file"
    echo "Convertido: $input_file -> $output_file"
done

echo "Conversion completed."
