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
#template_profile = sys.argv[2]
model_profile = sys.argv[2]
####


e = modeller.Environ()
a = modeller.Alignment(e, file=aln_file)

template1_profile = '2p1m_B.profile'
template2_profile = '2p1p_B.profile'
template3_profile = '2p1q_B.profile'
template4_profile = '2p1n_B.profile'
template5_profile = '2p1o_B.profile'


template1 = get_profile(template1_profile, a[template1_profile.split('.')[0]])
template2 = get_profile(template2_profile, a[template2_profile.split('.')[0]])
template3 = get_profile(template3_profile, a[template3_profile.split('.')[0]])
template4 = get_profile(template4_profile, a[template4_profile.split('.')[0]])
template5 = get_profile(template5_profile, a[template5_profile.split('.')[0]])

#template = get_profile('2p1q_b.profile', a['2p1q_b'])

model = get_profile(model_profile, a[model_profile.split('.')[0]])
#model = get_profile('AFB3_3.profile', a['AFB3'])



# Plot the template and model profiles in the same plot for comparison:
plt.figure(1, figsize=(10,6))
plt.xlabel('Alignment position')
plt.ylabel('DOPE per-residue score')
plt.plot(model, color='purple', linewidth=2, label=model_profile.split('.')[1])


plt.plot(template1, color='green', linewidth=2, label='Template1')
plt.plot(template2, color='blue', linewidth=2, label='Template2')
plt.plot(template3, color='red', linewidth=2, label='Template3')
plt.plot(template4, color='black', linewidth=2, label='Template4')
plt.plot(template1, color='yellow', linewidth=2, label='Template5')







plt.ylim([-0.06, 0])
plt.legend()



plt.savefig('dope_profile_{}.png'.format(model_profile.split('.')[1]), dpi=1000)
