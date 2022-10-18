################################################################
###  
### PoLaR-Draw-Sound-and-TextGrid-Advanced
###
### Runs PoLaR-Draw-Sound-and-TextGrid-CORE.praat
### on a pair of selected Sound and TextGrid objects
### with settings elicited from the user.
###
### For more information, see PoLaR-Draw-Sound-and-TextGrid-CORE.praat.
###
################################################################

run_on_directory = 0

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

numLogs=0
#@logging: date$ () + newline$ + "Running script for extracting information from PoLaR labels to a .tsv file"
@drawMain