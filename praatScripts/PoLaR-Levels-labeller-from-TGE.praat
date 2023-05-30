################################################################
###  
### PoLaR-Levels-labeller-from-TGE
###
###		>> Please ensure you have Praat v.6.1 or greater
###
### Runs PoLaR-Levels-labeller-CORE.praat
### with the settings defined in PoLaR-Levels-labeller-Quick-Settings.praat.
### This is run from the TextGridEditor menu, and does not open a new View & Edit window after running
###
### For more information, see PoLaR-Levels-labeller-CORE.praat.
###
################################################################

@saveSelection

# First we need to select the TextGrid and Sound objects that are open in the TextGridEditor.
# This works in a weird way: Praat loads a TextGrid and Sound in the "View & Edit" window by loading the TextGrid directly,
# but the Sound object is a copy of the original Sound object. (So the original Sound object cannot be referred to directly.)
# To get around this (in case the relevant Sound object is not currently selected), this script selects the entire Sound file
# and extracts it to the Objects window. So the TextGrid that is used by this script is the original, and the Sound object
# that is used is a copy.

editorInfo$= Editor info
tgObj = extractNumber(editorInfo$, "Editor name: ")

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

sndN$ = extractWord$ (soundInfo$, "Object name: ")
Select: 0.0, sndLen
Extract selected sound (time from 0)
sndObj = selected()
endeditor
Rename: sndN$

selectObject: tgObj, sndObj


# Now we can move onto the actual labelling:

include PoLaR-Levels-labeller-Quick-Settings.praat
include PoLaR-Levels-labeller-CORE.praat
fromTGE=1 
viewandedit=0
@levelsLabellerMain

selectObject: sndObj
Remove

@returnSelection