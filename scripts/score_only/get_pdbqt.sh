#!/usr/bin/bash

set -euo pipefail

############################################################
# Help                                                     #
############################################################
Help()
{
   # Display Help
   echo "Usage: bash get_pdbqt.sh [-h] [-d DIRECTORY] [-n REPLICAS] [-p 0|1] [-z 0|1] [-e 0|1] [-x 0|1]"
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
trajin ../min_no_ntr_noWAT.rst7

# Save receptor and ligand separated

strip :2717 # receptor

trajout receptor.pdb
run

strip !(:2717) #ligando

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