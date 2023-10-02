################################################################
###
### PoLaR-Add-Missing.CORE
### v.2023.09.10
###
###
### This script adds any PoLaR tiers that are missing from TextGrids
###
###
###
###	Byron Ahn (bta@princeton.edu)
###	Attribution-ShareAlike 2.5 license
###
################################################################


procedure addMissingPoLaRTiersMain: .tg
	.anyChanges = 0
	@findPoLaRTiers: .tg
	numTiers = Get number of tiers

	if tierPrStr = 0
		.anyChanges = 1
		tierPrStr=numTiers+1
		Insert point tier: tierPrStr, "PrStr"
		numTiers+=1
	endif

	if tierPoints = 0
		.anyChanges = 1
		tierPoints=tierPrStr+1
		Insert point tier: tierPoints, "Points"
		numTiers+=1
	endif

	if tierLevels = 0
		.anyChanges = 1
		tierLevels=tierPoints+1
		Insert point tier: tierLevels, "Levels"
		numTiers+=1
	endif

	if tierRanges = 0
		.anyChanges = 1
		tierRanges=tierLevels+1
		Insert interval tier: tierRanges, "Ranges"
		numTiers+=1
	endif

	if tierMisc = 0
		.anyChanges = 1
		tierMisc=tierRanges+1
		Insert point tier: tierMisc, "misc"
		numTiers+=1
	endif
endproc


include PoLaR-praat-procedures.praat



################################################################
###  
### end of PoLaR-Blank-TextGrid
### 
################################################################