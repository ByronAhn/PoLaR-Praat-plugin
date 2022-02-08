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

numLogs=0
#@logging: date$ () + newline$ + "Running script for extracting information from PoLaR labels to a .tsv file"
@main