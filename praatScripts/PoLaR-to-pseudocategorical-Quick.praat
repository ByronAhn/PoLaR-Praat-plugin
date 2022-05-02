################################################################
###  
### PoLaR-to-pseudocategorical-Quick
###
###		>> Please ensure you have Praat v.6.1.38 or greater
###
### Runs PoLaR-to-pseudocategorical-CORE.praat
### with the settings defined in PoLaR-to-pseudocategorical-Quick-Settings.praat
###
### For more information, see PoLaR-to-pseudocategorical-CORE.praat.
###
################################################################

include PoLaR-to-pseudocategorical-Quick-Settings.praat
include PoLaR-to-pseudocategorical-CORE.praat

# Cycle through each TextGrid object that is selected
@saveSelection
for z to numberOfSelected ("TextGrid")
	tgName$ = selected$ ("TextGrid", z)
	origTg = selected ("TextGrid", z)
	selectObject: origTg

	@pseudoLabelsMain

	@returnSelection
endfor