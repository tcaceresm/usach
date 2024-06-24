#!/bin/bash

# Verifica si Open Babel está instalado
if ! command -v obabel &> /dev/null
then
    echo "Open Babel no está instalado. Por favor, instálalo e inténtalo de nuevo."
    exit 1
fi

# Directorio con archivos MOL2
INPUT_DIR="./mol2_files"
# Directorio para guardar archivos PDBQT
OUTPUT_DIR="../pdbqt_files"

# Crea el directorio de salida si no existe
mkdir -p "$OUTPUT_DIR"

# Recorre todos los archivos MOL2 en el directorio de entrada
for mol2_file in "$INPUT_DIR"/*.mol2; do
    # Obtener el nombre del archivo sin la extensión
    base_name=$(basename "$mol2_file" .mol2)
    # Ruta completa del archivo PDBQT de salida
    pdbqt_file="$OUTPUT_DIR/$base_name.pdbqt"
    # Convertir el archivo MOL2 a PDBQT usando Open Babel
    obabel "$mol2_file" -O "$pdbqt_file"
    echo "Convertido: $mol2_file -> $pdbqt_file"
done

echo "Conversión completada."
