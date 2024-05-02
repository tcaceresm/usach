from modeller import *
from modeller.scripts import complete_pdb

######
#Modified by Tomás Cáceres <caceres.tomas@uc.cl>
#Script to obtain profile of a model
#Modified just for convenience

#Usage example

#python3 evaluate_model_modified AFB3.B99990016.pdb 

import sys

#Input: model_file.pdb
model_to_eval = sys.argv[1]

######

log.verbose()    # request verbose output
env = Environ()
env.libs.topology.read(file='$(LIB)/top_heav.lib') # read topology
env.libs.parameters.read(file='$(LIB)/par.lib') # read parameters

# read model file        ###########
mdl = complete_pdb(env, model_to_eval)

# Assess with DOPE:
s = Selection(mdl)   # all atom selection
s.assess_dope(output='ENERGY_PROFILE NO_REPORT', file=model_to_eval.replace('pdb', 'profile'),
              normalize_profile=True, smoothing_window=15)
