from pymol import cmd

# Iterar sobre las 14 cadenas
for i in range(0,14):
    resi_98 = 98 + 194 * i
    resi_99 = 99 + 194 * i
    resi_100 = 100 + 194 * i
    resi_101 =  101 + 194 * i
    resi_121 = 121 + 194 * i
    resi_122 = 122 + 194 * i
    resi_123 = 123 + 194 * i
    resi_124 = 124 + 194 * i
    resi_153 = 153 + 194 * i
    resi_168 = 168 + 194 * i
    resi_97 = 97 + 194 * i

    residuos=f'buried_pocket_{i} {resi_97} {resi_98} {resi_99} {resi_100} {resi_101} {resi_121} {resi_122} {resi_123} {resi_124} {resi_153} {resi_168}'

    cmd.load('./last_snapshot.pdb', 'estructura')
    cmd.select(f'buried_pocket_{i}', f'resi {resi_97} + resi {resi_98} + resi {resi_99} + resi {resi_100} + resi {resi_101} + resi {resi_121} + resi {resi_122} + resi {resi_123} + resi {resi_124} + resi {resi_153} + resi {resi_168}')

    # Calcular el centro de masa de la selección
    centro_de_masa = cmd.centerofmass(f'buried_pocket_{i}')
    output_file=f'buried_pocket_residues_chain{i+1}.dat'
    with open(output_file, 'w') as f:
        f.write(f'Residues chain {i+1} {residuos}\n')
        f.write(f'Center of mass chain {i+1}: {centro_de_masa} \n')
        
    # Imprimir el centro de masa para la cadena i
    print(f"Centro de masa para cadena {i+1}: {centro_de_masa}")
