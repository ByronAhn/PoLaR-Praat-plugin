################################################################
###  
### PoLaR-momel-labels-from-ObjectWin
###
###		>> Please ensure you have Praat v.6.1 or greater
###
### Runs PoLaR-rough-draft-CORE.praat from the Objects window
###
### For more information, see PoLaR-momel-labels-CORE.praat.
###
################################################################

include PoLaR-momel-labels-Settings.praat

# Ensure that exactly one Sound object and one TextGrid object (and maybe one additional PitchTier object) are selected
if ((numberOfSelected("TextGrid") + numberOfSelected("Sound") = 2) & (numberOfSelected("Sound")=1))
	# being in here should mean that 1 sound object and 1 textgrid object are selected (maybe among other objects)
	
	sndN$ = selected$ ("Sound", 1)
	tgN$ = selected$ ("TextGrid", 1)
	
	# store the Sound and TextGrid objects
	sndObj = selected ("Sound", 1)
	tgObj = selected ("TextGrid", 1)

	# initialize ptObj with a value of 0, but overwrite it with a PitchTier object if one is selected
	ptObj = 0
	if (numberOfSelected("PitchTier")=1)
		ptObj = selected ("PitchTier", 1)
	endif
	
	# backup the original textgrid file
	selectObject: tgObj
	tgBkup$ = tgN$ + "-bkup"
	Copy: tgBkup$
	selectObject: sndObj, tgObj
	@saveSelection

else
	exitScript: "Select one Sound file AND one TextGrid file (and one optional PitchTier file)."

endif



# Now we can move onto the actual momel-based labelling:
include PoLaR-momel-labels-CORE.praat
include PoLaR-praat-procedures.praat
fromTGE=0
manipulate=1


@momelBasedLabelsMain: sndObj, sndN$, tgObj, ptObj


@returnSelection

if fromTGE <> 1
	if (ptObj = 0)
		howmanyObjs$ = "two new objects were"
		newObjs$ = ">>>> (1) a backup of the original TextGrid" + newline$ + ">>>> (2) a PitchTier object with a straight-line approximation"
	else
		howmanyObjs$ = "one new object was"
		newObjs$ = ">>>> a backup of the original TextGrid"
	endif
	@logging: newline$ + ">> Finished! The Sound and updated TextGrid are currently selected in the Objects window."
	@logging: ">>>> In addition, " + howmanyObjs$ + " added to the Objects window, namely:" + newline$ + newObjs$ 
endif