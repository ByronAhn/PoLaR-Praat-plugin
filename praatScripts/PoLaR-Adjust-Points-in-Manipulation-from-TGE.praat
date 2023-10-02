################################################################
###  
### PoLaR-Adjust-Points-in-Manipulation
###
###		>> Please ensure you have Praat v.6.1 or greater
###
### When a Sound object and a PoLaR-labelled TextGrid object
### (and a Pitch object) are selected, this script opens up a
### Manipulation window to allow the user to visually move 
### around the time/f0 coordinations of turning points, and it
### saves the changes back to the TextGrid
###
### This is heavily based on the logic of the Momel plugin,
### which can be accessed at this link:
### https://www.researchgate.net/publication/342039069_plugin_momel-intsint
### 
################################################################


include PoLaR-Adjust-Points-in-Manipulation-Settings.praat


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
Close
endeditor

sndObj = selected()
Rename: sndN$

# create PitchTier object:
@createPitchFromSound: sndObj, pitch_step
thePitch = createPitchFromSound.thePitch
@createPitchTierFromTG: sndObj, tgObj, thePitch
ptObj = createPitchTierFromTG.thePT

manipulate=1
@handEditPoints: sndObj, tgObj, ptObj

selectObject: thePitch, sndObj
Remove

@returnSelection

include PoLaR-praat-procedures.praat
