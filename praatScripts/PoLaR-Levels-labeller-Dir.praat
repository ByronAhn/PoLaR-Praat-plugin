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
beginPause: "Pitch settings for straight line approximations"
	comment: "Do you want to create a new TextGrid with these Levels labels?"
	boolean: "new_TextGrid_file_in_Object_List", 0
	comment: "==================================================================="
	comment: "Which units of frequency do you want to use to determine Levels labels?"
	boolean: "use_Raw_Hz", 1
	boolean: "use_Semitones", 0
	comment: "==================================================================="
	comment: "Praat (Advanced) Pitch Settings:"
	real: "time_step", 0.0025
	integer: "number_of_candidates", 15
	boolean: "very_accurate", 1
	real: "silence_threshold", 0.03
	real: "voicing_threshold", 0.5
	real: "octave_cost", 0.05
	real: "octave_jump_cost", 0.5
	real: "voice_unvoiced_cost", 0.2
	comment: "NOTE: f0 min and f0 max are set locally, by the Range tier labels"
endPause: "Choose Folder", 1
numUnmatchedWav = 0
numWarnings = 0
viewandedit=0

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