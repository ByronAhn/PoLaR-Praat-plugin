################################################################
###  
### PoLaR-to-pseudocategorical-from-TGE
###
###		>> Please ensure you have Praat v.6.1 or greater
###
### Runs PoLaR-to-pseudocategorical-CORE.praat
### with the settings defined in PoLaR-to-pseudocategorical-Quick-Settings.praat.
### This is run from the TextGridEditor menu, and does not open a new View & Edit window after running
###
### For more information, see PoLaR-to-pseudocategorical-CORE.praat.
###
################################################################

@saveSelection

editorInfo$ = Editor info
tgObj = extractNumber(editorInfo$, "Editor name: ")
tgLen = extractNumber(editorInfo$, "Editor end: ")
Select: 0.0, tgLen

soundInfo$ = Sound info

# I CAN'T FIGURE OUT HOW TO CATCH AN ERROR WHEN THE SOUND IS NOT LOADED
#if "soundInfo$" = "xxx"
#	beginPause: "ERROR"
#		comment: "To run this command the TextGrid and Sound must be opened **together**!"
#	endPause: "Quit", 1, 1
#	exitScript() 
#endif

Extract selected sound (time from 0)
sndN$ = extractWord$ (soundInfo$, "Object name: ")
sndObj = selected()
endeditor
Rename: sndN$

selectObject: tgObj
endeditor
include PoLaR-to-pseudocategorical-CORE.praat
fromTGE=1 
viewandedit=0
new_TextGrid_file_in_Object_List=0

@main

selectObject: sndObj
Remove

@returnSelection  