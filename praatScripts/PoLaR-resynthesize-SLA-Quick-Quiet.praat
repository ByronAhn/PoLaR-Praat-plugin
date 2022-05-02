################################################################
###  
### PoLaR-resynthesize-SLA-Quick-Quiet
###
###		>> Please ensure you have Praat v.6.1 or greater
###
### Runs PoLaR-SLA-CORE.praat
### with the settings defined in PoLaR-resynthesize-SLA-Quick-Settings.praat
### and without playing the original and resynthesized sounds back-to-back
###
### For more information, see PoLaR-resynthesize-SLA-CORE.praat.
###
################################################################

include PoLaR-resynthesize-SLA-Quick-Settings.praat
include PoLaR-resynthesize-SLA-CORE.praat
@pseudoMain

# Show resynthesized pitch with textgrid
selectObject: theResynth, theTg
View & Edit