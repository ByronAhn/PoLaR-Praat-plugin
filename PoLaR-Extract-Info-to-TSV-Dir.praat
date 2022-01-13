################################################################
###  
### PoLaR-Extract-Info-to-TSV-Dir
###
###		>> Please ensure you have Praat v.6.1 or greater
###
### Runs PoLaR-Extract-Info-to-TSV-CORE.praat
### with the settings defined in PoLaR-Extract-Info-to-TSV-Quick-Settings.praat
### on a whole directory of .wav and .Textgrid files.
###
### For more information, see PoLaR-Extract-Info-to-TSV-CORE.praat.
###
################################################################


# variable settings
include PoLaR-Extract-Info-to-TSV-Quick-Settings.praat
outToFile = 1
numUnmatchedWav = 0
numLogs=0
@logging: date$ () + newline$ + "Running script for extracting information from PoLaR labelled TextGrids in a directory to .tsv rows"

# get directory / directory listing
beginPause: "Where are your .wav and .Textgrid files?"
	comment: "First, say whether you want a single .tsv for all .wavs,"
	comment: "if not, a .tsv will be created for each .wav."
	boolean: "Create A Single Output File", 1
	comment: "Hit the ""Choose Folder"" button to select the with your matching .wav and"
	comment: ".Textgrid files, to extract PoLaR labels and PoLaR-based measures from."
endPause: "Choose Folder", 1
outDir$ = chooseDirectory$: "Choose the folder with matching .wav and .Textgrid files"
outDir$ = outDir$ + "/"
stringsOfFiles = Create Strings as file list: "listOfWavs", outDir$ + "/*.wav"

if create_A_Single_Output_File = 1
	# set up a single output file for all .wavs, if create_A_Single_Output_File = 1
	output_File_Name$ = "Info-from-PoLaR-labels.tsv"
	outputDirFile$ = outDir$ + output_File_Name$

	header$ = "Filename" + tab$ + "Tier name" + tab$ + "Label" + tab$ + "(Start) Time [sec]" + tab$ + "End Time [sec]" + tab$ + "Timing wrt Words" + tab$ + "Timing wrt Phones" + tab$ + "(Start) F0 value [Hz]" + tab$ + "End F0 value [Hz]" + tab$ + "Avg F0 value [Hz]" + tab$ + "F0 Range (Hz)" + tab$ + "Levels value" + tab$ + "(Start) Intensity value [dB]" + tab$ + "End Intensity value [dB]" + tab$ + "Avg Intensity value [dB]"
	@writeThisInfo: header$
endif

# run a for-loop, for each .wav file
selectObject: stringsOfFiles
numberOfFiles = Get number of strings
for xF from 1 to numberOfFiles
	selectObject: stringsOfFiles
	aFilename$ = Get string: xF
	@logging: "starting " + aFilename$ + "…"

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
			if create_A_Single_Output_File = 0
				# set up a new output file for each .wav, if create_A_Single_Output_File = 0
				output_File_Name$ = baseFilename$ + ".tsv"
				outputDirFile$ = outDir$ + output_File_Name$
			endif
			aTg = Read from file: tgFile$

			# run the extraction functions, with the .wav and .Textgrid files
			selectObject: aWav, aTg
			@main
			selectObject: aWav, aTg
			Remove

		# this else statement runs when there is no matching .Textgrid file
		# it stores the name of the .wav file and reports it to the user at the end
		else
			numUnmatchedWav += 1
			unmatchedWav$ [numUnmatchedWav] = wavFilename$
		endif
	endif
	@logging: "   … done!"
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
	@warningMsg: "ALERT: An issue came up; see the Praat Info window for details."
endif

@logging: "Directory complete!"

include PoLaR-Extract-Info-to-TSV-CORE.praat