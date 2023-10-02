################################################################
###
### PoLaR-Add-Missing
### v.2023.09.10
###
###
### This script adds any PoLaR tiers that are missing from TextGrids
### 
### Instructions:
###  - Select at least one TextGrid file in the Praat objects window
###  - Click the button on the righthand side of the objects window, titled "Modify/Inspect PoLaR TextGrids ▾"
###  - Choose "Add Missing PoLaR Tiers"
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

for z to numberOfSelected ("TextGrid")
	origTg = selected ("TextGrid", z)

	@addMissingPoLaRTiersMain: origTg

	@returnSelection
endfor


include PoLaR-TextGrid-Add-Missing-CORE.praat



################################################################
###  
### end of PoLaR-Blank-TextGrid
### 
################################################################