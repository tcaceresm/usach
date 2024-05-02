# Comparative modeling with multiple templates
from modeller import *              # Load standard Modeller classes
from modeller.automodel import *    # Load the AutoModel class

log.verbose()    # request verbose output
env = Environ()  # create a new MODELLER environment to build this model in

# directories for input atom files
env.io.atom_files_directory = ['.']


env.io.hetatm = True


a = AutoModel(env,
              alnfile  = 'TIRs_AFB3_modeller_input', # alignment filename
              knowns   = ('2p1m', '2p1p', '2p1q', '2p1n', '2p1o'),     # codes of the templates
              sequence = 'AFB3',
              assess_methods=(assess.DOPE,assess.GA341))               # code of the target

a.deviation = 4.0           #controls the amount of randomization done by randomize.xyz

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




a.starting_model= 1                 # index of the first model
a.ending_model  = 20                # index of the last model
                                    # (determines how many models to calculate)
a.make()                            # do the actual comparative modeling

#Get a list of all successfully built models from a.outputs

ok_models = [x for x in a.outputs if x['failure'] is None]

#Rank the models by DOPE score
key = 'DOPE score'
ok_models.sort(key=lambda a: a[key])

#Get top model

m = ok_models[0]
print("Top model: %s (DOPE score %.3f)" % (m['name'], m[key]))