#Modified from evaluate_model.py by Tomás Cáceres <caceres.tomas@uc.cl>

#Script to obtain the profile of a given number of models
#Specifically, here we are obtaining the profile of loop refined models


from modeller import *
from modeller.scripts import complete_pdb

log.verbose()    # request verbose output
env = Environ()
env.libs.topology.read(file='$(LIB)/top_heav.lib') # read topology
env.libs.parameters.read(file='$(LIB)/par.lib') # read parameters



N_models = 400 #This should change depending of the numbers of models

for i in range(1, N_models + 1):
	if i < 10:
		model_name = 'AFB3.BL000{}0001.pdb'.format(i)
		mdl = complete_pdb(env, model_name)
		
		# Assess with DOPE:
		s = Selection(mdl)   # all atom selection
		s.assess_dope(output='ENERGY_PROFILE NO_REPORT', file=model_name.replace('pdb', 'profile'),
		      		normalize_profile=True, smoothing_window=15)
		
	elif i < 100:
	
		model_name = 'AFB3.BL00{}0001.pdb'.format(i)
		mdl = complete_pdb(env, 'AFB3.BL00{}0001.pdb'.format(i))
	
		# Assess with DOPE:
		s = Selection(mdl)   # all atom selection
		s.assess_dope(output='ENERGY_PROFILE NO_REPORT', file=model_name.replace('pdb', 'profile'),
		      		normalize_profile=True, smoothing_window=15)
	else:
		model_name = 'AFB3.BL0{}0001.pdb'.format(i)
		mdl = complete_pdb(env, 'AFB3.BL0{}0001.pdb'.format(i))
	
		# Assess with DOPE:
		s = Selection(mdl)   # all atom selection
		s.assess_dope(output='ENERGY_PROFILE NO_REPORT', file=model_name.replace('pdb', 'profile'),
		      		normalize_profile=True, smoothing_window=15)
	
