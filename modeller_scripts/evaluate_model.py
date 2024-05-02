from modeller import *
from modeller.scripts import complete_pdb

log.verbose()    # request verbose output
env = Environ()
env.libs.topology.read(file='$(LIB)/top_heav.lib') # read topology
env.libs.parameters.read(file='$(LIB)/par.lib') # read parameters

# read model pdb file

model_pdb = 'AFB3.B99990002.pdb'
mdl = complete_pdb(env, model_pdb)

# Assess with DOPE:
s = Selection(mdl)   # all atom selection
s.assess_dope(output='ENERGY_PROFILE NO_REPORT', file=model_pdb.replace('pdb', 'profile'),
              normalize_profile=True, smoothing_window=15)
