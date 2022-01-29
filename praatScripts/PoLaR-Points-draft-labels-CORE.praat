################################################################
###  
### PoLaR-Points-draft-labels-CORE
### v.2021.03.28
### 
### 
###  >>>>> IMPORTANT NOTE
###  >>>>> This script requires PRAAT VERSION 6.1.38 OR LATER (released Jan 2021)
### 
###
### This script creates "first-draft" labels for the Points tier, using Praat's built-in Pitch Stylizer.
### These labels should >>NOT<< be treated as final versions of PoLaR Points labels, and instead >>MUST<< be
### reviewed and revised by human labellers.
### 
### 
### Instructions:
###  To run from the Praat objects window, select at least one TextGrid object, to make "PoLaR Label Generators ▾" appear on the right
###       - Choose the appropriate script: "Points Labels DRAFT (Quick)" or "Points Labels DRAFT (Advanced)"
###       - When running the Quick version, the script loads with all the (Advanced) Pitch Settings parameters that are described in the PoLaR guidelines.
###       - When running the Advanced version, you can adjust settings manually.
###  To run from the View&Edit window,
### 
### 
### Results:
### 
### After running the script, the newly edited TextGrid file will be opened
###         > > >  NOTE  < < <
###  YOU MUST SAVE THE TEXTGRID MANUALLY!
###  The script itself does not save the TextGrid object it creates
###
### 
### Troubleshooting:
###  - Make sure your TextGrid file has one tier named "Points", with PoLaR labels
###       - If you have multiple tiers named "Points", this script will reference the last one
###       - If your Points tier is named something different (e.g., "Point", "Pnts", etc.), then the script MAY NOT find it
###  - Make sure your Points tier is labelled with Advanced PoLaR labels
###
###
###
### Byron Ahn
###	Attribution-ShareAlike 2.5 license
###
################################################################

# --------------------
# 
#	Procedure main
#	(The main function)
# 
# --------------------
procedure main
	@versionChecker: 6, 1, 38

	numLogs=0

	# Ensure that exactly one Sound object and one TextGrid object are selected
	if numberOfSelected () <> 2
		exitScript: "Select exactly one Sound file AND one TextGrid file"
	else
		origSoundName$ = selected$ ("Sound", 1)
		origTgName$ = selected$ ("TextGrid", 1)
		if origSoundName$ = ""
			exitScript: "You must select a Sound file"
		endif
		if origTgName$ = ""
			exitScript: "You must select a TextGrid file"
		endif
		origSound = selected ("Sound", 1)
		origTg = selected ("TextGrid", 1)
	endif

	selectObject: origTg
	@findPoLaRTiers: origTg
	if tierPoints > 0
		x = Get number of points: tierPoints
		if x > 0
			beginPause: "User input needed"
				comment: "Existing information on the Points tier will be deleted"
				comment: "Press 'Yes' below to confirm."
			clicked = endPause: "Yes", "No (Cancel)", 1, 2
			if clicked = 1
				Remove tier: tierPoints
				Insert point tier: tierPoints, "Points"
			else
				exit
			endif
		endif
	else
		tierPoints = Get number of tiers + 1
		Insert point tier: tierPoints, "Points"
		@findPoLaRTiers: origTg
	endif


	@findGlobalMinMax: origTg
	freqResolution = (hertzToSemitones(findGlobalMinMax.globalMax) - hertzToSemitones(findGlobalMinMax.globalMin))/5
	if freqResolution < 1.75
		freqResolution=1.75
	endif

	selectObject: origSound
	theManip = To Manipulation: 0.0025, findGlobalMinMax.globalMin, findGlobalMinMax.globalMax
	thePitch = Extract pitch tier
	Stylize: freqResolution, "semitones"

	selectObject: thePitch
	numPoints = Get number of points
	for x from 1 to numPoints
		selectObject: thePitch
		xTime = Get time from index: x
		selectObject: origTg
		Insert point: tierPoints, xTime, "0"
	endfor

	selectObject: theManip, thePitch
	Remove

	selectObject: origSound, origTg
endproc

include PoLaR-praat-procedures.praat


################################################################
###  
### end of PoLaR-Points-draft-labels-CORE
### 
################################################################