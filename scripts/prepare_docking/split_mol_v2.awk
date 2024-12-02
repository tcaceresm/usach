#!/usr/bin/awk -f

BEGIN {molecule=""; FS="/"}
/@<TRIPOS>MOLECULE/ {
    if (molecule !="")
    {
        sub(old_name, molname, molecule)
        print molecule > out
        close(out)
    }
    molecule = $0 "\n"
    getline; old_name = $0; molname = $9; out = molname ".mol2" 
    }

!(/@<TRIPOS>MOLECULE/) {
    molecule = (molecule $0 "\n")
    }

END {
    sub(old_name,molname, molecule)
    print molecule > out
    }
