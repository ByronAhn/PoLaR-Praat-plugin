################################################################
###  
### PoLaR-Adjust-Points-in-Manipulation-dir
###
###		>> Please ensure you have Praat v.6.1.38 or greater
###
### Same functionality as PoLaR-Adjust-Points-in-Manipulation
### but operates on all files in a directory
###
### This is heavily based on the logic of the Momel plugin,
### which can be accessed at this link:
### https://www.researchgate.net/publication/342039069_plugin_momel-intsint
### 
################################################################

# fileNames$# is a function that wasn't defined until 6.1.38
@versionChecker: 6, 1, 38

include PoLaR-Adjust-Points-in-Manipulation-Settings.praat

@saveSelection

fromTGE=0
saveToDir=1
numUnmatchedWav = 0
numWarnings = 0
numLabelled = 0
numLogs = 0


# get directory / directory listing
beginPause: "Where are your .wav + .Textgrid (+ .PitchTier) files?"
	comment: "Hit the ""Choose Folder"" button to select the with your .wav and .Textgrid"
	comment: "(and .PitchTier) files, to hand-correct PoLaR Points labels audio-visually."
endPause: "Choose Folder", 1
inDir$ = chooseDirectory$: "Choose the folder with files"
if right$(inDir$,1) <> "/" and right$(inDir$,1) <> "\"
	inDir$ = inDir$ + "/"
endif

theFiles$ = inDir$ + "*.*"

listOfFiles$# = fileNames$#: theFiles$

# run a for-loop, for each .wav file

for xF from 1 to size(listOfFiles$#)
	aFilename$ = listOfFiles$#[xF]

	# target .wav files (regardless of capitalization)
	extensionDotLoc = rindex(aFilename$, ".")
	baseFilename$ = left$(aFilename$, extensionDotLoc-1)
	extension$ = right$(aFilename$, length(aFilename$)-extensionDotLoc)
	lowercaseExtension$ = replace_regex$ (extension$, "[A-Z]", "\L&", 0)

	if lowercaseExtension$ = "wav"
		wavFilename$ = aFilename$
		sndObj = Read from file: inDir$ + aFilename$

		# try to open a .Textgrid file of the same name
		tgFile$ = inDir$ + baseFilename$ + ".Textgrid"
		if fileReadable(tgFile$)
			tgObj = Read from file: tgFile$

			# try to open a .PitchTier file of the same name
			ptFile$ = inDir$ + baseFilename$ + ".PitchTier"
			if fileReadable(ptFile$)
				ptObj = Read from file: ptFile$
			else
				@createPitchFromSound: sndObj, pitch_step
				thePitch = createPitchFromSound.thePitch
				@createPitchTierFromTG: sndObj, tgObj, thePitch
				ptObj = createPitchTierFromTG.thePT
			endif
			
			# getting here means there are Textgrid and PitchTier objects for the Wav file
			@handEditPoints: sndObj, tgObj, ptObj
			
			selectObject: handEditPoints.theTg
			Save as text file: tgFile$
			
			selectObject: handEditPoints.thePT
			Save as text file: ptFile$			

			selectObject: handEditPoints.theSnd, handEditPoints.theTg, handEditPoints.thePT
			Remove

		# this else statement runs when there is no matching .Textgrid file
		# it stores the name of the .wav file and reports it to the user at the end
		else
			numUnmatchedWav += 1
			unmatchedWav$ [numUnmatchedWav] = wavFilename$
		
		endif
	endif
endfor

# this alerts the user if there were any .wav files without a matching .Textgrid file
if numUnmatchedWav > 0 
	@logging: ">> Warning: there was not a .Textgrid file of the same name for the following .wav files:"
	for x to numUnmatchedWav
		@logging: ">>>>  " + unmatchedWav$ [x]
	endfor
endif
if numWarnings > 0
	@warningMsg: "ALERT: See the Praat Info window for a message."
endif

@logging: ">> Finished!"
@logging: ">>>> Any modified TextGrids were saved to the folder: " + inDir$

@returnSelection


include PoLaR-praat-procedures.praat