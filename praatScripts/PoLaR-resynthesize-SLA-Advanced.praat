################################################################
###  
### PoLaR-resynthesize-SLA-Advanced
###
###		>> Please ensure you have Praat v.6.1 or greater
###
### Runs PoLaR-SLA-CORE.praat
### with the settings that are input by the user
###
### For more information, see PoLaR-resynthesize-SLA-CORE.praat.
###
################################################################

form Pitch settings for straight line approximations
		comment Do you want to use Ranges tier annotations to override the f0Min/Max below?
		boolean use_Ranges_tier_(if_available) 1
		comment Do you want to play the original and resynthesized sounds, back to back?
		boolean play_sound_files_to_compare 1
		comment ===================================================================
		comment How much of the file would you like to resynthesize?
		comment (Put times in seconds, 0.0 for both values resynthesizes the entire file)
		real start_Time 0.0
		real end_Time 0.0
		comment ===================================================================
		comment Praat (Advanced) Pitch Settings:
		positive f0Min 75
		positive f0Max 500
		real time_step_(0.0_=_auto): 0.0025
		integer number_of_candidates 15
		boolean very_accurate 1
		positive silence_threshold 0.03
		positive voicing_threshold 0.5
		positive octave_cost 0.05
		positive octave_jump_cost 0.5
		positive voice_unvoiced_cost 0.2
endform

include PoLaR-resynthesize-SLA-CORE.praat
@main

# Show resynthesized pitch with textgrid
selectObject: theResynth, theTg
View & Edit

# Play the sounds back to back, if the option is selected
if play_sound_files_to_compare
	selectObject: theSound
	Play
	selectObject: theResynth
	Play
endif