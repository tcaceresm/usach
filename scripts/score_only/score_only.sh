#!/usr/bin/bash

set -euo pipefail

############################################################
# Help                                                     #
############################################################
Help()
{
   # Display Help
   echo "Usage: bash score_only.sh [-h] [-d DIRECTORY] [-n LIG_RESNUM] [-a LIG_NAME] [-c MINIMIZATION_FILE]"
   echo
   echo "AMBER Protein-Ligand Complex rst7 --> receptor.pdb and ligand.mol2."
   echo " --> Obtaing PDBQT's --> Compute AD4 Maps --> Get score of minimized pose"
   echo "--> redock ligand in minimized pocket."
   echo "All AD4 scripts are provided in this folder"
   echo "Requires AMBER cpptraj and a rst7 file (without water and ions) from minimization."
   echo
   echo "Options:"
   echo "  -h                    Print this help"
   echo "  -d DIRECTORY          MMPBSA_rescoring folder."
   echo "  -n LIG_RESIDUE        (default=2717). Ligand residue number."
   echo "  -a LIG_NAME           Ligand name."
   echo "  -p PROCESS_RST7       (default=1). Process rst7 from minimization in AMBER. Requires cpptraj".
   echo "  -f RST7_FILE          (default="min_no_ntr_noWAT.rst7"). RST7 filename."        
   echo "  -q OBTAIN_PDBQT       (default=1). Obtain PDBQTs of ligand and receptor."
   echo "  -m PREPARE_MAPS       (default=1). Calculate grid maps for AD4."
   echo "  -x RESCORE_REDOCKING  (default=1). Perform rescoring of minimized pose, and perform docking on minimized pocket."
   echo "  -t CUTOFF             (default=2.0). Cutoff employed for clustering of redocked poses."
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

while getopts ":hd:n:a::p:f:q:m:x:k:t:" option; do
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
        p)  # Process RST7
            PROCESS_RST=$OPTARG;;
        f)  # Minimization file
            RST7_FILE=$OPTARG;;
        q)  # Obtain PDBQT
            OBTAIN_PDBQT=$OPTARG;;
        m)  # Prepare maps for AD
            PREPARE_MAPS=$OPTARG;;
        x)  # Rescore and redocking
            RESCORE_and_REDOCKING=$OPTARG;;
        k)  # Process redocking
            PROCESS_REDOCKING=$OPTARG;;
        t)  # Clustering cutoff of redocking poses
            CUTOFF=$OPTARG;;
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

mkdir -p "${IPATH}/docking_score_only"
cd ${IPATH}/docking_score_only

if [[ ${PROCESS_RST} -eq 1 ]]
then
    # Prepare cpptraj input file to obtain receptor.pdb and ligand.mol2 (GAFF2 atom type)

    echo "Obtaining receptor.pdb and ligand.mol2"

    cat <<EOF > "./get_rec_lig.in"
parm ../../../../topo/${LIGAND_NAME}_buried_pocket_vac_com.parm7
trajin ../${RST7_FILE}
# Save receptor and ligand separated
strip :${LIGAND_RESNUMBER} # receptor
trajout receptor.pdb
run
strip !(:${LIGAND_RESNUMBER}) #ligando
trajout ${LIGAND_NAME}_GAFF2.mol2
run
EOF

    ${AMBERHOME}/bin/cpptraj -i ${IPATH}/docking_score_only/get_rec_lig.in


    echo "REMINDER: Ligand MOL2 format have GAFF2 atom types. Going to use antechamber to obtain SYBYL atom types."
    echo
    echo "#########################################################"
    echo "Using antechamber to convert GAFF2 -> SYBYL atom types"
    echo "#########################################################"
    echo

    ${AMBERHOME}/bin/antechamber -i ${IPATH}/docking_score_only/${LIGAND_NAME}_GAFF2.mol2 -fi mol2 -o ${IPATH}/docking_score_only/${LIGAND_NAME}_SYBYL.mol2 -fo mol2 -at sybyl -pf y
    echo "Done!"
    echo
fi

if [[ ${OBTAIN_PDBQT} -eq 1 ]]
then
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
fi


if [[ ${PREPARE_MAPS} -eq 1 ]]
then
    echo "######################"
    echo "Preparing GPF file    "
    echo "Grid box centered on ligand "
    echo "Size=50,50,50"
    echo "######################"

    #-y flag center grid box on ligand
    ${SCRIPT_PATH}/prepare_gpf.py -l ${IPATH}/docking_score_only/${LIGAND_NAME}.pdbqt -r ${IPATH}/docking_score_only/receptor.pdbqt -y -p npts='50,50,50'

    if [[ -f "${IPATH}/docking_score_only/receptor.gpf" ]]
    then
        echo "GPF created!"
    else
        echo "GPF creation failed."
        echo "Exiting..."
        exit 1
    fi

    echo "###############################"
    echo "Computing maps with AutoGrid."
    echo "Maybe check AGFR, I think it's faster:"
    echo " https://ccsb.scripps.edu/agfr/"
    echo "##############################"

    ${SCRIPT_PATH}/autogrid4 -p ${IPATH}/docking_score_only/receptor.gpf -l ${IPATH}/docking_score_only/receptor.glg

    echo "Ok!"
fi

# echo "######################"
# echo "Preparing DPF file    "
# echo "######################"

#${SCRIPT_PATH}/prepare_dpf4.py -l ${IPATH}/docking_score_only/${LIGAND_NAME}.pdbqt -r ${IPATH}/docking_score_only/receptor.pdbqt 

if [[ ${RESCORE_and_REDOCKING} -eq 1 ]]
then

    echo "#################################"
    echo "Computing score of input ligand  "
    echo " and computing redocking         "
    echo "#################################"

    mkdir -p ${IPATH}/docking_score_only/redocking/

    /usr/local/bin/autodock_gpu_64wi -L ${IPATH}/docking_score_only/${LIGAND_NAME}.pdbqt -M ${IPATH}/docking_score_only/*.fld --resnam ${IPATH}/docking_score_only/redocking/${LIGAND_NAME}_redocking --nrun 1000 --rlige 1

    # Get Binding affinity

    mkdir -p ${IPATH}/docking_score_only/score_only/

    awk '/INPUT-LIGAND-PDBQT: USER    Estimated Free Energy of Binding/ {print $9}' ${IPATH}/docking_score_only/redocking/${LIGAND_NAME}_redocking.dlg > ${IPATH}/docking_score_only/score_only/score_only.dat
fi

if [[ ${PROCESS_REDOCKING} -eq 1 ]]
then
    /usr/bin/bash ${SCRIPT_PATH}/process_output.sh -d ${IPATH}/docking_score_only/redocking/ -o ${IPATH}/docking_score_only/redocking/processed_output -c ${CUTOFF}
fi
