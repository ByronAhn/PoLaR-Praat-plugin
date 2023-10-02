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

@addMissingPoLaRTiersMain: origTg

@returnSelection


include PoLaR-TextGrid-Add-Missing-CORE.praat



################################################################
###  
### end of PoLaR-Blank-TextGrid
### 
################################################################