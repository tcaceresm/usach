#!/bin/bash

# Archivo de entrada
input_file="ligands2dock_replaced.mol2"

# Directorio de salida
output_dir="molecules"
mkdir -p $output_dir

# Contador de archivos
file_count=0

# Variable para almacenar el contenido de la molécula actual
current_molecule=""

# Leer el archivo de entrada línea por línea
while IFS= read -r line
do
    # Si encontramos el marcador de inicio de una molécula
    if [[ $line == "@<TRIPOS>MOLECULE" ]]; then
        # Si no es la primera molécula, guardar el archivo actual
        if (( file_count > 0 )); then
            # Extraer el nombre de la molécula de current_molecule
            molecule_name=$(echo "$current_molecule" | grep -A1 "@<TRIPOS>MOLECULE" | tail -1)
            echo $molecule_name
            # Guardar el contenido de la molécula actual en un archivo
            output_file="$output_dir/$molecule_name.mol2"
            echo "$current_molecule" > "$output_file"
        fi

        # Incrementar el contador de archivos
        ((file_count++))

        # Iniciar el contenido de la nueva molécula
        current_molecule="$line"
    else
        # Añadir la línea a la molécula actual
        current_molecule="$current_molecule"$'\n'"$line"
    fi
done < "$input_file"

# Guardar la última molécula
if [[ -n $current_molecule ]]; then
    molecule_name=$(echo "$current_molecule" | grep -A1 "@<TRIPOS>MOLECULE" | tail -1 )
    output_file="$output_dir/$molecule_name.mol2"
    echo "$current_molecule" > "$output_file"
fi
