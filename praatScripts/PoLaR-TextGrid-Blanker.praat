################################################################
###
### PoLaR-TextGrid-Blanker
### v.2021.08.05
###
###
### This script creates TextGrids with blank PoLaR tiers,
### preserving the information on the Words and Phones tiers, but DELETING ALL OTHER TIERS ENTIRELY.
### 
### If the TextGrid has PoLaR tiers, it makes them blank
### 
### Instructions:
###  - Select at least one TextGrid file in the Praat objects window
###  - Click the button on the righthand side of the objects window, titled "PoLaR TextGrids ▾"
###  - Choose "Blank PoLaR Tiers"
###  - You're done! You will only have the original Words and Phones tiers, plus blank PoLaR tiers
###    (replacing any PoLaR tiers that already existed, and deleting all others)
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

beginPause: "User input needed"
	comment: "Are you sure??"
	comment: "Note that ALL TIERS (except Words and Phones tiers) will be removed,"
	comment: "and blank PoLaR tiers will be added."
clicked = endPause: "Yes", "No (Cancel)", 1, 2
if clicked = 2
	exit
endif

# Cycle through each TextGrid object that is selected
@saveSelection
for z to numberOfSelected ("TextGrid")
	tgName$ = selected$ ("TextGrid", z)
	origTg = selected ("TextGrid", z)
	selectObject: origTg

	@findPoLaRTiers: origTg

	numTiers = Get number of tiers
	numRemoved = 0

	for x from 1 to numTiers
		y = x-numRemoved
		if (tierWords-numRemoved <> y) and (tierPhones-numRemoved <> y)
			Remove tier: y
			numRemoved = numRemoved + 1
		endif
	endfor

	tierOffset = 0
	if tierWords > 0
		tierOffset += 1
	endif
	if tierPhones > 0
		tierOffset += 1
	endif


	Insert point tier: tierOffset+1, "PrStr"
	Insert point tier: tierOffset+2, "Points"
	Insert point tier: tierOffset+3, "Levels"
	Insert interval tier: tierOffset+4, "Ranges"
	Insert point tier: tierOffset+5, "misc"

	@returnSelection
endfor



include PoLaR-praat-procedures.praat



################################################################
###  
### end of PoLaR-TextGrid-Blanker
### 
################################################################