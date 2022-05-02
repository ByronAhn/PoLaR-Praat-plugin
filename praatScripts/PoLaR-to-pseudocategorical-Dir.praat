################################################################
###  
### PoLaR-to-pseudocategorical-Dir
###
###		>> Please ensure you have Praat v.6.1.38 or greater
###
### Runs PoLaR-to-pseudocategorical-CORE.praat
### with the settings defined in PoLaR-to-pseudocategorical-Quick-Settings.praat
### on a whole directory of .wav and .Textgrid files.
###
### For more information, see PoLaR-to-pseudocategorical-CORE.praat.
###
################################################################

# variable settings
include PoLaR-Levels-labeller-Quick-Settings.praat
numUnmatchedWav = 0
numWarnings = 0
viewandedit=0

# get directory / directory listing
beginPause: "Where are your .Textgrid files?"
	comment: "Hit the ""Choose Folder"" button to select the with your .Textgrid files,"
	comment: "in which to create Pseudo tier labels. (Advanced labels required!)"
endPause: "Choose Folder", 1
outDir$ = chooseDirectory$: "Choose the folder with the .Textgrid files"
if right$(outDir$,1) <> "/" and right$(outDir$,1) <> "\"
	outDir$ = outDir$ + "/"
endif
stringsOfFiles = Create Strings as file list: "listOfFiles", outDir$ + "/*.*"

# run a for-loop, for each .Textgrid file
selectObject: stringsOfFiles
numberOfFiles = Get number of strings
for xF from 1 to numberOfFiles
	selectObject: stringsOfFiles
	aFilename$ = Get string: xF

	# target .Textgrid files (regardless of capitalization)
	lowercaseFilename$ = replace_regex$ (aFilename$, "[A-Z]", "\L&", 0) 
	filenameLen = length(lowercaseFilename$)
	extensionDotLoc = rindex(lowercaseFilename$, ".")

	if right$(lowercaseFilename$, filenameLen-extensionDotLoc) = "textgrid"
		tgFilename$ = aFilename$
		baseFilename$ = tgFilename$ - ".Textgrid"
		tgFile$ = outDir$ + baseFilename$
		aTg = Read from file: tgFile$

		# run the Pseudo tier labelling functions, with the .Textgrid files
		selectObject: aTg
		@pseudoLabelsMain
		selectObject: aTg
		Save as text file: tgFile$
		selectObject: aTg
		Remove
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
else
	beginPause: "Done!"
	comment: "All done! Files are in " + outDir$
	endPause: "OK", 1
endif

include PoLaR-to-pseudocategorical-CORE.praat