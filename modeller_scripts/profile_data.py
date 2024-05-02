#Modified from plot_profiles.py by Tomás Caceres <caceres.tomas@uc.cl>

#Script to write a profile file, which can be used to plot with Python or R

#Usage example
#python3 get_profile.py > file.log


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


profile_file = '2p1q_B.profile'

scores = get_profile(profile_file)
indexes = [x for x in range(1, len(scores) +1)]

dictionary = {
                'res': indexes,
	            'scores': scores
            }


df = pd.DataFrame(dictionary)

df.to_csv('data.csv', index=False)


