#!/usr/bin/bash

ligands_path="/home/pc-usach-cm/Escritorio/tcaceres/docking/corr_hinokiflavone/to_docking/ligandos"

declare -a ligandos_a_convertir=($(ls ${ligands_path}))

for ligando_a_convertir in "${ligandos_a_convertir[@]}"
   do
    echo "Convirtiendo ${ligando_a_convertir} a pdbqt"
    /home/pc-usach-cm/.local/bin/mk_prepare_ligand.py -i ${ligands_path}/${ligando_a_convertir} -o "${ligands_path}/${ligando_a_convertir}.pdbqt"
    echo "Listo para ${ligando_a_convertir}"
   done
   
rename 's/.sdf.pdbqt/.pdbqt/' ${ligands_path}/*.sdf.pdbqt   
