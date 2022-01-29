################################################################
###  
### PoLaR-pseudo-to-slopes
### v.2021.12.05
###

### 
### 
###
###	Byron Ahn
###	Attribution-ShareAlike 2.5 license
###
################################################################


include PoLaR-pseudo-to-slopes-Quick-Settings.praat
include PoLaR-pseudo-to-slopes-CORE.praat

create_A_Single_Output_File = 0
outToFile = 0
numLogs=0
@logging: date$ () + newline$ + "Running script for extracting information from PoLaR Pseudo labels to a .tsv file"
@main