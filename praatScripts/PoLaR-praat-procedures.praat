################################################################
###
### PoLaR-praat-procedures
### v.2023.10.02
###
###
### This file contains the procedures (which are like "functions" in other scripting
### languages) that are commonly used in the PoLaR suite of functions.
###
###
###	Byron Ahn (bta@princeton.edu)
###	Attribution-ShareAlike 2.5 license
###
################################################################


# --------------------
# 
#	Procedure createPitchFromSound
#	(Used create a Pitch object, using recording-based values for f0 min/max for analysis from an algorithm)
# 
# --------------------
procedure createPitchFromSound: .theSnd, .pitch_step
	# this uses the algorithm for setting pitch min/max from Daniel Hirst
	# (can be found in the Momel plugin for Praat)
	
	# create first-pass Pitch object
	selectObject: .theSnd
	.thePitch = To Pitch: .pitch_step, 50, 750
  	.q25 = Get quantile: 0.0, 0.0, 0.25, "Hertz"
	
	.min_f0 = 10*floor((0.75*.q25)/10)
	.max_f0 = .min_f0*4
  
  	selectObject: .thePitch
  	Remove
	
	# create second-pass Pitch object
	selectObject: .theSnd
	.thePitch = To Pitch: .pitch_step, .min_f0, .max_f0
endproc



# --------------------
# 
#	Procedure createPitchFromSoundTextGrid
#	(Used create a Pitch object, using PoLaR labels if possible)
# 
# --------------------
procedure createPitchFromSoundTextGrid: .theSnd, .theTg, .pitch_step	
	selectObject: .theTg
	@findPoLaRTiers: .theTg

	# use PoLaR Ranges labels to find minmax
	@findGlobalMinMax: .theTg
	.min_f0 = findGlobalMinMax.globalMin
	.max_f0 = findGlobalMinMax.globalMax
	
	# check if these values are the default values, which come up when there is no labelled Ranges tier
	if (.min_f0 = 55 and .max_f0 = 700)
		# if here, that means there is no lablled Ranges tier
		# and now we want to create a Pitch object for finding min/max, using the algorithm for setting pitch min/max from Daniel Hirst
		# (can be found in the Momel plugin for Praat)
		selectObject: .theSnd
		.thePitch = To Pitch: .pitch_step, 50, 750
	  	.q25 = Get quantile: 0.0, 0.0, 0.25, "Hertz"
	
		.min_f0 = 10*floor((0.75*.q25)/10)
		.max_f0 = .min_f0*4
  
	  	selectObject: .thePitch
	  	Remove
	endif
	
	# create a Pitch object with the .min_f0/.max_f0 calculated by this point
	selectObject: .theSnd
	.thePitch = To Pitch: .pitch_step, .min_f0, .max_f0
endproc



# --------------------
# 
#	Procedure createPitchTierFromTG
#	(Used to go from a Points-labelled TextGrid to a PitchTrack)
# 
# --------------------
procedure createPitchTierFromTG: .theSnd, .theTg, .thePitchObj
	# get duration of sound
	selectObject: .theSnd
	.duration = Get total duration

	# get name of TextGrid
	selectObject: .theTg
	.tgName$ = selected$("TextGrid")

	# create a blank PitchTier object with the same duration as the sound and same name as the TextGrid
	.thePT = Create PitchTier: .tgName$, 0, .duration

	# check to make sure that there is a Points tier with at least one label on the Points tier
	.numPoints = 0
	@findPoLaRTiers: .theTg
	if (tierPoints = 0)
		# being here means there's no Points tier
		exitScript: "This script requires a labelled Points tier, and there isn't one in the TextGrid "+ .tgName$
		selectObject: .thePT
		Remove
	else
		# being here means there IS a Points tier
		.numPoints = Get number of points: tierPoints
		if (.numPoints = 0)
			# being here means there's no labels on the Points tier
			exitScript: "This script requires a labelled Points tier, and there isn't one in the TextGrid "+ .tgName$
			selectObject: .thePT
			Remove
		else
			# being here means there IS a Points tier with at least 1 label
			
			# cycle over the Points tier labels
			for x to .numPoints
				# get the time and label of the Points label and send it to the @getF0Here function to read the comma override or measure the f0
				selectObject: .theTg
				.thePointTime = Get time of point: tierPoints, x
				.thePointLabel$ = Get label of point: tierPoints, x
				@getF0Here: .thePointTime, .thePointLabel$, .thePitchObj

				# add to the PitchTier a point whose coordinates are: the time of the Points label, and the f0 value from @getF0Here 
				selectObject: .thePT
				Add point: .thePointTime, getF0Here.thisF0
			endfor
		endif
	endif
	
	# if a PitchTier object is created successfully,
	# it is saved as createPitchTierFromTG.thePT
endproc


# --------------------
# 
#	Procedure debug
#	(Used to write messages to a pop-up window)
# 
# --------------------
procedure debug: .message$
	beginPause: "Debugging"
		comment: .message$
	endPause: "Continue", 1
endproc


# --------------------
# 
#	Procedure findGlobalMinMax
#	(Used to extract F0 min/max information encoded in the Ranges tier, if it exists)
# 
# --------------------
procedure findGlobalMinMax: .theTg
	if not (variableExists ("f0Min") and variableExists ("f0Max"))
		f0Min=55
		f0Max=700
	endif
	if not variableExists ("tierRanges")
		@findPoLaRTiers: .theTg
	endif
	.globalMin = f0Min
	.globalMax = f0Max
	if tierRanges >0
		.globalMin = 10000
		.globalMax = 0
		# Query TG tier 'tierRanges' for number of intervals
		selectObject: .theTg
		.numRanges = Get number of intervals: tierRanges
		.numLabeledRanges = 0

		for x to .numRanges
			selectObject: .theTg
			.intervalLabel$ = Get label of interval: tierRanges, x
			@parseRanges: .intervalLabel$
			if parseRanges.localMin = undefined or parseRanges.localMax = undefined
				.numLabeledRanges = .numLabeledRanges
			else
				.numLabeledRanges += 1
			endif
			if parseRanges.localMin < .globalMin
				.globalMin = parseRanges.localMin
			endif
			if parseRanges.localMax > .globalMax
				.globalMax = parseRanges.localMax
			endif
		endfor

		#if there are no (validly) labelled Ranges intervals, then find .globalMin and .globalMax on the basis of raw f0 measurments by Praat
		if .numLabeledRanges = 0
			if variableExists("fromTGE")
				if fromTGE = 1
					selectObject: sndObj
				else
					beginPause: "User input needed"
						comment: "In the Praat objects window, please select the relevant Sound object."
						comment: "Press 'Continue' below after you have done so."
					endPause: "Continue", "Cancel", 1, 2
					theSound = selected("Sound",1)
				endif
			else
				beginPause: "User input needed"
					comment: "In the Praat objects window, please select the relevant Sound object."
					comment: "Press 'Continue' below after you have done so."
				endPause: "Continue", "Cancel", 1, 2
				theSound = selected("Sound",1)
			endif
			soundName$ = selected$("Sound",1)
			pitchName$ = soundName$
			if not variableExists ("voice_unvoiced_cost")
				time_step=0.0025
				number_of_candidates=15
				very_accurate=1
				silence_threshold=0.03
				voicing_threshold=0.5
				octave_cost=0.05
				octave_jump_cost=0.5
				voice_unvoiced_cost=0.2
			endif
			.thePitch = To Pitch (ac): time_step, f0Min, number_of_candidates, very_accurate, silence_threshold, voicing_threshold, octave_cost, octave_jump_cost, voice_unvoiced_cost, f0Max
			selectObject: .thePitch
			.globalMin = Get minimum: 0.0, 0.0, "Hertz", "Parabolic"
			.globalMax = Get maximum: 0.0, 0.0, "Hertz", "Parabolic"
			selectObject: .thePitch
			Remove
		endif

		#FOR DEBUGGING:
		#@logging:".globalMin = "+string$('.globalMin')
		#@logging:".globalMax = "+string$('.globalMax')
	endif
endproc


# --------------------
# 
#	Procedure findPoLaRTiers
#	(Used to extract F0 min/max information encoded in the Ranges tier, if it exists)
# 
# --------------------
procedure findPoLaRTiers: .theTg
	selectObject: .theTg
	nTiers = Get number of tiers
	tierWords = 0
	tierPhones = 0
	tierPrStr = 0
	tierPoints = 0
	tierLevels = 0
	tierSTLevels = 0
	tierRanges = 0
	tierMisc = 0
	tierPseudo = 0
	for x to nTiers
		thisTierName$ = Get tier name: x
		# First, transform to lower case to avoid issues there
		lowercaseTierName$ = replace_regex$ (thisTierName$, "[A-Z]", "\L&", 0) 
		if index_regex (lowercaseTierName$, "word") > 0
			tierWords = x
		elsif index_regex (lowercaseTierName$, "phone") > 0
			tierPhones = x
		elsif index_regex (lowercaseTierName$, "prstr") > 0
			tierPrStr = x
		elsif index_regex (lowercaseTierName$, "points") > 0
			tierPoints = x
		elsif index_regex (lowercaseTierName$, "levels") > 0
			tierLevels = x
		elsif index_regex (lowercaseTierName$, "st-lvl") > 0
			tierSTLevels = x
		elsif index_regex (lowercaseTierName$, "ranges") > 0
			tierRanges = x
		elsif index_regex (lowercaseTierName$, "misc") > 0
			tierMisc = x
		elsif index_regex (lowercaseTierName$, "pseudo") > 0
			tierPseudo = x
		elsif index_regex (lowercaseTierName$, "phon") > 0
			tierPhones = x
		endif
	endfor
endproc


# --------------------
# 
#	Procedure getF0Here
#	(used to determine what the script should consider as the f0 value, at this point in time)
# 
# --------------------
procedure getF0Here: .thePointTime, .thePointLabel$, .thePitchObj
	# Start by initiating a variable with no value
	.thisF0 = undefined

	# Get the f0 at the time '.thePointTime' by either (in order of priority)
	#  - extracting the number from a "comma label" in the Points tier object
	#  - measuring the f0 using Praat's tracking

	.commaSep$ = "[,(]"
	if index_regex(.thePointLabel$, .commaSep$) > 0
		# If there is a comma in the Points tier object, parse it out
		@parseCommaOverride
		.thisF0 = parseCommaOverride.commaOverride
	else
		# If there is no comma in the Points tier object, measure f0 directly
		@measureWindowedF0Average
		.thisF0 = measureWindowedF0Average.resultF0
	endif
endproc





# --------------------
# 
#	Procedure handEditPoints
#	(Used to open a Manipulation window for audio-visual editing of f0 turning points)
# 
# --------------------
procedure handEditPoints: .theSnd, .theTg, .thePT
	@findPoLaRTiers: .theTg
	
	if (tierPoints = 0)
		.theSnd = .theSnd
		.theTg = .theTg
		.thePT = .thePT
		selectObject: .theTg
		.tgName$ = selected$("TextGrid")
		@logging: "There is no Points tier for the TextGrid " + .tgName$ + ". This file was skipped."
	else
		# check for open TG editors and close all of them
		originallySelectedObjects# = selected#()
		editorsAreOpen = 1
		while (editorsAreOpen = 1)
			nocheck editor: .theTg
				editorInfo$ = nocheck Editor info
			nocheck endeditor
			if length (editorInfo$) > 0
				editorsAreOpen = 1
				editor: .theTg
					Close
				endeditor
			else
				editorsAreOpen = 0
			endif
		endwhile
		selectObject: originallySelectedObjects#

		# open a new TG editor window
		selectObject: .theSnd, .theTg
		View & Edit

		# for identifying the f0min/max in this recording
		tempF0min = 10000
		tempF0max = 0

		selectObject: .thePT
		nTargets = Get number of points
		for iTarget from 1 to nTargets
			selectObject: .thePT
			time = Get time from index... iTarget
			f0 = Get value at index... iTarget

			# tracking global min/max:
			if (f0 > tempF0max) 
				tempF0max = f0
			endif
			if (f0 < tempF0min)
				tempF0min = f0
			endif
		endfor

		# round the global min/max down/up to the nearest 10
		.rangeF0min = floor(tempF0min/10)*10
		.rangeF0max = ceiling(tempF0max/10)*10

		selectObject: .theSnd
		.theManip = To Manipulation: 0.01, .rangeF0min, .rangeF0max
		plus .thePT
		Replace pitch tier

		select .theManip
		Edit
		editor: .theManip
		Set pitch range: .rangeF0min, .rangeF0max
		endeditor
		beginPause: "Hand-correct the Points targets"
			comment: "Adjust the location of turning points in the Manipulation window, as necessary."
			comment: "Then come back to this window and select an option below."
			comment: "(Pressing 'Stop' quits the script without saving any changes.)"
		saveIt = endPause: "Leave Unchanged", "Save Changes", 2

		if (saveIt = 2)
			selectObject: .thePT
			Remove

			selectObject: .theManip
			.thePT = Extract pitch tier

			# blank out Points and Levels tiers
			selectObject: .theTg
			Remove tier: tierPoints
			Insert point tier: tierPoints, "Points"
			Remove tier: tierLevels
			Insert point tier: tierLevels, "Levels"

			# for identifying the f0min/max in this recording
			tempF0min = 10000
			tempF0max = 0

			selectObject: .thePT
			nTargets = Get number of points
			for iTarget from 1 to nTargets
				selectObject: .thePT
				time = Get time from index... iTarget
				f0 = Get value at index... iTarget

				# tracking global min/max:
				if (f0 > tempF0max) 
					tempF0max = f0
				endif
				if (f0 < tempF0min)
					tempF0min = f0
				endif

				selectObject: .theTg
				point$ = "0," + string$(floor(f0))
				Insert point: tierPoints, time, point$
			endfor

			# round the global min/max down/up to the nearest 10
			.rangeF0min = floor(tempF0min/10)*10
			.rangeF0max = ceiling(tempF0max/10)*10

			# write the global min/max again, in case it's changed
			selectObject: .theTg
			range$ = string$(.rangeF0min)+"-"+string$(.rangeF0max)
			Set interval text: tierRanges, 1, range$
	
			@pitchTierToLevelsLabels: .theTg, .thePT, .rangeF0min, .rangeF0max
		endif
		selectObject: .theManip
		Remove
	endif
	selectObject: .theSnd, .theTg, .thePT
endproc



# --------------------
# 
#	Procedure logging
#	(Used to write messages to info window, or to a file, depending on the variables)
# 
# --------------------
procedure logging: .message$
	if numLogs = 0
		numLogs = 1
		writeInfoLine: .message$
	else
		appendInfoLine: .message$
	endif
endproc


# --------------------
# 
#	Procedure measureWindowedF0Average
#	(measure the average an f0 value over 10 ms window centered at a the time for this Point)
# 
# --------------------
procedure measureWindowedF0Average:
	.windowStart = getF0Here.thePointTime - 0.0025
	.windowEnd = getF0Here.thePointTime + 0.0025
	selectObject: getF0Here.thePitchObj
	.resultF0 = Get mean: .windowStart, .windowEnd, "Hertz"

	# For some reason, getting a mean sometimes returns undefined, even though "get value" returns a value. For those cases:
	if .resultF0 = undefined
		.windowStart = getF0Here.thePointTime
		.windowEnd = getF0Here.thePointTime
		.resultF0 = Get mean: .windowStart, .windowEnd, "Hertz"
	endif

	# In case F0 is coming back undefined still, alert the user
	if .resultF0 = undefined
		@logging: tab$ + ">> ALERT <<" + newline$ + tab$ + tab$ + "There was no f0 detected in the 10 ms window, centered on the Points label at time " + string$(getF0Here.thePointTime) + "." + newline$ + tab$ + tab$ + "The average f0 value for the entire file was used, but this is NOT GOOD."
		.resultF0 = Get mean: 0.0, 0.0, "Hertz"
	endif
endproc


# --------------------
# 
#	Procedure parseCommaOverride
#	(used to extract a value from a "comma override" label in a Points tier object)
# 
# --------------------
procedure parseCommaOverride:
	.commaSep$ = "[,(]"
	.commaPos = rindex_regex (getF0Here.thePointLabel$, .commaSep$)
	afterTheComma$ = mid$(getF0Here.thePointLabel$, (.commaPos+1), (length(getF0Here.thePointLabel$)-.commaPos))

	# Prase out a number from after the comma
	.commaOverride = extractNumber (afterTheComma$, "")

	# Check to see if the parse was successful
	if .commaOverride = undefined
		# If parse was unsuccessful…
		# …first tell the user this happened
			@logging: tab$ + ">> ALERT <<" + newline$ + tab$ + tab$ + "A Points tier label had a “comma label” that could not be parsed, at time " + string$(getF0Here.thePointTime) + newline$ + tab$ + tab$ + "The F0 was measured directly at this time, instead of using a comma override label."
		# …and then measure the f0 directly
		@measureWindowedF0Average
		.commaOverride = measureWindowedF0Average.resultF0
	endif
endproc


# --------------------------------------------------------------------------------
#
#	Procedure parseRanges
#	(Used to extract F0 min/max information encoded in the Ranges tier, if it exists)
#
# --------------------------------------------------------------------------------
procedure parseRanges: .intervalLabel$
	.localMin = undefined
	.localMax = undefined
	# Parse the Ranges label into two strings: one for either side of the dash(es)
	.separator$ = "[-–—]+"
	.lSep = index_regex (.intervalLabel$, .separator$)
	.leftOfSep$ = left$(.intervalLabel$, .lSep-1)
	.rSep = rindex_regex (.intervalLabel$, .separator$)
	.rightOfSep$ = mid$(.intervalLabel$, .rSep+1, length(.intervalLabel$)-.rSep+1)

	# Note: there is a weird thing in Praat with the "extractNumber" function. If the string
	#       contains a '/' in it somewhere, it fails to extract the number, instead returning
	#       undefined. So, as a hack, all of these strings are having any '/' removed through
	#       the 'replace$' function.
	.leftOfSep$ = replace$(.leftOfSep$, "/", "", 0)
	.rightOfSep$ = replace$(.rightOfSep$, "/", "", 0)

	# For the left side of the dash (i.e., the min):
	# First, extract the first number in the string:
	.minOutOfParens = extractNumber(.leftOfSep$, "")
	# Check if there are parentheses labels. If so, extract the number that comes after the open-parens.
	# If not, extract the number from the left-side of the dash.
	.llParen = index_regex (.leftOfSep$, "\(")
	if .llParen > 0
		.localMin = extractNumber(.leftOfSep$, "(")
	else
		.localMin = .minOutOfParens
	endif

	# For the right side of the dash (i.e., the max):
	# First, extract the first number in the string from the right-side of the dash:
	.maxOutOfParens = extractNumber(.rightOfSep$, "")
	# Check if there are parentheses labels. If so, extract the number that comes after the open-parens.
	# If not, extract the number from the right-side of the dash.
	.rlParen = index_regex (.rightOfSep$, "\(")
	if .rlParen > 0
		.localMax = extractNumber(.rightOfSep$, "(")
	else
		.localMax = .maxOutOfParens
	endif
endproc


# --------------------------------------------------------------------------------
#
#	Procedure parseRangesIgnoreParens
#	(Used to extract F0 min/max information encoded in the Ranges tier, if it exists)
#
# --------------------------------------------------------------------------------

procedure parseRangesIgnoreParens: .intervalLabel$
	# Parse the Ranges label into two strings: one for either side of the dash(es)
	.separator$ = "[-–—]+"
	.lSep = index_regex (.intervalLabel$, .separator$)
	.leftOfSep$ = left$(.intervalLabel$, .lSep-1)
	.rSep = rindex_regex (.intervalLabel$, .separator$)
	.rightOfSep$ = mid$(.intervalLabel$, .rSep+1, length(.intervalLabel$)-.rSep+1)

	# Note: there is a weird thing in Praat with the "extractNumber" function. If the string
	#       contains a '/' in it somewhere, it fails to extract the number, instead returning
	#       undefined. So, as a hack, all of these strings are having any '/' removed through
	#       the 'replace$' function.
	.leftOfSep$ = replace$(.leftOfSep$, "/", "", 0)
	.rightOfSep$ = replace$(.rightOfSep$, "/", "", 0)

	# For the left side of the dash (i.e., the min), extract the number from the left-side of the dash.
	.localMin = extractNumber(.leftOfSep$, "")

	# For the right side of the dash (i.e., the max), extract the number from the right-side of the dash.
	.localMax = extractNumber(.rightOfSep$, "")
endproc


# --------------------
# 
#	Procedure pitchTierToLevelsLabels
#	(Used to add Levels on the basis of the f0 values in the PitchTier and specified min/max)
# 
# --------------------
procedure pitchTierToLevelsLabels: .theTg, .thePT, .rangeMin, .rangeMax
	selectObject: .thePT
	nPts = Get number of points

	@findPoLaRTiers: .theTg

	for xPt from 1 to nPts
		selectObject: .thePT
		t = Get time from index: xPt
		pt = Get value at index: xPt
		@transformF0ToLevel: pt, .rangeMin, .rangeMax
		.lvl$ = transformF0ToLevel.theLevel$
		
		selectObject: .theTg
		Insert point: tierLevels, t, .lvl$
	endfor
endproc


# --------------------
# 
#	Procedure pointingAtWhatPrStr
#	(Find the PrStr tier label(s) that an advanced Points label is pointing at)
# 
# --------------------
procedure pointingAtWhatPrStr: .point$, .pointTime
	selectObject: theTg
	.pointsNumMax = Get number of points: tierPoints

	#deconstruct Points label into parts
	#start by seeing if there is a *, ], or [ in the Points label
	.pointTypeChar = index_regex(.point$, "[\*\[\]]")
	if .pointTypeChar > 0
		#store the *, ], or [ character as the "type" of this advanced Point
		.pointType$ = mid$(.point$, .pointTypeChar, 1)
		
		#get the pointer character (>, <, or @) and store it as the "pointer" for this advanced Point
		.pointPointerChar = index_regex(.point$, "[<>@]")
		.pointPointer$ = mid$(.point$, .pointPointerChar, 1)

		#this variable will be set to the "type" of PrStr labels, but initialize it as ""
		.prstrType$ = ""
		
		# if we're looking leftwards, we're going to be moving backwards through PrStr labels
		if .pointPointer$ == "<"
			x = 0

			# get the index of the PrStr label that is at/before the time of this Points tier label
			.prStrIndex = Get low index from time: tierPrStr, .pointTime

			# this while loop incrementally moves leftward on the PrStr tier, looking for PrStr labels that have the same "type" as the advanced Points label
			while .prstrType$ != .pointType$ && .prStrIndex > 0
				.prStrIndex = .prStrIndex - x
				.prstr$ = Get label of point: tierPrStr, .prStrIndex
				.prstrTime = Get time of point: tierPrStr, .prStrIndex
				.prstrTypeChar = index_regex(.prstr$, "[\*\[\]]")
				.prstrType$ = mid$(.prstr$, .prstrTypeChar, 1)
				x = x + 1
			endwhile

		# if we're looking rightwards (or at the same time), we're going to be moving forwards through PrStr labels
		# (note that the "@" type is collapsed with this one… maybe return to this to make it only work for "@" type pointers if there is a PrStr label within a narrow time window…)
		elsif (.pointPointer$ == ">" || .pointPointer$ == "@")
			x = 0
			.prStrIndex = Get high index from time: tierPrStr, .pointTime

			# this while loop incrementally moves rightward on the PrStr tier, looking for PrStr labels that have the same "type" as the advanced Points label
			while .prstrType$ != .pointType$ && .prStrIndex < .pointsNumMax
				.prStrIndex = .prStrIndex + x
				.prstr$ = Get label of point: tierPrStr, .prStrIndex
				.prstrTime = Get time of point: tierPrStr, .prStrIndex
				.prstrTypeChar = index_regex(.prstr$, "[\*\[\]]")
				.prstrType$ = mid$(.prstr$, .prstrTypeChar, 1)
				x = x + 1
			endwhile

		# what if the Points label doesn't contain a <, >, or @?
		else
			# set variables to indicate this
			.prStrIndex = 0
			.prstrTime = 0
			.prstr$ = ""
			.prstrType$ = ""
		endif

		# if there is a "/" in the Points label, we'll need to do this again for the advanced Points label that's after the slash
		# (I'm assuming a maximum of one "/" per Points label… there might be edge cases I'm not thinking of)
		if index(.point$, "/") > 0

			# the contents of this if-statement chunk are IDENTICAL to the code above, except that it saves all the info into different variables
			
			.partB$ = mid$(.point$, index(.point$, "/")+1, length(.point$)-index(.point$, "/"))
			.pointTypeCharB = index_regex(.partB$, "[\*\[\]]")
			.pointTypeB$ = mid$(.partB$, .pointTypeCharB, 1)
			.pointPointerCharB = index_regex(.partB$, "[<>@]")
			.pointPointerB$ = mid$(.partB$, .pointPointerCharB, 1)

			.pointTypeB$ = ""
			if .pointPointerB$ == "<" && .prStrIndexB > 0
				x = 0
				.prStrIndexB = Get low index from time: tierPrStr, .pointTime
				while .prstrTypeB$ != .pointTypeB$
					.prStrIndexB = .prStrIndexB - x
					.prstrB$ = Get label of point: tierPrStr, .prStrIndexB
					.prstrTimeB = Get time of point: tierPrStr, .prStrIndexB
					.prstrTypeCharB = index_regex(.prstrB$, "[\*\[\]]")
					.prstrTypeB$ = mid$(.prstrB$, .prstrTypeCharB, 1)
					x = x + 1
				endwhile
			elsif (.pointPointerB$ == ">" || .pointPointerB$ == "@")
				x = 0
				.prStrIndexB = Get high index from time: tierPrStr, .pointTime
				while .prstrTypeB$ != .pointTypeB$ && .prStrIndexB < .pointsNumMax
					.prStrIndexB = .prStrIndexB + x
					.prstrB$ = Get label of point: tierPrStr, .prStrIndexB
					.prstrTimeB = Get time of point: tierPrStr, .prStrIndexB
					.prstrTypeCharB = index_regex(.prstrB$, "[\*\[\]]")
					.prstrTypeB$ = mid$(.prstrB$, .prstrTypeCharB, 1)
					x = x + 1
				endwhile
			endif
			else
				.prStrIndexB = 0
				.prstrTimeB = 0
				.prstrB$ = ""
				.prstrTypeB$ = ""

		# what if there is no "/" in the advanced Points label?
		else
			# set variables to indicate this
			.prStrIndexB = 0
			.prstrTimeB = 0
			.prstrB$ = ""
			.prstrTypeB$ = ""
		endif
	else
		# if in here, there are *no* PrStr labels being pointed at
		.prStrIndex = 0
		.prstr$ = ""
		.prstrTime = 0
		.prstrType$ = ""
		.prStrIndexB = 0
		.prstrB$ = ""
		.prstrTimeB = 0
		.prstrTypeB$ = ""
	endif
endproc


# --------------------
# 
#	Procedure pointingAtWhatPrStr
#	(Find the PrStr tier label(s) that an advanced Points label is pointing at)
# 
# --------------------
procedure pointingAtWhatPrStr: .point$, .pointTime
	selectObject: theTg
	.pointsNumMax = Get number of points: tierPoints

	#deconstruct Points label into parts
	#start by seeing if there is a *, ], or [ in the Points label
	.pointTypeChar = index_regex(.point$, "[\*\[\]]")
	if .pointTypeChar > 0
		#store the *, ], or [ character as the "type" of this advanced Point
		.pointType$ = mid$(.point$, .pointTypeChar, 1)
		
		#get the pointer character (>, <, or @) and store it as the "pointer" for this advanced Point
		.pointPointerChar = index_regex(.point$, "[<>@]")
		.pointPointer$ = mid$(.point$, .pointPointerChar, 1)

		#this variable will be set to the "type" of PrStr labels, but initialize it as ""
		.prstrType$ = ""
		
		# if we're looking leftwards, we're going to be moving backwards through PrStr labels
		if .pointPointer$ == "<"
			x = 0

			# get the index of the PrStr label that is at/before the time of this Points tier label
			.prStrIndex = Get low index from time: tierPrStr, .pointTime

			# this while loop incrementally moves leftward on the PrStr tier, looking for PrStr labels that have the same "type" as the advanced Points label
			while .prstrType$ != .pointType$ && .prStrIndex > 0
				.prStrIndex = .prStrIndex - x
				.prstr$ = Get label of point: tierPrStr, .prStrIndex
				.prstrTime = Get time of point: tierPrStr, .prStrIndex
				.prstrTypeChar = index_regex(.prstr$, "[\*\[\]]")
				.prstrType$ = mid$(.prstr$, .prstrTypeChar, 1)
				x = x + 1
			endwhile

		# if we're looking rightwards (or at the same time), we're going to be moving forwards through PrStr labels
		# (note that the "@" type is collapsed with this one… maybe return to this to make it only work for "@" type pointers if there is a PrStr label within a narrow time window…)
		elsif (.pointPointer$ == ">" || .pointPointer$ == "@")
			x = 0
			.prStrIndex = Get high index from time: tierPrStr, .pointTime

			# this while loop incrementally moves rightward on the PrStr tier, looking for PrStr labels that have the same "type" as the advanced Points label
			while .prstrType$ != .pointType$ && .prStrIndex < .pointsNumMax
				.prStrIndex = .prStrIndex + x
				.prstr$ = Get label of point: tierPrStr, .prStrIndex
				.prstrTime = Get time of point: tierPrStr, .prStrIndex
				.prstrTypeChar = index_regex(.prstr$, "[\*\[\]]")
				.prstrType$ = mid$(.prstr$, .prstrTypeChar, 1)
				x = x + 1
			endwhile

		# what if the Points label doesn't contain a <, >, or @?
		else
			# set variables to indicate this
			.prStrIndex = 0
			.prstrTime = 0
			.prstr$ = ""
			.prstrType$ = ""
		endif

		# if there is a "/" in the Points label, we'll need to do this again for the advanced Points label that's after the slash
		# (I'm assuming a maximum of one "/" per Points label… there might be edge cases I'm not thinking of)
		if index(.point$, "/") > 0

			# the contents of this if-statement chunk are IDENTICAL to the code above, except that it saves all the info into different variables
			
			.partB$ = mid$(.point$, index(.point$, "/")+1, length(.point$)-index(.point$, "/"))
			.pointTypeCharB = index_regex(.partB$, "[\*\[\]]")
			.pointTypeB$ = mid$(.partB$, .pointTypeCharB, 1)
			.pointPointerCharB = index_regex(.partB$, "[<>@]")
			.pointPointerB$ = mid$(.partB$, .pointPointerCharB, 1)

			.pointTypeB$ = ""
			if .pointPointerB$ == "<" && .prStrIndexB > 0
				x = 0
				.prStrIndexB = Get low index from time: tierPrStr, .pointTime
				while .prstrTypeB$ != .pointTypeB$
					.prStrIndexB = .prStrIndexB - x
					.prstrB$ = Get label of point: tierPrStr, .prStrIndexB
					.prstrTimeB = Get time of point: tierPrStr, .prStrIndexB
					.prstrTypeCharB = index_regex(.prstrB$, "[\*\[\]]")
					.prstrTypeB$ = mid$(.prstrB$, .prstrTypeCharB, 1)
					x = x + 1
				endwhile
			elsif (.pointPointerB$ == ">" || .pointPointerB$ == "@")
				x = 0
				.prStrIndexB = Get high index from time: tierPrStr, .pointTime
				while .prstrTypeB$ != .pointTypeB$ && .prStrIndexB < .pointsNumMax
					.prStrIndexB = .prStrIndexB + x
					.prstrB$ = Get label of point: tierPrStr, .prStrIndexB
					.prstrTimeB = Get time of point: tierPrStr, .prStrIndexB
					.prstrTypeCharB = index_regex(.prstrB$, "[\*\[\]]")
					.prstrTypeB$ = mid$(.prstrB$, .prstrTypeCharB, 1)
					x = x + 1
				endwhile
			endif
			else
				.prStrIndexB = 0
				.prstrTimeB = 0
				.prstrB$ = ""
				.prstrTypeB$ = ""

		# what if there is no "/" in the advanced Points label?
		else
			# set variables to indicate this
			.prStrIndexB = 0
			.prstrTimeB = 0
			.prstrB$ = ""
			.prstrTypeB$ = ""
		endif
	else
		# if in here, there are *no* PrStr labels being pointed at
		.prStrIndex = 0
		.prstr$ = ""
		.prstrTime = 0
		.prstrType$ = ""
		.prStrIndexB = 0
		.prstrB$ = ""
		.prstrTimeB = 0
		.prstrTypeB$ = ""
	endif
endproc



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
#	Procedure roundTo
#	(Used to round a number to a particular number of decimal places)
# 
# --------------------
procedure roundTo: .num, .places
	.temp = .num * 10^.places
	.result = round(.temp) / 10^.places
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



# --------------------
# 
#	Procedure warningMsg
#	(Used to write messages to a pop-up window)
# 
# --------------------
procedure warningMsg: .message$
	beginPause: "WARNING"
		comment: .message$
	endPause: "Continue", 1
endproc


# --------------------
# 
#	Procedure versionChecker
#	(Used to write messages to a pop-up window)
# 
# --------------------
procedure versionChecker: .major, .minor, .build
	dot1 = index(praatVersion$, ".")
	majorVers = number(left$(praatVersion$, dot1-1))
	nonMajorVers$ = right$(praatVersion$, length(praatVersion$)-dot1)
	dot2 = index(nonMajorVers$, ".")
	if dot2 > 0
		minorVers = number(left$(nonMajorVers$, dot2-1))
		buildVers = number(replace_regex$(right$(nonMajorVers$, length(nonMajorVers$)-dot2), "[^0-9]", "", 0))
	else
		minorVers = number(replace_regex$(nonMajorVers$, "[^0-9]", "", 0))
		buildVers = 0
	endif

	build$ = string$(.build)
	if length(build$) == 1
	build$ = "0" + build$
	endif
	minVersion$ = string$(.major) + "." + string$(.minor) + "." + build$

	if majorVers < .major
		exitScript: "Your Praat is OUT OF DATE. This script requires version " + minVersion$ + " or newer. Download the latest version from https://praat.org."
	elsif (majorVers = .major) and (minorVers < .minor)
		exitScript: "Your Praat is OUT OF DATE. This script requires version " + minVersion$ + " or newer. Download the latest version from https://praat.org."
	elsif (majorVers = .major) and (minorVers = .minor) and (buildVers < .build)
		exitScript: "Your Praat is OUT OF DATE. This script requires version " + minVersion$ + " or newer. Download the latest version from https://praat.org."
	endif
endproc