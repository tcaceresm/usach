# Function to replace NONAME with the molecule name extracted from PROPERTY_DATA section
def replace_noname_with_property_data_name(content):
    molecules = content.split("@<TRIPOS>MOLECULE")
    modified_content = "@<TRIPOS>MOLECULE"  # Start with the first molecule marker
    for molecule in molecules[1:]:  # Skip the first split part as it will be empty
        molecule_lines = molecule.split('\n')
        for i, line in enumerate(molecule_lines):
            if line.startswith('NONAME'):
                for j in range(i, len(molecule_lines)):
                    if molecule_lines[j].startswith('@<TRIPOS>PROPERTY_DATA'):
                        property_data_name = molecule_lines[j + 1].replace("Nombre |", "").strip()
                        molecule_lines[i] = property_data_name
                        break
                break
        modified_content += '\n'.join(molecule_lines) + "\n@<TRIPOS>MOLECULE"
    
    # Remove the last @<TRIPOS>MOLECULE that was added at the end
    modified_content = modified_content[:-len("\n@<TRIPOS>MOLECULE")]
    return modified_content

# Path to the new uploaded file
new_file_path = '/mnt/linux_partition/tcaceres/docking/ligandos/flavones/mol2_flavones/flavones.mol2'  # Reemplaza con la ruta correcta a tu archivo

# Read the original content of the newly uploaded file
with open(new_file_path, 'r') as file:
    content = file.read()

# Apply the replacement function to the new content
modified_content = replace_noname_with_property_data_name(content)

# Save the modified content to a new file
modified_new_file_path = '/mnt/linux_partition/tcaceres/docking/ligandos/flavones/mol2_flavones/flavones_noname_replaced.mol2'  # Reemplaza con la ruta deseada para el archivo modificado
with open(modified_new_file_path, 'w') as file:
    file.write(modified_content)

print(f"Archivo modificado guardado en: {modified_new_file_path}")
	
