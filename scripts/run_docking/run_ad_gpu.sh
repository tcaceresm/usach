#!/usr/bin/bash


############################################################
# Help                                                     #
############################################################
Help()
{
   # Display Help

   echo "Syntax: [-hrlco]"
   echo "To save a log file and also print the status, run: bash prepare_odbqt.sh -d \$DIRECTORY | tee -a \$LOGFILE"
   echo "Options:"
   echo "h     Print help"
   echo "r     Receptor map file (fld) directory"
   echo "l     Ligands PDBQT"
   echo "o     Output directory"
   echo "n     N runs"
   
}

############################################################
# Process the input options. Add options as needed.        #
############################################################
# Get the options

while getopts ":hr:l:o:n:" option; do
   case $option in
      h) # Print this help
         Help
         exit;;
      r) # Receptor FLD directory
         RECEPTOR_FLD=$OPTARG;;
      l) # Enter the Ligands PDBQT path
         LIGANDS_PDBQT_PATH=$OPTARG;;
      o) # Output path
         OUTPUT_PATH=$OPTARG;;
      n) # NRuns
         NRUNS=$OPTARG;;
     \?) # Invalid option
         echo "Error: Invalid option"
         exit;;
   esac
done

LIGANDS_PDBQT=(${LIGANDS_PDBQT_PATH}/*.pdbqt)

mkdir -p ${OUTPUT_PATH}

for LIGAND_NAME in "${LIGANDS_PDBQT[@]}"
do
   LIGAND_NAME=$(basename ${LIGAND} .pdbqt)
   echo "Docking ${LIGAND}"
   /usr/local/bin/autodock_gpu_64wi -L ${LIGANDS_PDBQT_PATH}/${LIGAND}.pdbqt -M ${RECEPTOR_FLD}/*.maps.fld --nrun $NRUNS --resnam ${OUTPUT_PATH}/${LIGAND_NAME}
done

echo "Done!"
