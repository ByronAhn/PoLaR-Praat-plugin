################################################################
###
### PoLaR-Add-Missing
### v.2022.10.19
###
###
### This script adds any PoLaR tiers that are missing from TextGrids
### 
### Instructions:
###  - In an editor window with a TextGrid open, select the Tiers menu
###  - Choose "PoLaR: Add Missing PoLaR Tiers"
###  - You're done! For any PoLaR tiers that were missing before, you will now have blank tiers 
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

# Cycle through each TextGrid object that is selected
@saveSelection

editorInfo$ = Editor info
origTg = extractNumber(editorInfo$, "Editor name: ")
endeditor
selectObject: origTg
tgName$ = selected$ ("TextGrid", 1)

@findPoLaRTiers: origTg
numTiers = Get number of tiers

if tierPrStr = 0
	tierPrStr=numTiers+1
	Insert point tier: tierPrStr, "PrStr"
	numTiers+=1
endif

if tierPoints = 0
	tierPoints=tierPrStr+1
	Insert point tier: tierPoints, "Points"
	numTiers+=1
endif

if tierLevels = 0
	tierLevels=tierPoints+1
	Insert point tier: tierLevels, "Levels"
	numTiers+=1
endif

if tierRanges = 0
	tierRanges=tierLevels+1
	Insert interval tier: tierRanges, "Ranges"
	numTiers+=1
endif

if tierMisc = 0
	tierMisc=tierRanges+1
	Insert point tier: tierMisc, "misc"
	numTiers+=1
endif

@returnSelection


include PoLaR-praat-procedures.praat



################################################################
###  
### end of PoLaR-Blank-TextGrid
### 
################################################################