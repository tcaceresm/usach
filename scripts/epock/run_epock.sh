#!/usr/bin/bash

# First run pymol -c get_buried_pocket_coords.py. It will generate
# .dat files containing center of mass of pockets.

for i in {1..14}; do
  echo "Running ${i}"
  mkdir "epock_chain${i}_output"
  epock -s "./last_snapshot.pdb" -c "./epock_chain${i}.in" -o "./epock_chain${i}_output/chain${i}_volume.dat" -f "AF_ClpP_prod_noWAT.xtc" --ox
  echo "Done ${i}"
done
