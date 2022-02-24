################################################################
###
### PoLaR-Blank-TextGrid-from-TGE
### v.2022.02.23
###
###
### This script creates TextGrids with blank PoLaR tiers
### 
### If the TextGrid has PoLaR tiers, it makes them blank
### 
### Instructions:
###  - Works from the TextGrid Editor window
###  - Choose "PoLaR: Blank PoLaR tiers" from the Tier menu
###  - You're done! You will have blank PoLaR tiers (replacing any PoLaR tiers that already existed)
###
###
###         > > >  NOTE  < < <
###
###  YOU MUST SAVE THE TEXTGRID MANUALLY!
###  The script itself does not save the TextGrid object it creates
###
###
###
###	Byron Ahn (bta@princeton.edu)
###	Attribution-ShareAlike 2.5 license
###
################################################################


@saveSelection

beginPause: "Confirm"
	comment: "Are you sure you want to remove all PoLaR labels?"
clicked = endPause: "Yes, Continue", 1

if clicked = 1
	@makeBlank
endif

procedure makeBlank:
	editorInfo$ = Editor info
	origTg = extractNumber(editorInfo$, "Editor name: ")
	endeditor
	selectObject: origTg

	@findPoLaRTiers: origTg

	numTiers = Get number of tiers

	if tierPrStr = 0
		tierPrStr=numTiers+1
		Insert point tier: tierPrStr, "PrStr"
		numTiers+=1
	else
		@findPoLaRTiers: origTg
		Remove tier: tierPrStr
		Insert point tier: tierPrStr, "PrStr"
	endif

	if tierPoints = 0
		tierPoints=tierPrStr+1
		Insert point tier: tierPoints, "Points"
		numTiers+=1
	else
		@findPoLaRTiers: origTg
		Remove tier: tierPoints
		tierPoints=tierPrStr+1
		Insert point tier: tierPoints, "Points"
	endif

	if tierLevels = 0
		tierLevels=tierPoints+1
		Insert point tier: tierLevels, "Levels"
		numTiers+=1
	else
		@findPoLaRTiers: origTg
		Remove tier: tierLevels
		tierLevels=tierPoints+1
		Insert point tier: tierLevels, "Levels"
	endif

	if tierRanges = 0
		tierRanges=tierLevels+1
		Insert interval tier: tierRanges, "Ranges"
		numTiers+=1
	else
		@findPoLaRTiers: origTg
		Remove tier: tierRanges
		tierRanges=tierLevels+1
		Insert interval tier: tierRanges, "Ranges"
	endif

	if tierMisc = 0
		tierMisc=tierRanges+1
		Insert point tier: tierMisc, "misc"
		numTiers+=1
	else
		@findPoLaRTiers: origTg
		Duplicate tier: tierMisc, tierRanges+1, "misc"
		@findPoLaRTiers: origTg
		Remove tier: tierMisc
	endif

	if tierSTLevels > 0
		@findPoLaRTiers: origTg
		Remove tier: tierSTLevels
	endif
	if tierPseudo > 0
		@findPoLaRTiers: origTg
		Remove tier: tierPseudo
	endif

	@returnSelection
endproc

include PoLaR-praat-procedures.praat



################################################################
###  
### end of PoLaR-Blank-TextGrid-from-TGE
### 
################################################################