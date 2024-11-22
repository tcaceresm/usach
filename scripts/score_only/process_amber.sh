#!/usr/bin/bash

set -euo pipefail

############################################################
# Help                                                     #
############################################################
Help()
{
   # Display Help
   echo "Usage: bash process_amber.sh [-h] [-d DIRECTORY] [-n REPLICAS] [-p 0|1] [-z 0|1] [-e 0|1] [-x 0|1]"
   echo
   echo "AMBER Protein-Ligand Complex rst7 --> receptor.pdb and ligand.mol2."
   echo "Requires cpptraj and a rst7 (without water and ions) file from minimization."
   echo "Hard-coded:"
   echo " Ligand residue --> 2717"
   echo " rst7 file from minimization (MM/PBSA procedure) --> min_no_ntr_noWAT.rst7" 
   echo
   echo "Options:"
   echo "  -h                   Print this help"
   echo "  -d DIRECTORY         MMPBSA_rescoring folder."
   echo "  -n LIG_RESIDUE       (default=2717). Ligand residue number."
   echo "  -a LIG_NAME          Ligand name."
   echo "  -c rst7 file         (default="min_no_ntr_noWAT.rst7"). Unsolvated minimization file."
   echo
   echo "Examples:"

}


# Default values

LIGAND_RESNUMBER=2717
RST7_FILE="min_no_ntr_noWAT.rst7"

############################################################
# Process the input options. Add options as needed.        #
############################################################
# Get the options

while getopts ":hd:n:a:" option; do
    case $option in
        h)  # Print this help
            Help
            exit;;
        d)  # Enter the mmpbsa_rescoring directory
            IPATH=$OPTARG;;
        n)  # Ligand residue number in PL complex.
            LIGAND_RESNUMBER=$OPTARG;;
        a)  # Ligand name
            LIGAND_NAME=$OPTARG;;
        \?) # Invalid option
            echo "Error: Invalid option"
            exit;;
    esac
done

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# cpptraj

if [[ -z ${AMBERHOME} ]]
then
    echo "AMBERHOME not found."
    echo "Exiting..."
    exit 1
fi

# Check if mmpbsa_rescoring/docking_score_only exists

if [[ ! -d "${IPATH}/docking_score_only" ]]
then
   echo "${IPATH}/docking_score_only dont exists."
   echo "Exiting..."
   exit 1
else
   cd ${IPATH}/docking_score_only
fi

# Prepare cpptraj input file

  cat <<EOF > "./get_rec_lig.in"
parm ../../../../topo/${LIGAND_NAME}_buried_pocket_vac_com.parm7
trajin ../${RST7_FILE}
# Save receptor and ligand separated
strip :${LIGAND_RESNUMBER} # receptor
trajout receptor.pdb
run
strip !(:${LIGAND_RESNUMBER}) #ligando
trajout ${LIGAND_NAME}_GAFF.mol2
run
EOF

${AMBERHOME}/bin/cpptraj -i ${IPATH}/docking_score_only/get_rec_lig.in

echo "REMINDER: Ligand MOL2 format have GAFF2 atom types. Going to use antechamber to obtain SYBYL atom types."
echo
echo "#########################################################"
echo "Using antechamber to convert GAFF2 -> SYBYL atom types"
echo "#########################################################"
echo

${AMBERHOME}/bin/antechamber -i ${IPATH}/docking_score_only/${LIGAND_NAME}_GAFF.mol2 -fi mol2 -o ${IPATH}/docking_score_only/${LIGAND_NAME}_SYBYL.mol2 -fo mol2 -at sybyl -pf y
echo "Done!"
echo

echo "######################"
echo "Obtaining PDBQT files"
echo "######################"

if [[ -z $(which obabel) ]]
then
 echo " obabel not found."
 echo " Exiting..."
 exit 1
fi

echo " Processing receptor "
${SCRIPT_PATH}/prepare_receptor4.py -r ${IPATH}/docking_score_only/receptor.pdb
echo "  OK!"

echo
echo " Processing Ligand "

obabel -i mol2 ${IPATH}/docking_score_only/${LIGAND_NAME}_SYBYL.mol2 -o pdbqt -O ${IPATH}/docking_score_only/${LIGAND_NAME}.pdbqt
echo "  OK!"

echo "######################"
echo "Preparing GPF file    "
echo "######################"

#-y flag center grid box on ligand
${SCRIPT_PATH}/prepare_gpf.py -l ${IPATH}/docking_score_only/${LIGAND_NAME}.pdbqt -r ${IPATH}/docking_score_only/receptor.pdbqt -y -p npts='50,50,50'

if [[ -f "${IPATH}/docking_score_only/receptor.gpf" ]]
then
    echo "GPF created!"
else
    echo "GPF creation failed."
    echo "Exiting..."
fi

echo "###############################"
echo "Computing maps with AutoGrid."
echo "Maybe check AGFR, is faster:"
echo " https://ccsb.scripps.edu/agfr/"
echo "##############################"

/home/pc-usach-cm/Documentos/autodocksuite-4.2.6-x86_64Linux2/x86_64Linux2/autogrid4 -p ${IPATH}/docking_score_only/receptor.gpf -l ${IPATH}/docking_score_only/receptor.glg

echo "Ok!"

# echo "######################"
# echo "Preparing DPF file    "
# echo "######################"

#${SCRIPT_PATH}/prepare_dpf4.py -l ${IPATH}/docking_score_only/${LIGAND_NAME}.pdbqt -r ${IPATH}/docking_score_only/receptor.pdbqt 

echo "#################################"
echo "Computing score of input ligand    "
echo "#################################"

/usr/local/bin/autodock_gpu_64wi -L Quercetina.pdbqt -M *.fld --resnam AD_GPU_score_only --nrun 1 --rlige 1

# Falta procesar el output para filtrar solo la energya del input ligand