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

run_on_directory = 0

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

form Input Parameter Values
	comment Tick at least 1 box if you want to automatically save the drawing produced
	boolean save_as_pdf no
	boolean save_as_eps no
	boolean save_as_png no

	comment Settings for the analysis:
	boolean manual_advanced_pitch_settings no
	real startTime 0.0
	real endTime 0.0 (= all)
	positive spectrogram_settings_FreqMax 7000
	positive f0Min_(for_analysis) 75
	positive f0Max_(for_analysis) 450

	comment Settings for the drawing:
	positive width_of_entire_drawing 8
	positive height_of_the_pitch_track_and_spectrogram 1.5
	boolean draw_the_f0_contour yes	
	boolean let_the_script_determine_the_f0_draw_range yes
	boolean use_Ranges_tier_as_draw_range_(if_available) no
	integer y_axis_interval 50
	boolean mark_f0_intervals_on_the_axis yes
	boolean draw_the_spectrogram yes	
	positive spectrogram_dynamic_range 40
	comment Deselect the following will cause a menu to pop up:
	boolean draw_all_TextGrid_tiers yes
endform

include PoLaR-Draw-Sound-and-TextGrid-CORE.praat
endeditor

numLogs=0
#@logging: date$ () + newline$ + "Running script for extracting information from PoLaR labels to a .tsv file"
@drawMain


selectObject: sndObj
Remove