################################################################
###  
### PoLaR-Advanced-to-Basic-Custom
###
###		>> Please ensure you have Praat v.6.1 or greater
###
### Runs PoLaR-Advanced-to-Basic-CORE.praat.
### with the user deciding which tiers to convert
###
### For more information, see PoLaR-Advanced-to-Basic-CORE.praat.
###
################################################################

form Convert tiers to basic labels
	comment Which tiers do you want to convert to basic labels?
	boolean make_PrStr_Basic 1
	boolean make_Points_Basic 1
	boolean make_Ranges_Basic 1
endform
include PoLaR-Advanced-to-Basic-CORE.praat