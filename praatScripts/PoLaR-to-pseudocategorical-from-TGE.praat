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

soundInfo$ = nocheck Sound info
if soundInfo$ == ""
	# being in here means that a LongSound has been loaded
	soundInfo$ = nocheck LongSound info
	sndLen = extractNumber(soundInfo$, "Duration: ")
	
	if soundInfo$ == ""
		# being in here means that no Sound/LongSound has been loaded
		beginPause: "ERROR"
			comment: "You can only run this command if a TextGrid and Sound object are opened together!"
		endPause: "Quit", 1, 1
		exitScript() 		
	endif
else
	# being in here means that a Sound has been loaded
	sndLen = extractNumber(soundInfo$, "End time: ")
endif

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

@pseudoLabelsMain

selectObject: sndObj
Remove

@returnSelection  