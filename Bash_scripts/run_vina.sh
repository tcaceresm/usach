#!/usr/bin/bash

config_file='/home/pc-usach-cm/Escritorio/tcaceres/docking/autodock_vina_input/grid_box_monomers.txt'
ligands_path='/home/pc-usach-cm/Escritorio/tcaceres/docking/corr_hinokiflavone/to_docking/ligandos'
declare -a ligands=($(ls ${ligands_path}))
output_path='/home/pc-usach-cm/Escritorio/tcaceres/docking/corr_hinokiflavone/to_docking/vina_out'
for ligand in "${ligands[@]}"
 do
  echo "Docking ${ligand}"
  /home/pc-usach-cm/Documentos/autodock_vina_1_1_2_linux_x86/bin/vina --config ${config_file} --ligand ${ligands_path}/${ligand} --out ${output_path}/${ligand}
 done
