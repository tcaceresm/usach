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

aln_file = '/home/tcaceres/Documents/tecnicas_avanzadas/modeller_files/afb3/multiple_template/degron_canonico/AFB3_TIR1s_modeller_input.pir'
#aln_file = '../../../AFB3_TIR1s_modeller_input.pir'

e = modeller.Environ()
a = modeller.Alignment(e, file=aln_file)

N_models = 400 #Change this depending of the number of models to plot

template = get_profile('../../2p1q_B.profile', a['2p1q_B'])

for i in range(1, N_models + 1):
	
	if i < 10:

		model = get_profile('AFB3.BL000{}0001.profile'.format(i), a['AFB3'])


		# Plot the template and model profiles in the same plot for comparison:
		plt.figure(1, figsize=(10,6))
		plt.xlabel('Alignment position')
		plt.ylabel('DOPE per-residue score')
		plt.plot(model, color='green', linewidth=2, label='AFB3.BL000{}0001.profile'.format(i))
		plt.plot(template, color='red', linewidth=2, label='2p1q_B')
		plt.ylim([-0.06, 0])
		plt.legend()
		plt.savefig('AFB3.BL000{}0001.profile_template.png'.format(i), dpi=100)
		plt.clf()
		
	elif i < 100:
	
		model = get_profile('AFB3.BL00{}0001.profile'.format(i), a['AFB3'])


		# Plot the template and model profiles in the same plot for comparison:
		plt.figure(1, figsize=(10,6))
		plt.xlabel('Alignment position')
		plt.ylabel('DOPE per-residue score')
		plt.plot(model, color='green', linewidth=2, label='AFB3.BL00{}0001.profile'.format(i))
		plt.plot(template, color='red', linewidth=2, label='2p1q_B')
		plt.ylim([-0.06, 0])
		plt.legend()
		plt.savefig('AFB3.BL00{}0001.profile_template.png'.format(i), dpi=100)
		plt.clf()
	else:
		
		model = get_profile('AFB3.BL0{}0001.profile'.format(i), a['AFB3'])


		# Plot the template and model profiles in the same plot for comparison:
		plt.figure(1, figsize=(10,6))
		plt.xlabel('Alignment position')
		plt.ylabel('DOPE per-residue score')
		plt.plot(model, color='green', linewidth=2, label='AFB3.BL0{}0001.profile'.format(i))
		plt.plot(template, color='red', linewidth=2, label='2p1q_B')
		plt.ylim([-0.06, 0])
		plt.legend()
		plt.savefig('AFB3.BL0{}0001.profile_template.png'.format(i), dpi=100)
		plt.clf()
	
