################################################################
###  
### Save-multiple-Sounds-Textgrids
### v.2021.08.05
###
### This script saves all selected Sound/Textgrid objects as .wav/.Textgrid files
### 
### 
### Instructions:
### 
###  In the Praat objects window, select all the Sound and/or TextGrid objects that you want to save
###       - In the "Save" menu, select whichever of the following menu items appears at the bottom: 
###       - "Save as .wav (multiple selected objects)"
###       - "Save as .Textgrid (multiple selected objects)"
###       - "Save as .wav/.Textgrid (multiple selected objects)"
###  You will be prompted for a save directory, and then all files will be saved
###       - If there are files with the same name in the directory, you will be warned and prompted about what to do
### 
### 
###	Byron Ahn
###	Attribution-ShareAlike 2.5 license
###
################################################################

overwriteALL=0

# Ask the user to select the directory for where to save
outDir$ = chooseDirectory$: "Choose the folder to save the .wav/.Textgrid files"
if right$(outDir$,1) <> "/" and right$(outDir$,1) <> "\"
	outDir$ = outDir$ + "/"
endif

@saveSelection

# Loop through the sounds
for x from 1 to saveSelection.numSavedSel
	selectObject: saveSelection.theSavedSel#[x]
	aName$ = selected$()
	if startsWith (aName$,"Sound")
		aName$ = replace$ (aName$, "Sound ", "", 0)
		saveme$ = outDir$ + aName$ + ".wav"
		if (fileReadable(saveme$)) and (not overwriteALL)
			beginPause: "WARNING"
			comment: "For Sound " + aName$ + ":"
			comment: "A file named " + aName$ +".wav already exists in this dir…"
			choice: "Resolution", 2
				option: "Skip this one"
				option: "Append '-new'"
				option: "Overwrite this one"
				option: "Overwrite ALL"
			endPause: "Continue", 1
			if resolution == 4
				overwriteALL = 1
			endif
			if resolution == 2
				saveme$ = outDir$ + aName$ + "-new.wav"
			endif
			if resolution >= 2
				Save as text file... 'saveme$'
			endif
		else 
			Save as WAV file... 'saveme$'
		endif
	elsif startsWith (aName$,"TextGrid")
		aName$ = replace$ (aName$, "TextGrid ", "", 0)
		saveme$ = outDir$ + aName$ + ".TextGrid"
		if (fileReadable(saveme$)) and (not overwriteALL)
			beginPause: "WARNING"
			comment: "For TextGrid " + aName$ + ":"
			comment: "A file named " + aName$ +".TextGrid already exists in this dir…"
			choice: "Resolution", 2
				option: "Skip this one"
				option: "Append '-new'"
				option: "Overwrite this one"
				option: "Overwrite ALL"
			endPause: "Continue", 1
			if resolution == 4
				overwriteALL = 1
			endif
			if resolution == 2
				saveme$ = outDir$ + aName$ + "-new.TextGrid"
			endif
			if resolution >= 2
				Save as text file... 'saveme$'
			endif
		else 
			Save as text file... 'saveme$'
		endif
	endif
	@returnSelection
endfor
@returnSelection

# --------------------
# 
#	Procedure returnSelection
#	(Used to re-open the previously bookmarked selection)
# 
# --------------------
procedure returnSelection
	if saveSelection.numSavedSel > 0
		selectObject: saveSelection.theSavedSel#
	endif
endproc


# --------------------
# 
#	Procedure saveSelection
#	(Used to bookmark which objects are currently selected)
# 
# --------------------
procedure saveSelection
	.numSavedSel = numberOfSelected()
	if .numSavedSel > 0
		.theSavedSel# = zero# (.numSavedSel)
		for x from 1 to .numSavedSel
			.theSavedSel# [x] = selected(x)
		endfor
	else
		.theSavedSel# = {0}
	endif
endproc