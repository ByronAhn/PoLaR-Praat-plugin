################################################################
###  
### PoLaR-Draw-Sound-and-TextGrid-Quick
###
### Runs PoLaR-Draw-Sound-and-TextGrid-CORE.praat
### with the settings defined in PoLaR-Draw-Sound-and-TextGrid-Quick-Settings.praat
### on a pair of selected Sound and TextGrid objects.
###
### For more information, see PoLaR-Draw-Sound-and-TextGrid-CORE.praat.
###
################################################################

include PoLaR-Draw-Sound-and-TextGrid-Quick-Settings.praat
include PoLaR-Draw-Sound-and-TextGrid-CORE.praat

numLogs=0
#@logging: date$ () + newline$ + "Running script for extracting information from PoLaR labels to a .tsv file"
@drawMain