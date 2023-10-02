################################################################
###  
### PoLaR-Draw-Sound-and-TextGrid-Dir
###
###		>> Please ensure you have Praat v.6.1 or greater
###
### Runs PoLaR-Draw-Sound-and-TextGrid-CORE.praat
### with some options given to the end user, but mostly using the settings 
### defined in PoLaR-resynthesize-SLA-Quick-Settings.praat and then
### saves the resultant pictures as an image file in the same directory.
###
### For more information, see PoLaR-Draw-Sound-and-TextGrid-CORE.praat.
###
################################################################

include PoLaR-resynthesize-SLA-Quick-Settings.praat
include PoLaR-resynthesize-SLA-CORE.praat
numUnmatchedWav = 0
numWarnings = 0
viewandedit=0

numLogs = 0
run_on_directory = 1
manual_advanced_pitch_settings=0
draw_all_TextGrid_tiers=1

label PARAMETERSETTINGS
beginPause: "Input Parameter Values"
	comment: "FIRST, at least 1 box below *MUST* be ticked:"
	boolean: "save as pdf", 0
	boolean: "save as eps", 0
	boolean: "save as png", 1

	comment: "SECOND, adjust settings for the drawing:"
	positive: "width of entire drawing", 8
	positive: "height of the pitch track and spectrogram", 1.5
	boolean: "draw the f0 contour", 1
	boolean: "let the script determine the f0 draw_range", 1
	boolean: "use Ranges tier as draw range (if available)", 1
	integer: "y axis interval", 50
	boolean: "mark f0 intervals on the axis", 1
	boolean: "draw the spectrogram", 1
	positive: "spectrogram dynamic range", 40

	comment: "FINALLY, hit the ""Choose Folder"" button to select the with your matching .wav and"
	comment: ".Textgrid files, to extract PoLaR labels and PoLaR-based measures from."
endPause: "Choose Folder", 1

if ((save_as_pdf = 0) & (save_as_eps = 0) & (save_as_png = 0))
	pause You must choose at least ONE format to save the image files
	goto PARAMETERSETTINGS
endif

outDir$ = chooseDirectory$: "Choose the folder with matching .wav and .Textgrid files"
if right$(outDir$,1) <> "/" and right$(outDir$,1) <> "\"
	outDir$ = outDir$ + "/"
endif

theFiles$ = inDir$ + "*.*"
listOfFiles$# = fileNames$#: theFiles$

# run a for-loop, for each .wav file
for xF from 1 to size(listOfFiles$#)
	aFilename$ = listOfFiles$#[xF]

	# settings from PoLaR-Draw-Sound-and-TextGrid-Quick-Settings.praat
	spectrogram_settings_FreqMax=7000
	new_TextGrid_file_in_Object_List = 0
	use_Ranges_tier = 1
	startTime = 0.0
	endTime = 0.0
	f0Min = 75
	f0Max = 500
	time_step = 0.0025
	number_of_candidates = 15
	very_accurate = 1
	silence_threshold = 0.03
	voicing_threshold = 0.5
	octave_cost = 0.05
	octave_jump_cost = 0.5
	voice_unvoiced_cost = 0.2
	numLogs = 0
	numOutputs = 0
	outToFile = 0
	create_A_Single_Output_File = 0
	numWarnings = 0

	# target .wav files (regardless of capitalization)
	extensionDotLoc = rindex(aFilename$, ".")
	baseFilename$ = left$(aFilename$, extensionDotLoc-1)
	extension$ = right$(aFilename$, length(aFilename$)-extensionDotLoc)
	lowercaseExtension$ = replace_regex$ (extension$, "[A-Z]", "\L&", 0)
	
	if lowercaseExtension$ = "wav"
		wavFilename$ = aFilename$
		aWav = Read from file: outDir$ + baseFilename$ + ".wav"

		# try to open a .Textgrid file of the same name
		tgFile$ = outDir$ + baseFilename$ + ".Textgrid"
		if fileReadable(tgFile$)
			aTg = Read from file: tgFile$

			# run the extraction functions, with the .wav and .Textgrid files
			selectObject: aWav, aTg
			@drawMain
			selectObject: aWav, aTg
			Remove

		# this else statement runs when there is no matching .Textgrid file
		# it stores the name of the .wav file and reports it to the user at the end
		else
			selectObject: aWav
			@drawMain
			selectObject: aWav

			numUnmatchedWav += 1
			unmatchedWav$ [numUnmatchedWav] = wavFilename$
		endif
	endif
endfor

# this alerts the user if there were any .wav files without a matching .Textgrid file
if numUnmatchedWav > 0 
	@logging: "For at least one .wav file, there was not a .Textgrid file of the same name."
	@logging: ">> The list of such .wav files:"
	for x to numUnmatchedWav
		@logging: ">>>>  " + unmatchedWav$ [x]
	endfor
	@logging: "A drawing was created for each of these .wav files, but there is no TextGrid in the drawing."
endif
if numWarnings > 0
	@warningMsg: "ALERT: An issue came up; see the Praat Info window for details."
endif
@logging: "Done!"


include PoLaR-Draw-Sound-and-TextGrid-CORE.praat