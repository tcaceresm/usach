from modeller import *
from modeller.automodel import *
import sys

####

ali_file = sys.argv[1]
template_name = sys.argv[2]
archives = sys.argv[3]


env = Environ()
log.verbose()

env.io.atom_files_directory = []
env.io.atom_files_directory.append(archives)


######

# Give less weight to all soft-sphere restraints
env.schedule_scale = physical.Values(default=1.0, soft_sphere=0.7)

env.io.hetatm = True
                        #######
a=AutoModel(env,alnfile=ali_file,
            knowns=(template_name),sequence='AFB3', assess_methods=(assess.DOPE,assess.GA341))

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
