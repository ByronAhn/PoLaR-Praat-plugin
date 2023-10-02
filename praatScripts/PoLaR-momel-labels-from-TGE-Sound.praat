################################################################
###  
### PoLaR-momel-labels-from-TGE-Sound
###
###		>> Please ensure you have Praat v.6.1 or greater
###
### Runs PoLaR-rough-draft-CORE.praat from the TextGridEditor menu
###
### For more information, see PoLaR-momel-labels-CORE.praat.
###
################################################################

include PoLaR-momel-labels-Settings.praat
@saveSelection

editorInfo$= Editor info
type$= extractWord$ (editorInfo$, "Data type:")


if type$ = "Sound"
	soundInfo$ = Sound info
	sndN$ = extractWord$ (editorInfo$, "Object name: ")

	sndObj = extractNumber(editorInfo$, "Editor name: ")
	Close
	endeditor

	# create PoLaR TextGrid
	selectObject: sndObj
	tgObj = To TextGrid: "Words Phones PrStr Points Levels Ranges misc", "PrStr Points Levels misc"

	# initialize ptObj with a value of 0, so momelBasedLabelsMain will create one
	ptObj = 0
	
	selectObject: sndObj, tgObj
	@saveSelection

	# Now we can move onto the actual momel-based labelling:
	fromTGE=1
	manipulate=0

	@momelBasedLabelsMain: sndObj, sndN$, tgObj, ptObj

	selectObject: tgObj, sndObj
	View & Edit

endif


@returnSelection

include PoLaR-momel-labels-CORE.praat
include PoLaR-praat-procedures.praat