from modeller import *
from modeller.automodel import *

env = Environ()
log.verbose()

env.io.atom_files_directory = ['./']

env.schedule_scale = physical.Values(default=1.0, soft_sphere=0.7)

env.io.hetatm = True

aln_file = 'input.pir'
template_id = '2p1m_B'
model_id = 'AFB3'

a=AutoModel(env,
            alnfile=aln_file,
            knowns=(template_id),
            sequence=model_id,
            assess_methods=(assess.DOPE,assess.GA341))
            
a.starting_model = 1
a.ending_model = 20
a.deviation = 4.0 #controls the amount of randomization done by randomize.xyz

#Amount of randomization between models

a.generate_method= generate.transfer_xyz
a.rand_method = randomize.xyz #change all x y z for +- 4 amstrongs

#Very thorough VTFM schedule

a.library_schedule = autosched.slow #Default is normal
a.max_var_iterations = 300

#Thorough MD optimization:

a.md_level = refine.very_slow #Degree of MD refinement
a.final_malign3d = True #if True, all generated models are fit to the 
				#templates and written out with the _fit.pdb extension.
a.make()

#Get a list of all successfully built models from a.outputs

ok_models = [x for x in a.outputs if x['failure'] is None]

#Rank the models by DOPE score
key = 'DOPE score'
ok_models.sort(key=lambda a: a[key])

#Get top model

m = ok_models[0]
print("Top model: %s (DOPE score %.3f)" % (m['name'], m[key]))