################################################################
###
### PoLaR-TextGrid-for-Sound-from-TGE
### v.2023.09.13
###
###
### This script creates a blank TextGrid with PoLaR tiers for any selected Sounds
### 
### Instructions:
###  - Select at least one Sound file in the Praat objects window
###  - Click the button on the righthand side of the objects window, titled ""
###  - You're done!
###
###
###         > > >  NOTE  < < <
###
###  YOU MUST SAVE THE TEXTGRIDS MANUALLY!
###  The script itself does not save the TextGrid object it creates
###
###
###
###	Byron Ahn (bta@princeton.edu)
###	Attribution-ShareAlike 2.5 license
###
################################################################

# Cycle through each Sound object that is selected
@saveSelection

editorInfo$= Editor info
type$= extractWord$ (editorInfo$, "Data type:")

if type$ = "Sound"
	soundInfo$ = Sound info

	sndObj = extractNumber(editorInfo$, "Editor name: ")
	Close
	endeditor

	# create PoLaR TextGrid
	selectObject: sndObj
	tgObj = To TextGrid: "Words Phones PrStr Points Levels Ranges misc", "PrStr Points Levels misc"

	selectObject: tgObj, sndObj
	View & Edit

endif

@returnSelection

include PoLaR-praat-procedures.praat

################################################################
###  
### end of PoLaR-Blank-TextGrid
### 
################################################################