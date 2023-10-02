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

# Ensure that exactly one Sound object and one TextGrid object (and maybe one additional PitchTier object) are selected
if ((numberOfSelected("TextGrid") + numberOfSelected("Sound") = 2) & (numberOfSelected("Sound")=1))
	# being in here should mean that 1 sound object and 1 textgrid object are selected
	
	# store the Sound and TextGrid objects
	sndObj = selected ("Sound", 1)
	tgObj = selected ("TextGrid", 1)

	# if there is one selected PitchTier as well, store it; otherwise create one and store it
	if (numberOfSelected("PitchTier")=1)
		ptObj = selected ("PitchTier", 1)
	else
		@createPitchFromSound: sndObj, pitch_step
		thePitch = createPitchFromSound.thePitch

		@createPitchTierFromTG: sndObj, tgObj, thePitch
		ptObj = createPitchTierFromTG.thePT
	endif
	
else
	exitScript: "Select one Sound file AND one TextGrid file (and one optional PitchTier file)."

endif

@handEditPoints: sndObj, tgObj, ptObj

selectObject: thePitch
Remove

include PoLaR-praat-procedures.praat
manipulate=1