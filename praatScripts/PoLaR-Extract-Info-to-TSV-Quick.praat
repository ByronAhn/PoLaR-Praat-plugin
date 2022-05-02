################################################################
###  
### PoLaR-Extract-Info-to-TSV-Quick
###
###		>> Please ensure you have Praat v.6.1 or greater
###
### Runs PoLaR-Extract-Info-to-TSV-CORE.praat
### with the settings defined in PoLaR-Extract-Info-to-TSV-Quick-Settings.praat
### on a pair of selected Sound and TextGrid objects.
###
### For more information, see PoLaR-Extract-Info-to-TSV-CORE.praat.
###
################################################################

include PoLaR-Extract-Info-to-TSV-Quick-Settings.praat
include PoLaR-Extract-Info-to-TSV-CORE.praat

numLogs=0
@logging: date$ () + newline$ + "Running script for extracting information from PoLaR labels to a .tsv file"
@extractInfoMain