from modeller import *
from modeller.scripts import complete_pdb

log.verbose()    # request verbose output
env = Environ()
env.libs.topology.read(file='$(LIB)/top_heav.lib') # read topology
env.libs.parameters.read(file='$(LIB)/par.lib') # read parameters

# directories for input atom files
env.io.atom_files_directory = './'

# read template pdb file

template_pdb = '2p1m_B.pdb'

mdl = complete_pdb(env, template_pdb, model_segment=('FIRST:@', 'END:'))

s = Selection(mdl)
s.assess_dope(output='ENERGY_PROFILE NO_REPORT', file=template_pdb.replace('pdb', 'profile'),
              normalize_profile=True, smoothing_window=15)
