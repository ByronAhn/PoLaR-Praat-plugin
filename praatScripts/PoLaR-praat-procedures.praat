################################################################
###
### PoLaR-praat-procedures
### v.2021.11.15
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
	.globalMin = f0Min
	.globalMax = f0Max
	if tierRanges >0
		.globalMin = 10000
		.globalMax = 0
		# Query TG tier 'tierRanges' for number of intervals
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

	if majorVers < .major
		exitScript: "Your Praat is OUT OF DATE. To use this script, download the latest version from https://praat.org."
	elsif (majorVers = .major) and (minorVers < .minor)
		exitScript: "Your Praat is OUT OF DATE. To use this script, download the latest version from https://praat.org."
	elsif (majorVers = .major) and (minorVers = .minor) and (buildVers < .build)
		exitScript: "Your Praat is OUT OF DATE. To use this script, download the latest version from https://praat.org."
	endif
endproc