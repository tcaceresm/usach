# Modified by Andreas Schueller <aschueller@bio.puc.cl> on 2022-07-20

from modeller import *
from modeller.automodel import *

num_models = 5

def superpose(query, target):
    mdl  = Model(env, file='1fas')
    mdl2 = Model(env, file='2ctx')
    aln = Alignment(env, file='toxin.ali', align_codes=('1fas', '2ctx'))

    atmsel = Selection(mdl).only_atom_types('CA')
    r = atmsel.superpose(mdl2, aln)

    # We can now use the calculated RMS, DRMS, etc. from the returned 'r' object:
    rms = r.rms
    drms = r.drms
    print("%d equivalent positions" % r.num_equiv_pos)

    mdl2.write(file='2ctx.fit')
    

log.verbose()
env = Environ()
a = AutoModel(env, alnfile='fm00495.ali',
              knowns=('5a0u_BchainB', '5a0z_BchainB'), sequence='5a0z_BchainB_loops', assess_methods=[assess.DOPE, assess.normalized_dope])
a.starting_model = 1
a.ending_model = num_models

# Very thorough VTFM optimization:
a.library_schedule = autosched.slow
a.max_var_iterations = 300

# Thorough MD optimization:
a.md_level = refine.very_slow

# Repeat the whole cycle 2 times and do not stop unless obj.func. > 1E6
a.repeat_optimization = 3
a.max_molpdf = 1e6

#a.final_malign3d = True # Produces an error, probably becausee the alignment of 5a0u and 5a0z has zero equivalent residues

a.make()

# Superpose models onto 5a0z. We have to do this manually, since 'a.final_malign3d = True' produces an error,
# probably becausee the alignment of 5a0u and 5a0z has zero equivalent residues
for i in range(1,num_models + 1):
    mdl = Model(env)
    aln = Alignment(env)
    target = '5a0z_Bchain_fit'
    mdl.read(file=target) # Target
    aln.append_model(mdl, align_codes=target, atom_files=target)
    query = '5a0z_BchainB_loops.B9999000' + str(i)
    mdl.read(file=query) # Query
    aln.append_model(mdl, align_codes=query, atom_files=query)
    aln.malign(gap_penalties_1d=(-600, -400))
    aln.malign3d(gap_penalties_3d=(0, 2.0), write_fit=True)
    aln.write(file='malign3d_%s.ali' % i)
