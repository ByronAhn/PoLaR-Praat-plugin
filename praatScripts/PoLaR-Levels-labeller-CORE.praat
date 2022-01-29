################################################################
###  
### PoLaR-Levels-labeller-CORE
### v.2022.01.07
###
### This script creates PoLaR "Levels" tier labels, on the basis of existing "Ranges" and "Points" annotations.
### 
### 
### 
### Instructions:
###     To run from the Praat Objects window:
###         - Select at least one TextGrid file in the Praat objects window, to make the "PoLaR TextGrids" button appear on the right side of the objects window
###         - Select the menu item called "Make Pseudo-ToBI labels"
###         - After the script runs, each new modified TextGrid will pop-up
###     To run from an Editor window:
###         - Click the Tier menu button
###         - Select the menu item called "PoLaR: Make Pseudo-ToBI labels"
### 
###         > > >  NOTE  < < <
###  IN ALL CASES, YOU MUST SAVE THE TEXTGRID MANUALLY!
###  The script itself does not save the TextGrid object it creates
###
### 
### 
### Troubleshooting:
###  - Make sure your TextGrid file has one tier named "Points" and one tier named "Ranges", with PoLaR labels
###       - If, for example, you have multiple tiers named "Points", this script will reference the last one
###       - If, for example, your Points tier is named something different (e.g., "Point", "Pnts", "Range", etc.), then the script MAY NOT find it
###  - Make sure your Ranges labels are correct
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
	numLogs=0
	@versionChecker: 6, 1, 0

	if not variableExists("fromTGE")
		fromTGE = 0
	endif

	# Suppress the "running script…" message, when being called from the TextGrid Editor window
	if fromTGE <> 1
		@logging: date$ () + newline$ + "Running script for generating Levels labels based on Points and Ranges labels"
	endif

	if use_Raw_Hz = 0 and use_Semitones = 0
		exitScript: "You must tick at least one box, for unit of frquency."
	endif

	# Ensure that exactly one Sound object and one TextGrid object are selected
	if numberOfSelected () <> 2
		exitScript: "Select exactly one Sound file AND one TextGrid file."
	else
		soundName$ = selected$ ("Sound", 1)
		tgName$ = selected$ ("TextGrid", 1)
		origTgName$ = tgName$
		if soundName$ = ""
			exitScript: "You must select a Sound file"
		endif
		if tgName$ = ""
			exitScript: "You must select a TextGrid file"
		endif
		theSound = selected ("Sound", 1)
		origTg = selected ("TextGrid", 1)
		theTg = selected ("TextGrid", 1)
	endif

	@findPoLaRTiers: theTg

	# Throw an error if "Points" and "Ranges" tiers aren't there (or aren't named exactly this way)
	if tierPoints = 0 or tierRanges = 0
		exitScript: "The selected TextGrid file does not have tiers named “Points” and “Ranges”, and it must to proceed."
	endif

	# If the user wants new Levels in a new TextGrid object...
	if new_TextGrid_file_in_Object_List = 1
		# Create a second TextGrid file, with a new name, in case old Levels tier info should be preserved
		tgName$ = tgName$ + "-newLevels"
		Copy... 'tgName$'
		selectObject: "TextGrid " + tgName$
		theTg = selected("TextGrid", 1)
	endif

	if use_Raw_Hz = 1
		# If there is a Levels tier, delete it and create a new one
		if tierLevels > 0
			selectObject: theTg
			Remove tier... 'tierLevels'
			Insert point tier... 'tierLevels' Levels
		endif

		# If there isn't a Levels tier, create one below the Points tier
		if tierLevels = 0
			tierLevels = 'tierPoints'+1 
			Insert point tier... 'tierLevels' Levels

			# In case the Ranges tier is below the Points tier, adjust the Ranges tier counter
			# (Because adding a new tier in the line above affects the position of the Ranges tier)
			if 'tierRanges' > 'tierPoints'
				tierRanges += 1
			endif
		endif
	endif

	# update which tiers are where
	@findPoLaRTiers: theTg

	if use_Semitones = 1
		if tierSTLevels > 0
			selectObject: theTg
			Remove tier... 'tierSTLevels'
			Insert point tier... 'tierSTLevels' ST-Lvl
		endif
		if tierSTLevels = 0 
			#if there is a Levels tier too, add ST-Lvl below that. if not, add ST-Lvl below Points.
			if tierLevels > 0
				tierSTLevels = 'tierLevels'+1
			else
				tierSTLevels = 'tierPoints'+1
			endif
			Insert point tier... 'tierSTLevels' ST-Lvl

			# In case the Ranges tier is below the Points tier, adjust the Ranges tier counter
			# (Because adding a new tier in the line above affects the position of the Ranges tier)
			if 'tierRanges' > 'tierPoints'
				tierRanges += 1
			endif
		endif

	# when "use_Semitones" is unchecked, but there is a pre-existing ST-Lvl tier…
	# the following "else" statement deletes that ST-Lvl tier
	else
		if tierSTLevels > 0
			selectObject: theTg
			Remove tier... 'tierSTLevels'
		endif
	endif

	# Since tiers may have been added or removed, find the tier numbers again
	@findPoLaRTiers: theTg
	
	# Query TG tier 'tierRanges' for number of intervals
	numRanges = Get number of intervals... 'tierRanges'

	# Query TG tier 'tierPoints' for number of points
	numPoints = Get number of points... 'tierPoints'
	if numPoints = 0
		selectObject: origTg, theSound
		exitScript: "Your TextGrid doesn't have any Points labels in it."	
	endif

	# For counting points in the for loop below
	pointCounter = 1

	# This for loop takes Ranges intervals one at a time, and then
	# goes through Points labels in each interval (also one at at time)
	for x to numRanges
		selectObject: theTg
		# pointsWhile is going to be used for the while loop below
		pointsWhile=1

		localStart = Get start time of interval... 'tierRanges' 'x'
		localEnd = Get end time of interval... 'tierRanges' 'x'
		intervalLabel$ = Get label of interval... 'tierRanges' 'x'

		pointTime = Get time of point... 'tierPoints' 'pointCounter'
		# FOR DEBUGGING:
		# appendInfoLine: "Range counter: " + string$(x) + " -- Point counter: " + string$(pointCounter) + " -- Point time: " + string$(pointTime)


		# Check if there is a point on the Points tier somewhere within this interval
		if pointTime > localStart and pointTime <= localEnd
		# If there is at least one, start the process of converting it to a Levels label
		# If there are none, do nothing (effectively making the script skip to the next Ranges interval)

			@parseRanges: intervalLabel$
			localMin = parseRanges.localMin
			localMax = parseRanges.localMax

			# When parsing fails for a Ranges tier interval, give a warning and skip to the next interval
			if localMin = undefined or localMax = undefined
				appendInfoLine: ""
				appendInfoLine: ">> ALERT <<"
				appendInfoLine: "The PoLaR Levels script found a Ranges interval that could not be parsed into “MIN-MAX”."
				appendInfoLine: "It was interval number " + string$(x) + ", labelled: “" + intervalLabel$ + "”."
				appendInfoLine: "As a result, NO LEVELS TIER LABELS WERE CREATED for the Points within that interval."
			elsif localMin >= localMax
				appendInfoLine: ""
				appendInfoLine: ">> ALERT <<"
				appendInfoLine: "The PoLaR Levels script found a Ranges interval where the MIN value is ≥ the MAX value:"
				appendInfoLine: "It was interval number " + string$(x) + ", labelled: “" + intervalLabel$ + "”."
				appendInfoLine: "As a result, NO LEVELS TIER LABELS WERE CREATED."
			else
				@pitchesToLevels
			endif

		# This is for a fringe case, where there is a Points object at a time of literally 0.0seconds:
		elsif pointTime == 0
			@parseRanges: intervalLabel$
			localMin = parseRanges.localMin
			localMax = parseRanges.localMax

			# When parsing fails for a Ranges tier interval, give a warning and skip to the next interval
			if localMin = undefined or localMax = undefined
				appendInfoLine: ""
				appendInfoLine: ">> ALERT <<"
				appendInfoLine: "The PoLaR Levels script found a Ranges interval that could not be parsed into “MIN-MAX”,:"
				appendInfoLine: "It was interval number " + string$(x) + ", labelled: “" + intervalLabel$ + "”."
				appendInfoLine: "As a result, NO LEVELS TIER LABELS WERE CREATED for the Points within that interval."
			else
				@pitchesToLevels
			endif		
		endif	
	endfor

	selectObject: theTg, theSound
	if viewandedit = 1
		View & Edit
	endif

	selectObject: origTg, theSound
	#@logging: "Script finished at " + date$ ()
endproc



# --------------------
# 
#	Procedure pitchesToLevels
#	(Used to extract pitch information and convert it to Levels labels)
# 
# --------------------
procedure pitchesToLevels
# Create a Pitch object for this interval
#   For pitch settings, the F0 Min/Max are set by the variables localMin/localMax, based on the local Range interval label.
#   The other pitch settings are set by the pop-up at the beginning of the script.
selectObject: theSound
localPitchName$ = soundName$ + "-Interval-" + string$(x)
To Pitch (ac)... 'time_step' 'localMin' 'number_of_candidates' 'very_accurate' 'silence_threshold' 'voicing_threshold' 'octave_cost' 'octave_jump_cost' 'voice_unvoiced_cost' 'localMax'
selectObject: "Pitch " + soundName$
thePitch = selected ("Pitch", 1)
Rename... 'localPitchName$'

# cycle through Points in this interval of time
selectObject: theTg
while pointsWhile = 1
	thisPointTime = Get time of point... 'tierPoints' 'pointCounter'

	# Check to see if this Points tier point is still within this Ranges interval
	if thisPointTime <= localEnd
		# Get the Points tier label, in case it has a "comma override" value in it
		thisPointLabel$ = Get label of point... 'tierPoints' 'pointCounter'

		# If the Points tier object is unlabelled, replace the null string with a '0' label
		if thisPointLabel$ = ""
			Set point text: 'tierPoints', 'pointCounter', "0"
		endif

		# Run the @getF0Here process to determine the F0 value, which determines the Level
		@getF0Here: thisPointTime, thisPointLabel$, thePitch
		thisPointF0 = getF0Here.thisF0

		# if use_Raw_Hz is true...
		if use_Raw_Hz = 1
			# Run the @transformF0ToLevel process to convert the F0 value to the Level label
			@transformF0ToLevel: thisPointF0, localMin, localMax
			thisPointLevel$ = transformF0ToLevel.theLevel$

			# Select the Textgrid, to prepare for inserting a Levels tier label
			selectObject: theTg

			# Insert the points on the Levels tier, with the right label:
			Insert point... 'tierLevels' 'thisPointTime' 'thisPointLevel$'

			#FOR DEBUGGING
			#@logging: "Hz-Levels" + tab$ + string$(thisPointTime) + tab$ + string$(thisPointF0) + tab$ + thisPointHzLevel$
		endif

		# if use_Semitones is true...
		if use_Semitones = 1
			# Run the @transformF0ToSTLevel process to convert the F0 value to the ST-Level label
			@transformF0ToSTLevel: thisPointF0, localMin, localMax
			thisPointSTLevel$ = transformF0ToSTLevel.theLevel$

			# Select the Textgrid, to prepare for inserting a Levels tier label
			selectObject: theTg

			# Insert the points on the Levels tier, with the right label:
			Insert point... 'tierSTLevels' 'thisPointTime' 'thisPointSTLevel$'

			#FOR DEBUGGING
			#@logging: "ST-Levels" + tab$ + string$(thisPointTime) + tab$ + string$(thisPointF0) + tab$ + thisPointSTLevel$
		endif


		# If this is the last Points tier point, "pointsWhile" is set to 0, breaking the while loop
		# Otherwise, the counter is stepped, prepare for the next iteration of this while loop
		if pointCounter < numPoints
			pointCounter += 1
		else
			pointsWhile=0
		endif
	else
		pointsWhile=0
	endif
endwhile

# Remove the Pitch object that was created for this interval
selectObject: thePitch
Remove
endproc


# --------------------
# 
#	Procedure transformF0ToLevel
#	(Used to transform the f0 value into a levels scale, 1-5)
# 
# --------------------
procedure transformF0ToLevel: .theF0, .theF0Min, .theF0Max
	if .theF0 = undefined
		# In case the F0 value is undefined for some reason
		.theLevel$ = "???"

	elsif .theF0 < .theF0Min
		# In case the F0 value is outside of the range defined by the Range interval labels
		@logging: tab$ + ">> ALERT <<" + newline$ + tab$ + tab$ + "The f0 found for the Points label at time " + string$(thisPointTime) + " (" + string$(.theF0) + ") was below the min-max set by the Range interval (" + string$(.theF0Min) + ")." + newline$ + tab$ + tab$ + "A Levels point was inserted with the label “???”. Consider changing your Ranges label, or consider using the “comma override” in the Points label." + newline$ + tab$ + tab$ + "(The latter may be favorable if you believe this is due to errors in software f0 tracking.)"
		.theLevel$ = "???"

	elsif .theF0 > .theF0Max
		# In case the F0 value is outside of the range defined by the Range interval labels
		@logging: tab$ + ">> ALERT <<" + newline$ + tab$ + tab$ + "The f0 found for the Points label at time " + string$(thisPointTime) + " (" + string$(.theF0) + ") was above the min-max range set by the Range interval (" + string$(.theF0Max) + ")." + newline$ + tab$ + tab$ + "A Levels point was inserted with the label “???”. Consider changing your Ranges label, or consider using the “comma override” in the Points label." + newline$ + tab$ + tab$ + "(The latter may be favorable if you believe this is due to errors in software f0 tracking.)"
		.theLevel$ = "???"

	else
		## the simplest algorithm: 5 evenly spaced levels, on the basis of Hz values
		##
		## potential concern about the following algorithm for determining the Levels value: 
		##		if Level 2 corresponds to the space between 150Hz and 165Hz, an f0 value of 165.1Hz
		##		is going to be labelled as Level 3.
		##
		@roundTo: .theF0, 2
		.theRoundedF0 = roundTo.result

		.theLevelSpace = (.theF0Max - .theF0Min)/5
		@roundTo: .theLevelSpace, 4
		.theLevelSpace = roundTo.result

		.theRelativeF0 = .theRoundedF0 - .theF0Min
		@roundTo: .theRelativeF0, 2
		.theRelativeF0 = roundTo.result

		if .theRelativeF0 <= 0
			# In case the rounded F0 value is equal to (or somehow less than) the f0 Min from the Range interval label
			.theLevel$ = "1"

		else
			.theLevelNum = ceiling(.theRelativeF0/.theLevelSpace)
			if .theLevelNum < 1
				.theLevel$ = "<1"
			elsif .theLevelNum > 5
				.theLevel$ = ">5"
			else
				.theLevel$ = string$(.theLevelNum)
			endif
		endif

		# FOR DEBUGGING: the following line also prints the f0 in the levels label
		# .theLevel$ = string$(.theRoundedF0) + ": " + .theLevel$
	endif
endproc


# --------------------
# 
#	Procedure transformF0ToSTLevel
#	(Used to transform the f0 value into a levels scale, 1-5)
# 
# --------------------
procedure transformF0ToSTLevel: .theF0, .theF0Min, .theF0Max
	if .theF0 = undefined
		# In case the F0 value is undefined for some reason
		.theLevel$ = "???"

	elsif .theF0 < .theF0Min
		# In case the F0 value is outside of the range defined by the Range interval labels
		@logging: tab$ + ">> ALERT <<" + newline$ + tab$ + tab$ + "The f0 found for the Points label at time " + string$(thisPointTime) + " (" + string$(.theF0) + ") was below the min-max set by the Range interval (" + string$(.theF0Min) + ")." + newline$ + tab$ + tab$ + "A Levels point was inserted with the label “???”. Consider changing your Ranges label, or consider using the “comma override” in the Points label." + newline$ + tab$ + tab$ + "(The latter may be favorable if you believe this is due to errors in software f0 tracking.)"
		.theLevel$ = "???"

	elsif .theF0 > .theF0Max
		# In case the F0 value is outside of the range defined by the Range interval labels
		@logging: tab$ + ">> ALERT <<" + newline$ + tab$ + tab$ + "The f0 found for the Points label at time " + string$(thisPointTime) + " (" + string$(.theF0) + ") was above the min-max range set by the Range interval (" + string$(.theF0Max) + ")." + newline$ + tab$ + tab$ + "A Levels point was inserted with the label “???”. Consider changing your Ranges label, or consider using the “comma override” in the Points label." + newline$ + tab$ + tab$ + "(The latter may be favorable if you believe this is due to errors in software f0 tracking.)"
		.theLevel$ = "???"

	else
		## the simplest algorithm: 5 evenly spaced levels, on the basis of Hz values
		##
		## potential concern about the following algorithm for determining the Levels value: 
		##		if Level 2 corresponds to the space between 150Hz and 165Hz, an f0 value of 165.1Hz
		##		is going to be labelled as Level 3.
		##
		@roundTo: hertzToSemitones(.theF0Max), 2
		.theRoundedSTMax = roundTo.result

		@roundTo: hertzToSemitones(.theF0Min), 2
		.theRoundedSTMin = roundTo.result

		@roundTo: hertzToSemitones(.theF0), 2
		.theRoundedST = roundTo.result

		.theLevelSpace = (.theRoundedSTMax - .theRoundedSTMin)/5
		@roundTo: .theLevelSpace, 4
		.theLevelSpace = roundTo.result

		.theRelativeST = .theRoundedST - .theRoundedSTMin
		@roundTo: .theRelativeST, 2
		.theRelativeST = roundTo.result

		if .theRelativeST <= 0
			# In case the rounded ST value is equal to (or somehow less than) the rounded ST Min
			.theLevel$ = "1"

		else
			.theLevelNum = ceiling(.theRelativeST/.theLevelSpace)
			if .theLevelNum < 1
				.theLevel$ = "<1"
			elsif .theLevelNum > 5
				.theLevel$ = ">5"
			else
				.theLevel$ = string$(.theLevelNum)
			endif
		endif

		# FOR DEBUGGING: the following line also prints the ST in the levels label
		# .theLevel$ = string$(.theRoundedST) + ": " + .theLevel$
	endif
endproc


include PoLaR-praat-procedures.praat


################################################################
###  
### end of PoLaR-Levels-labeller-CORE
### 
################################################################