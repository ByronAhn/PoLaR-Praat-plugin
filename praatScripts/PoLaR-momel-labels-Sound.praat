################################################################
###  
### PoLaR-momel-labels-Sound
###
###		>> Please ensure you have Praat v.6.1 or greater
###
### Runs PoLaR-rough-draft-CORE.praat from the Objects window
###
### For more information, see PoLaR-momel-labels-CORE.praat.
###
################################################################

include PoLaR-momel-labels-Settings.praat

fromTGE=0
manipulate=0

@saveSelection
sounds = numberOfSelected ("Sound")

# Ensure that exactly one Sound object and one TextGrid object (and maybe one additional PitchTier object) are selected
for z to sounds
	sndN$ = selected$ ("Sound", z)
	sndObj = selected ("Sound", z)

	# create PoLaR TextGrid
	selectObject: sndObj
	tgObj = To TextGrid: "Words Phones PrStr Points Levels Ranges misc", "PrStr Points Levels misc"

	# initialize ptObj with a value of 0, but overwrite it with a PitchTier object if one is selected
	ptObj = 0
	if (numberOfSelected("PitchTier")=1)
		ptObj = selected ("PitchTier", 1)
	endif
	
	# Now we can move onto the actual momel-based labelling:
	@momelBasedLabelsMain: sndObj, sndN$, tgObj, ptObj

	selectObject: momelBasedLabelsMain.thePT
	Remove
	
	@returnSelection
endfor




include PoLaR-momel-labels-CORE.praat
include PoLaR-praat-procedures.praat

newFiles$ = string$(sounds)
if fromTGE <> 1
	@logging: ">> Finished!"
	@logging: ">>>> The Objects window now has " + newFiles$ + " new PoLaR TextGrid objet(s) with Momel-based labels"
endif