Eventualmente haré un protocolo

prepare_docking:
	Scripts para preparar el docking
	Obtener pdbqts' del receptor y ligando, maps, etc.

run_docking:
	Scripts para ejecutar el docking, vina o AD

process_docking:
	Scripts para procesar los resultados del docking de vina o AD

	process_dlg.sh > sort_pdb.sh > extract_energies.sh > obrms > clustering.R


El archivo flavones.mol2 proviene de MOE.
Sin embargo, el nombre de la molecula no es adecuado (NONAME),
pero el nombre de la molécula aparece en @<TRIPOS>PROPERTY_DATA.
Proceso el archivo flavones.mol2 para que en vez de NONAME posean el nombre adecuado.
	rename step1 y luego el comando en rename step2
Ahora, spliteo el archivo con split_mol.sh
El archivo flavones_modified.mol2
