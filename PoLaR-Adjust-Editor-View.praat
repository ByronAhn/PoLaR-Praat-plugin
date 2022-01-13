################################################################
###
### PoLaR-Adjust-Editor-View
### v.2021.11.15
###
###
### This script adjusts the editor view, based on suggestions
### made in the PoLaR guidelines, as well as others that might
### optimize the viewer for editing
### 
### Instructions:
###  - From within an editor window, open the "Tier" menu
###  - Select "PoLaR: Automatic Editor View Settings"
###
###
###	Byron Ahn (bta@princeton.edu)
###	Attribution-ShareAlike 2.5 license
###
################################################################


################################################################
# Standard values below
################################################################
	fromTGE = 1
	use_Ranges = 0
	f0MinAnalysis = 65
	f0MaxAnalysis = 500
	time_step = 0.0025
	number_of_candidates = 15
	very_accurate = 1
	silence_threshold = 0.03
	voicing_threshold = 0.5
	octave_cost = 0.05
	octave_jump_cost = 0.5
	voice_unvoiced_cost = 0.2


################################################################
# If you want the pitch range to be adjusted according to the
# labels on the Ranges tier, leave this use_Ranges variable as
# set to 1. If you do NOT want the script to use the Ranges tier
# annotations, comment out this line
################################################################
	use_Ranges = 1


################################################################
# Find the best settings for the pitch min/max
################################################################
if use_Ranges = 1
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

	# take us to the object window commands
	endeditor
	Rename: sndN$
	@findPoLaRTiers: tgObj
	if tierRanges > 0
		@findGlobalMinMax: tgObj
		if findGlobalMinMax.globalMin <> 55
			temp = findGlobalMinMax.globalMin / 25
			@roundTo(temp, 0)
			temp = roundTo.result * 25 - 50
			if temp < 75
				f0MinAnalysis = 65
			else
				f0MinAnalysis = temp
			endif
		endif
		if findGlobalMinMax.globalMax <> 700
			temp = findGlobalMinMax.globalMax / 25
			@roundTo(temp, 0)
			temp = roundTo.result * 25 + 50
			f0MaxAnalysis = temp
		endif
	endif

	selectObject: tgObj, sndObj
	View & Edit

	# take us back to the editor commands
	editor
endif


################################################################
# Adjust the relevant editor settings
################################################################
Pitch settings: f0MinAnalysis, f0MaxAnalysis, "Hertz", "autocorrelation", "speckles"
Advanced pitch settings: 0.0, 0.0, very_accurate, number_of_candidates, silence_threshold, voicing_threshold, octave_cost, octave_jump_cost, voice_unvoiced_cost
Time step settings: "fixed", time_step, 100
Spectrogram settings: 0.0, 7000.0, 0.005, 40.0


################################################################
# Close
################################################################
if use_Ranges = 1
	endeditor

	selectObject: sndObj
	Remove

	@returnSelection
endif

include PoLaR-praat-procedures.praat


################################################################
###  
### end of PoLaR-Adjust-Editor-View
### 
################################################################