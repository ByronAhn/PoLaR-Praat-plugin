################################################################
###  
### PoLaR-momel-labels-from-TGE
###
###		>> Please ensure you have Praat v.6.1 or greater
###
### Runs PoLaR-rough-draft-CORE.praat from the TextGridEditor menu
###
### For more information, see PoLaR-momel-labels-CORE.praat.
###
################################################################

include PoLaR-momel-labels-Settings.praat
@saveSelection

# First we need to select the TextGrid and Sound objects that are open in the TextGridEditor.
# This works in a weird way: Praat loads a TextGrid and Sound in the "View & Edit" window by loading the TextGrid directly,
# but the Sound object is a copy of the original Sound object. (So the original Sound object cannot be referred to directly.)
# To get around this (in case the relevant Sound object is not currently selected), this script selects the entire Sound file
# and extracts it to the Objects window. So the TextGrid that is used by this script is the original, and the Sound object
# that is used is a copy.

editorInfo$= Editor info
tgObj = extractNumber(editorInfo$, "Editor name: ")

soundInfo$= Sound info
sndLen = extractNumber(soundInfo$, "End time: ")
if sndLen = undefined
	beginPause: "ERROR"
		comment: "You can only run this command if a TextGrid and Sound object are opened together!"
	endPause: "Quit", 1, 1
	exitScript() 
endif
sndN$ = extractWord$ (soundInfo$, "Object name: ")
Select: 0.0, sndLen
Extract selected sound (time from 0)
sndObj = selected()
Close
endeditor
Rename: sndN$

selectObject: tgObj
tgN$ = selected$("TextGrid")
tgBkup$ = tgN$ + "-bkup"
Copy: tgBkup$

selectObject: tgObj, sndObj


# Now we can move onto the actual momel-based labelling:

include PoLaR-momel-labels-CORE.praat
include PoLaR-praat-procedures.praat
fromTGE=1 
manipulate=1


@momelBasedLabelsMain: sndObj, sndN$, tgObj, 0


selectObject: sndObj
Remove


@returnSelection