################################################################
###  
### PoLaR-resynthesize-SLA-CORE
### v.2021.01.29
###
### This script uses PoLaR Point tier labels to create a straight line approximation (SLA) of the pitch track.
### 
### 
### Instructions:
### 
###  Select exactly one Sound file and one TextGrid file in the Praat objects window, to make the "PoLaR Straight Line Approx." button appear on the right side of the objects window
###       - Choose the appropriate script: Quick, Quick+Quiet, or Advanced
###       - When running the Quick or Quick+Quiet version, the script loads with all the (Advanced) Pitch Settings parameters that are described in the PoLaR guidelines.
###       - When running "PoLaR SLA (Advanced)", you can adjust settings manually.
###       - Both Quick and Advanced scripts play the original and resynthesized sound files back-to-back. Quick+Quiet resynthesizes without playing any sounds.
### 
### 
### Results:
### 
### After running the script, two new objects will be in the Praat Objects window: a Manipulation object and a new Sound object
###       - neither of these is saved to the disk
### The resynthesized sound file and the original TextGrid are opened in a new window.
### 
### 
### Troubleshooting:
###  - Make sure your TextGrid file has one tier named "Points", with PoLaR labels
###       - If you have multiple tiers named "Points", this script will reference the last one
###       - If your Points tier is named something different (e.g., "Point", "Pnts", etc.), then the script MAY NOT find it
### 
### 
###
###	Nanette Veilleux and Byron Ahn
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
	@versionChecker: 6, 1, 0
	endeditor
	numLogs=0
	
	if not variableExists("fromTGE")
		fromTGE = 0
	endif

	# Suppress the "running script…" message, when being called from the TextGrid Editor window
	if fromTGE <> 1
		@logging: date$ () + newline$ + "Running script for resynthesizing a straight line approximation of the f0 based on Points annotation"
	endif

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

	# If the user provides a different start/end time, create new sound/textgrid files
	if start_Time > 0 or end_Time > 0
		selectObject: origSound
		sound_part = Extract part: start_Time, end_Time, rectangular, 1, 0
		selectObject: sound_part
		soundName$ = origSoundName$ + "-piece"
		Rename: soundName$
		theSound = sound_part
	#
		selectObject: origTg
		tg_part = Extract part: start_Time, end_Time, 0
		selectObject: tg_part
		tgName$ = origTgName$ + "-piece"
		Rename: tgName$
		theTg = tg_part
	else
		soundName$ = origSoundName$
		theSound = origSound
		tgName$ = origTgName$
		theTg = origTg
	endif
	#@logging: tgName$

	# Discover the tier number in the TextGrid for each of the PoLaR tiers
	@findPoLaRTiers: theTg

	# Select just the TextGrid
	selectObject: theTg

	# Determine the appropriate f0 min/max, and save them as globalMin and globalMax
	@findGlobalMinMax: theTg
	globalMin = findGlobalMinMax.globalMin
	globalMax = findGlobalMinMax.globalMax

	# Select the TextGrid and the Sound
	selectObject: theTg, theSound

	# Create a PitchTier containing the appropriate f0 values at the appropriate times, on the
	# basis of the PoLaR Points tier and the Sound object
	@extractF0fromPoints


	# The selected Sound object is selected again, and a Manipulation object is created (on the basis of
	# the time step settings from the pop-up, and the f0Min/Max determined by the findGlobalMinMax procedure)
	selectObject: theSound
	# for deubgging:
	# @logging: string$(globalMin) + tab$ + string$(globalMax)
	theManip = To Manipulation: time_step, globalMin, globalMax

	#use manipulation and new pitchtier to resynthesize
	selectObject: thePitchTier, theManip
	Replace pitch tier
	selectObject: theManip
	resynthName$ = soundName$ + "-resynth"
	Rename: resynthName$
	theResynth = Get resynthesis (overlap-add)

	#edit this in if you want to write to straightline file
	#sound_file_extension$ = ".wav"
	#outfile$ = resynthName$ + sound_file_extension$
	#Write to WAV file: outfile$

		selectObject: thePitch
			Remove
		selectObject: thePitchTier
			Remove
		#selectObject: theManip
		#	Remove
		if soundName$ <> origSoundName$
			selectObject: theSound
			Remove
		endif
		if tgName$ <> origTgName$
			selectObject: theTg
			Remove
		endif

	# Move selection back to the original Sound and TextGrid files
	selectObject: origSound, origTg
endproc


# --------------------
# 
#	Procedure extractF0fromPoints
#	(Used to extract F0 information)
# 
# --------------------
procedure extractF0fromPoints
	# Create a Pitch object for this interval
	#   For pitch settings, the F0 Min/Max are set by the variables localMin/localMax, based on the local Range interval label.
	#   The other pitch settings are set by the pop-up at the beginning of the script.
	selectObject: theSound
	pitchName$ = soundName$
	thePitch = To Pitch (ac): time_step, globalMin, number_of_candidates, very_accurate, silence_threshold, voicing_threshold, octave_cost, octave_jump_cost, voice_unvoiced_cost, globalMax
	selectObject: thePitch

	#Create new Pitch tier and fill with t,f0 points 
	startTime = Get start time
	endTime = Get end time
	thePitchTier = Create PitchTier: "empty", startTime, endTime

	# cycle through Points in this interval of time
	selectObject: theTg
	numPoints = Get number of points: tierPoints
	for pointCounter to numPoints
		selectObject: theTg
		thisPointTime = Get time of point: tierPoints, pointCounter

		# Get the Points tier label, in case it has a "comma override" value in it
		thisPointLabel$ = Get label of point: tierPoints, pointCounter

		# Run the @getF0Here process to determine the F0 value, which determines the Level
		@getF0Here: thisPointTime, thisPointLabel$, thePitch
		thisPointF0 = getF0Here.thisF0

		selectObject: thePitch
		selectObject: thePitchTier
		Add point: thisPointTime, thisPointF0
	endfor
endproc


include PoLaR-praat-procedures.praat


################################################################
###  
### end of PoLaR-resynthesize-SLA-CORE
### 
################################################################