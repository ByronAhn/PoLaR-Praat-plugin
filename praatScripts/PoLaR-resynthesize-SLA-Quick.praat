################################################################
###  
### PoLaR-resynthesize-SLA-Quick
###
###		>> Please ensure you have Praat v.6.1 or greater
###
### Runs PoLaR-SLA-CORE.praat
### with the settings defined in PoLaR-resynthesize-SLA-Quick-Settings.praat
###
### For more information, see PoLaR-resynthesize-SLA-CORE.praat.
###
################################################################

include PoLaR-resynthesize-SLA-Quick-Settings.praat
include PoLaR-resynthesize-SLA-CORE.praat
@resynthMain

# Show resynthesized pitch with textgrid
selectObject: theResynth, theTg
View & Edit

# Play the sounds back to back
selectObject: theSound
Play
selectObject: theResynth
Play