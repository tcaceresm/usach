# compare_multi.py - Compare multiple structures with a given alignment (PIR format)
# NO fitting/superpositioning is done, the structures are expected to be superposed,
# e.g. by salign.
#
# USAGE
#     mod10.1 compare_multi.py <alignment.ali>
#  OR
#     python compare_multi.py <alignment.ali>
#
# USAGE EXAMPLES
# mod10.1 compare_multi.py 25_SARS-2.ali
# python compare_multi.py 25_SARS-2.ali > compare_multi.log
# 
# AUTHOR
# Andreas Schueller <aschueller@bio.puc.cl>
#
# HISTORY
# 2022-07-19    0.2      Added energy assessment
# 2022-01-27    0.1.2    Fixed errors in comments
# 2021-12-29    0.1.1    Forgot to rename old script name in some instances and
#                        added usage info using python
# 2021-12-28    0.1      First version

from __future__ import print_function
from modeller import *
from modeller.scripts import complete_pdb
import sys

if len(sys.argv) <= 1:
    print('ERROR: Expected the alignment file as the first command line argument.', file=sys.stderr)
    print('USAGE: mod10.1 compare_multi.py <alignment.ali>', file=sys.stderr)
    sys.exit(1)
    
alifile = sys.argv[1]

if __name__ == '__main__':
    #log.very_verbose()
    env = Environ()
    env.io.atom_files_directory = ['.']
    aln = Alignment(env)
    
    # Compare structures
    aln.append(file=alifile, align_codes='all')
    print("Comparing structures without cutoffs...")
    aln.compare_structures(rms_cutoffs=[999]*11, fit=False, asgl_output=True)
    print("Comparing structures with 3.5A/60 degree cutoffs for RMS, DRMS, and dihedral angle comparisons...")
    aln.compare_structures(rms_cutoffs=(3.5, 3.5, 60, 60, 60, 60, 60, 60, 60, 60, 60), fit=False)
    
    # Assess energy
    env.libs.topology.read(file='$(LIB)/top_heav.lib')
    env.libs.parameters.read(file='$(LIB)/par.lib')
    dope = []
    zscore = []
    for seq in aln:
        mdl = complete_pdb(env, seq.atom_file)
        sel = Selection(mdl.chains[0])
        dope.append(sel.assess_dope())
        zscore.append(mdl.assess_normalized_dope())

    print('Enery assessment')
    print('File', 'DOPE', 'Normalized DOPE')
    for i,seq in enumerate(aln):
        print(seq.atom_file, dope[i], zscore[i])