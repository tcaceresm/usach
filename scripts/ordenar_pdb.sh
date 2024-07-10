#!/bin/bash

# Ruta al archivo PDB
PDB_FILE="./Crisina.pdb"

# Archivo temporal para almacenar los valores de energía y los nombres de conformaciones
TEMP_FILE="temp_energy_values.txt"
CONFORMATIONS_DIR="conformations"

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
cat $SORTED_FILE

# Limpiar archivos temporales
rm -rf $TEMP_FILE $CONFORMATIONS_DIR
