################################################################
###  
### PoLaR-to-pseudocategorical-Quick
###
###		>> Please ensure you have Praat v.6.1.38 or greater
###
### Runs PoLaR-to-pseudocategorical-CORE.praat
### with the settings that are input by the user
###
### For more information, see PoLaR-to-pseudocategorical-CORE.praat.
###
################################################################

form Pitch settings for straight line approximations
	comment Do you want to create a new TextGrid with these Levels labels?
	boolean new_TextGrid_file_in_Object_List 0
	comment ===================================================================
	comment Which units of frequency do you want to use to determine Levels labels?
	boolean use_Raw_Hz 1
	boolean use_Semitones 0
	comment ===================================================================
	comment Praat (Advanced) Pitch Settings:
	real time_step 0.0025
	integer number_of_candidates 15
	boolean very_accurate 1
	real silence_threshold 0.03
	real voicing_threshold 0.5
	real octave_cost 0.05
	real octave_jump_cost 0.5
	real voice_unvoiced_cost 0.2
	comment NOTE: f0 min and f0 max are set locally, by the Range tier labels
endform
include PoLaR-Levels-labeller-CORE.praat
viewandedit=1
@main