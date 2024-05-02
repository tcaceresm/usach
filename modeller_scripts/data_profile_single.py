#Modified from plot_profiles.py by Tomás Caceres <caceres.tomas@uc.cl>

#Script to write a profile csv file, which can be used to plot with Python or R



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



profile_name = 'AFB3.BL02210001.profile'

scores = get_profile(profile_name)

indexes = [x for x in range(1, len(scores) +1)]

dictionary = {
	      	'res': indexes,
		'scores': scores
	     }
	     
df = pd.DataFrame(dictionary)
df.to_csv('AFB3.BL02210001.profile.csv', index=False)


