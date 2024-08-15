#!/usr/bin/awk -f

BEGIN {molecule=""}
/@<TRIPOS>MOLECULE/ {
    if (molecule !="")
    {
        sub("NONAME",molname, molecule)
        print molecule > out
        close(out)
    }
    molecule = $0 "\n"
    }

/@<TRIPOS>PROPERTY_DATA/ {
    molecule = (molecule $0 "\n"); getline; molname = $3; out = molname ".mol2" }

!(/@<TRIPOS>MOLECULE/ || /@<TRIPOS>PROPERTY_DATA/) {
    molecule = (molecule $0 "\n")
    }

END {
    sub("NONAME",molname, molecule)
    print molecule > out
    }