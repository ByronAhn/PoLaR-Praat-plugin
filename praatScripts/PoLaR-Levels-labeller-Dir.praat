################################################################
###  
### PoLaR-Levels-labeller-Dir
###
###		>> Please ensure you have Praat v.6.1 or greater
###
### Runs PoLaR-Levels-labeller-CORE.praat
### with the settings defined in PoLaR-Levels-labeller-Quick-Settings.praat.
### on a whole directory of .wav and .Textgrid files.
###
### For more information, see PoLaR-Levels-labeller-CORE.praat.
###
################################################################


# variable settings
include PoLaR-Levels-labeller-Quick-Settings.praat
numUnmatchedWav = 0
numWarnings = 0
viewandedit=0

# get directory / directory listing
beginPause: "Where are your .wav and .Textgrid files?"
	comment: "Hit the ""Choose Folder"" button to select the with your matching .wav and"
	comment: ".Textgrid files, to extract PoLaR labels and PoLaR-based measures from."
endPause: "Choose Folder", 1
outDir$ = chooseDirectory$: "Choose the folder with matching .wav and .Textgrid files"
if right$(outDir$,1) <> "/" and right$(outDir$,1) <> "\"
	outDir$ = outDir$ + "/"
endif
stringsOfFiles = Create Strings as file list: "listOfFiles", outDir$ + "/*.*"

# run a for-loop, for each .wav file
selectObject: stringsOfFiles
numberOfFiles = Get number of strings
for xF from 1 to numberOfFiles
	selectObject: stringsOfFiles
	aFilename$ = Get string: xF

	# target .wav files (regardless of capitalization)
	lowercaseFilename$ = replace_regex$ (aFilename$, "[A-Z]", "\L&", 0) 
	filenameLen = length(lowercaseFilename$)
	extensionDotLoc = rindex(lowercaseFilename$, ".")

	if right$(lowercaseFilename$, filenameLen-extensionDotLoc) = "wav"
		wavFilename$ = aFilename$
		baseFilename$ = wavFilename$ - ".wav"
		aWav = Read from file: outDir$ + baseFilename$ + ".wav"

		# try to open a .Textgrid file of the same name
		tgFile$ = outDir$ + baseFilename$ + ".Textgrid"
		if fileReadable(tgFile$)
			aTg = Read from file: tgFile$

			# run the extraction functions, with the .wav and .Textgrid files
			selectObject: aWav, aTg
			@levelsLabellerMain
			selectObject: aTg
			Save as text file: tgFile$
			selectObject: aWav, aTg
			Remove

		# this else statement runs when there is no matching .Textgrid file
		# it stores the name of the .wav file and reports it to the user at the end
		else
			numUnmatchedWav += 1
			unmatchedWav$ [numUnmatchedWav] = wavFilename$
		endif
	endif
endfor
selectObject: stringsOfFiles
Remove

# this alerts the user if there were any .wav files without a matching .Textgrid file
if numUnmatchedWav > 0 
	@logging: "For at least one .wav file, there was not a .Textgrid file of the same name."
	@logging: ">> The list of such .wav files:"
	for x to numUnmatchedWav
		@logging: ">>>>  " + unmatchedWav$ [x]
	endfor
endif
if numUnmatchedWav > 0 or numWarnings > 0
	@warningMsg: "ALERT: An issue came up; see the Praat Info window for details."
endif

include PoLaR-Levels-labeller-CORE.praat