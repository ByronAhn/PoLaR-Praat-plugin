################################################################
###  
### PoLaR-Draw-Sound-and-TextGrid-from-TGE-Adv
###
### Runs PoLaR-Draw-Sound-and-TextGrid-CORE.praat
### on a TextGrid-Sound pair that is open in the View & Edit window
### with settings elicited from the user.
###
### For more information, see PoLaR-Draw-Sound-and-TextGrid-CORE.praat.
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
endeditor
Rename: sndN$

selectObject: tgObj, sndObj

form Input Parameter Values

	comment Tick at least 1 box if you want to automatically save the drawing produced
	boolean save_as_pdf no
	boolean save_as_eps no
	boolean save_as_png no

	comment If you deselect this option, a menu will pop up asking which tiers you want to include:
	boolean draw_all_TextGrid_tiers no

	comment Settings for the analysis:
	boolean manual_advanced_pitch_settings no
	real startTime 0.0
	real endTime 0.0 (= all)
	positive spectrogram_settings_FreqMax 7000
	positive spectrogram_dynamic_range 40
	positive f0Min_(for_analysis) 75
	positive f0Max_(for_analysis) 450

	comment Settings for the drawing:
	comment Use these f0 analysis settings as the draw window range?
	boolean use_this_f0_range_as_draw_range no
	comment Use Ranges tier annotations to set the draw window range (overriding 
	comment the f0min/max above)?
	boolean use_Ranges_tier_as_draw_range yes
	positive width_of_entire_drawing 8
	positive height_of_the_pitch_track_and_spectrogram 1.5
	integer y_axis_interval 50
	boolean mark_f0_intervals_on_the_axis yes
endform

include PoLaR-Draw-Sound-and-TextGrid-CORE.praat
endeditor

numLogs=0
#@logging: date$ () + newline$ + "Running script for extracting information from PoLaR labels to a .tsv file"
@main


selectObject: sndObj
Remove