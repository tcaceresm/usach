import matplotlib.pyplot as plt
import modeller

def r_enumerate(seq):
    """Enumerate a sequence in reverse order"""
    # Note that we don't use reversed() since Python 2.3 doesn't have it
    num = len(seq) - 1
    while num >= 0:
        yield num, seq[num]
        num -= 1

def get_profile(profile_file, seq):
    """Read `profile_file` into a Python array, and add gaps corresponding to
       the alignment sequence `seq`."""
    # Read all non-comment and non-blank lines from the file:
    f = open(profile_file)
    vals = []
    for line in f:
        if not line.startswith('#') and len(line) > 10:
            spl = line.split()
            vals.append(float(spl[-1]))
    # Insert gaps into the profile corresponding to those in seq:
    for n, res in r_enumerate(seq.residues):
        for gap in range(res.get_leading_gaps()):
            vals.insert(n, None)
    # Add a gap at position '0', so that we effectively count from 1:
    vals.insert(0, None)
    return vals


####
#Modified by Tomás Cáceres <caceres.tomas@uc.cl>
#Script to obtain a profile plot of model and template

import sys
aln_file = sys.argv[1]
template_profile = sys.argv[2]
model_profile = sys.argv[3]
####


e = modeller.Environ()
a = modeller.Alignment(e, file=aln_file)

template = get_profile(template_profile, a[template_profile.split('.')[0]])

#template = get_profile('2p1q_b.profile', a['2p1q_b'])

model = get_profile(model_profile, a[model_profile.split('.')[0]])
#model = get_profile('AFB3_3.profile', a['AFB3'])


# Plot the template and model profiles in the same plot for comparison:
plt.figure(1, figsize=(10,6))
plt.xlabel('Alignment position')
plt.ylabel('DOPE per-residue score')
plt.plot(model, color='red', linewidth=2, label=model_profile.split('.')[1])
plt.plot(template, color='green', linewidth=2, label='Template1')
plt.ylim([-0.06, 0])
plt.legend()
plt.savefig('dope_profile_{}.png'.format(model_profile.split('.')[1]), dpi=1000)
