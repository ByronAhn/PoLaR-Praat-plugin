################################################################
###  
### PoLaR-momel-labels-dir
###
###		>> Please ensure you have Praat v.6.1.38 or greater
###
### Runs PoLaR-rough-draft-CORE.praat from the Objects window
###
### For more information, see PoLaR-momel-labels-CORE.praat.
###
################################################################

# fileNames$# is a function that wasn't defined until 6.1.38
@versionChecker: 6, 1, 38

include PoLaR-momel-labels-Settings.praat
@saveSelection

fromTGE=0
manipulate=0
saveToDir=1
numUnmatchedWav = 0
numWarnings = 0
numLabelled = 0


# get directory / directory listing
beginPause: "Where are your .wav + .Textgrid files?"
	comment: "Hit the ""Choose Folder"" button to select the with your .wav (and matching"
	comment: ".Textgrid) files, to create Momel-based PoLaR labels from."
endPause: "Choose Folder", 1
inDir$ = chooseDirectory$: "Choose the folder with matching .wav + .Textgrid files"
if right$(inDir$,1) <> "/" and right$(inDir$,1) <> "\"
	inDir$ = inDir$ + "/"
endif

outDir$ = inDir$ + "momel_Based_TextGrids/"
createFolder: outDir$

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

		# this else statement runs when there is no matching .Textgrid file
		# it stores the name of the .wav file and reports it to the user at the end
		else
			numUnmatchedWav += 1
			unmatchedWav$ [numUnmatchedWav] = wavFilename$
			selectObject: sndObj
			tgObj = To TextGrid: "Words", ""
		endif

		# try to open a .PitchTier file of the same name
		ptFile$ = inDir$ + baseFilename$ + ".PitchTier"
		if fileReadable(ptFile$)
			ptObj = Read from file: ptFile$
		else
			ptObj = 0
		endif

		# run the momel-based PoLaR-drafting functions, with the .wav and .Textgrid files
		selectObject: sndObj, tgObj
		@momelBasedLabelsMain: sndObj, baseFilename$, tgObj, ptObj
		numLabelled = numLabelled + 1
		selectObject: tgObj
		Save as text file: outDir$ + baseFilename$ + ".Textgrid"
		selectObject: sndObj, tgObj
		Remove

	endif
endfor

# this alerts the user if there were any .wav files without a matching .Textgrid file
if numUnmatchedWav > 0 
	@logging: ">> Warning: there was not a .Textgrid file of the same name for the following .wav files:"
	for x to numUnmatchedWav
		@logging: ">>>>  " + unmatchedWav$ [x]
	endfor
	@logging: "For each of these files, a TextGrid was created from scratch."
endif
if numUnmatchedWav > 0 or numWarnings > 0
	@warningMsg: "ALERT: See the Praat Info window for a message."
endif

@logging: ">> Finished!"
@logging: ">>>> " + string$(numLabelled) + " files were labelled."
@logging: ">>>> New TextGrid files (and any new PitchTier files) are in the folder:" + newline$ + "     " + outDir$

@returnSelection


include PoLaR-momel-labels-CORE.praat
include PoLaR-praat-procedures.praat