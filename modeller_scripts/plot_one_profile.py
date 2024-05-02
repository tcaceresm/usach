import matplotlib.pyplot as plt
import modeller


#Script to plot a profile file

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



e = modeller.Environ()

profile_file = '2p1q_B.profile'

template = get_profile(profile_file)




# Plot the template and model profiles in the same plot for comparison:
plt.figure(1, figsize=(10,6))
plt.xlabel('Alignment position')
plt.ylabel('DOPE per-residue score')
plt.plot(template, color='green', linewidth=2, label=profile_file)
plt.ylim([-0.06, 0])
plt.legend()
plt.savefig(profile_file + '.png', dpi=1000)
