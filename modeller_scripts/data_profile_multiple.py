#Modified from plot_profiles.py by Tomás Caceres <caceres.tomas@uc.cl>

#Script to write a profile csv file, which can be used to plot with Python or R

#Version to write a profile csv file of N number of models


import pandas as pd

def get_profile(profile_file):
    """Read `profile_file` into a Python array, and add gaps corresponding to
       the alignment sequence `seq`."""
    # Read all non-comment and non-blank lines from the file:
    f = open(profile_file)
    vals = []
    for line in f:
        if not line.startswith('#') and len(line) > 10:
            spl = line.split()
            vals.append(float(spl[-1]))
    return vals



N_models = 400 #This should change depending of the number of models

for i in range(1, N_models + 1):

	if i < 10:
		profile_file = 'AFB3.BL000{}0001.profile'.format(i)

		scores = get_profile(profile_file)
		indexes = [x for x in range(1, len(scores) +1)]
		

		dictionary = {
			      	'res': indexes,
				'scores': scores
			     }


		df = pd.DataFrame(dictionary)
		df.to_csv('AFB3.BL000{}0001.profile.csv'.format(i), index=False)
	

		
	elif i < 100:
	
		profile_file = 'AFB3.BL00{}0001.profile'.format(i)

		scores = get_profile(profile_file)
		indexes = [x for x in range(1, len(scores) +1)]
		

		dictionary = {
			      	'res': indexes,
				'scores': scores
			     }


		df = pd.DataFrame(dictionary)
		df.to_csv('AFB3.BL00{}0001.profile.csv'.format(i), index=False)	
	else:
	
		profile_file = 'AFB3.BL0{}0001.profile'.format(i)

		scores = get_profile(profile_file)
		indexes = [x for x in range(1, len(scores) +1)]
		

		dictionary = {
			      	'res': indexes,
				'scores': scores
			     }


		df = pd.DataFrame(dictionary)
		df.to_csv('AFB3.BL0{}0001.profile.csv'.format(i), index=False)
		


