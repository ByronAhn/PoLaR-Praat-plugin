################################################################
###  
### PoLaR-resynthesize-SLA-listen-from-TGE
###
###		>> Please ensure you have Praat v.6.1 or greater
###
### Runs PoLaR-SLA-CORE.praat
### with the settings defined in PoLaR-resynthesize-SLA-Quick-Settings.praat
### and without playing the original and resynthesized sounds back-to-back.
### This is run from the TextGridEditor menu.
###
### For more information, see PoLaR-resynthesize-SLA-CORE.praat.
###
################################################################

@saveSelection

# First we need to select the TextGrid and Sound objects that are open in the TextGridEditor.
# This works in a weird way: Praat loads a TextGrid and Sound in the "View & Edit" window by loading the TextGrid directly,
# but the Sound object is a copy of the original Sound object. (So the original Sound object cannot be referred to directly.)
# To get around this (in case the relevant Sound object is not currently selected), this script selects the entire Sound file
# and extracts it to the Objects window. So the TextGrid that is used by this script is the original, and the Sound object
# that is used is a copy.

soundInfo$= Sound info
sndN$ = extractWord$ (soundInfo$, "Object name: ")
editorInfo$= Editor info
tgObj = extractNumber(editorInfo$, "Editor name: ")
sndLen = extractNumber(editorInfo$, "Editor end: ")
Select: 0.0, sndLen
Extract selected sound (time from 0)
sndObj = selected()
endeditor
Rename: sndN$
selectObject: tgObj, sndObj


# Now we can move onto the actual labelling:

include PoLaR-resynthesize-SLA-Quick-Settings.praat
include PoLaR-resynthesize-SLA-CORE.praat
@pseudoMain

selectObject: sndObj
Play
selectObject: theResynth
Play

selectObject: sndObj
Remove

@returnSelection