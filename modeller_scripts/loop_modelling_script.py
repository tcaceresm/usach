from modeller import *
from modeller.automodel import *
class MyLoop(LoopModel):
    # This routine picks the residues to be refined by loop modeling
    def select_loop_atoms(self):
        # Two residue ranges (both will be refined simultaneously)
        return Selection(self.residue_range('7:A', '12:A'),
                         self.residue_range('197:B', '202:B'),
                         self.residue_range('387:C', '392:C'),
                         self.residue_range('577:D', '582:D'),
                         self.residue_range('767:E', '772:E'),
                         self.residue_range('957:F', '962:F'),
                         self.residue_range('1147:G', '1152:G'),
                         self.residue_range('1337:H', '1342:H'),
                         self.residue_range('1527:I', '1532:I'),
                         self.residue_range('1717:J', '1722:J'),
                         self.residue_range('1907:K', '1912:K'),
                         self.residue_range('2097:L', '2192:L'),
                         self.residue_range('2287:M', '2292:M'),
                         self.residue_range('2477:N', '2482:N'),
                         )
