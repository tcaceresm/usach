#!/usr/bin/bash

# First run pymol -c get_buried_pocket_coords.py. It will generate
# .dat files containing center of mass of pockets.

for i in {1..14}; do

  cat <<EOF > epock_chain${i}.in
[DEFAULT]
grid_spacing=0.5
contiguous = false
padding = 1.4
profile = true
contribution = residue

[cav${i}]
EOF

  # Agrega el contenido procesado de buried_pocket_residues_chain${i}.dat
  grep -v 'Residues' buried_pocket_residues_chain${i}.dat | \
    awk '{print $6 $7 $8}' | \
    sed 's/,/ /g' | \
    sed 's/\[/include_sphere = /g' | \
    sed 's/\]/ 7 /g' >> epock_chain${i}.in
done
