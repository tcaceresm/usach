import matplotlib.pyplot as plt
import modeller

#Script to plot template and model dope score per residue profile

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



e = modeller.Environ()
a = modeller.Alignment(e, file='aln_file')

template = get_profile('2p1q_b.profile', a['2p1q_b'])

model = get_profile('AFB3_3.profile', a['AFB3'])


# Plot the template and model profiles in the same plot for comparison:
plt.figure(1, figsize=(10,6))
plt.xlabel('Alignment position')
plt.ylabel('DOPE per-residue score')
plt.plot(model, color='red', linewidth=2, label='modelo_#')
plt.plot(template, color='green', linewidth=2, label='Template')
plt.ylim([-0.06, 0])
plt.legend()
plt.savefig('modelo', dpi=1000)
