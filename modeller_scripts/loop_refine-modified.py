# Loop refinement of an existing model
from modeller import *
from modeller.automodel import *

log.verbose()
env = Environ()

# directories for input atom files
env.io.atom_files_directory = ['.', '../atom_files']

env.io.hetatm = True #To get ligand into model

# Create a new class based on 'LoopModel' so that we can redefine
# select_loop_atoms (necessary)

#Modified LoopModel to DOPELoopModel in MyLoop argument
class MyLoop(DOPELoopModel):
    # This routine picks the residues to be refined by loop modeling
    def select_loop_atoms(self):
        # 10 residue insertion 
        return Selection(self.residue_range('344:A', '357:A'),
        		 self.residue_range('540:A', '549:A'))

modelo = 'AFB3.B99990016.pdb' #modelo.pdb a refinar
codigo = 'AFB3' #Codigo del target, i.e, AFB3       

m = MyLoop(env,
           inimodel = modelo, # initial model of the target
           sequence = codigo, # code of the target
           loop_assess_methods = (assess.DOPE, assess.GA341))

m.loop.starting_model= 1           # index of the first loop model 
m.loop.ending_model  = 400          # index of the last loop model
m.loop.md_level = refine.very_slow # loop refinement method; this yields
                                   # models quickly but of low quality;
                                   # use refine.slow for better models
                                   
#m.library_schedule = autosched.slow #Default is normal
#m.max_var_iterations = 300                                   

m.make()


