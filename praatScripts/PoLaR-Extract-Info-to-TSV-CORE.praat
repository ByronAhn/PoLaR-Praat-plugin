################################################################
###
### PoLaR-Extract-Info-to-TSV-CORE
### v.2021.12.05
###
###
### This script extracts PoLaR labels (and measures related to those PoLaR labels) into one or more .TSV files, which
### can be loaded into spreadsheet / statistical software.
### 
### Notes:
###  - Your TextGrid(s) must have PoLaR tiers named appropriately
###      * i.e., "PrStr", "Points", "Levels", and "Ranges"
###      * even better if you have a "Words" tier!
###  - If any tiers are missing, the script may run, but produce outputs that are not (as) complete (as they could be)
###
###
###         > > >  NOTE  < < <
###  If you are having troubles, make sure your PoLaR tiers are named appropriately
###
###
###
###	Byron Ahn (bta@princeton.edu)
###	Attribution-ShareAlike 2.5 license
###
################################################################


# --------------------
# 
#	Procedure extractInfoMain
#	(The main function)
# 
# --------------------
procedure extractInfoMain
	@versionChecker: 6, 1, 0
	header$ = "Filename" + tab$ + "Tier name" + tab$ + "Label" + tab$ + "(Start) Time [sec]" + tab$ + "End Time [sec]" + tab$ + "Timing wrt Words" + tab$ + "Timing wrt Phones" + tab$ + "(Start) F0 value [Hz]" + tab$ + "End F0 value [Hz]" + tab$ + "Avg F0 value [Hz]" + tab$ + "F0 Range (Hz)" + tab$ + "Levels value" + tab$ + "(Start) Intensity value [dB]" + tab$ + "End Intensity value [dB]" + tab$ + "Avg Intensity value [dB]"

	#if being called from a script the runs over multiple files, set the following variable to '1' in that script
	#this prevents the header from being written out too many times 
	if create_A_Single_Output_File = 0
		numOutputs = 0
		@writeThisInfo: header$
	endif
	@saveSelection
	# Ensure that exactly one Sound object and one TextGrid object are selected
	if numberOfSelected () <> 2
		exitScript: "Select exactly one Sound file AND one TextGrid file."
	else
		soundName$ = selected$ ("Sound", 1)
		tgName$ = selected$ ("TextGrid", 1)
		if soundName$ = ""
			exitScript: "You must select a Sound file"
		endif
		if tgName$ = ""
			exitScript: "You must select a TextGrid file"
		endif
		theSound = selected ("Sound", 1)
		theTg = selected ("TextGrid", 1)
	endif

	#figure out where the PoLaR tiers are
	@findPoLaRTiers: theTg

	#figure out the global f0 min/max for these PoLaR labels
	@findGlobalMinMax: theTg
	globalMin = findGlobalMinMax.globalMin
	globalMax = findGlobalMinMax.globalMax

	# Create a Pitch object for this recording
	#   For pitch settings, the F0 Min/Max are set by the variables localMin/localMax, based on the local Range interval label.
	#   The other pitch settings are set by the pop-up at the beginning of the script.
	selectObject: theSound
	thePitch = To Pitch (ac): time_step, globalMin, number_of_candidates, very_accurate, silence_threshold, voicing_threshold, octave_cost, octave_jump_cost, voice_unvoiced_cost, globalMax

	# Create an Intensity object for this recording
	selectObject: theSound
	theIntensity = To Intensity: 50, 0.001, 1

	@returnSelection

	if tierWords > 0
		@extractWords
	endif

	if tierPhones > 0
		@extractPhones
	endif

	if tierPseudo > 0
		@extractPseudo
	endif

	if tierPrStr > 0
		@extractPrStr
	endif

	if tierPoints > 0
		@extractPoints
	endif

	if tierRanges > 0
		@extractRanges
	endif

#	@overall

	selectObject: thePitch, theIntensity
	Remove

	@returnSelection
endproc


# --------------------
# 
#	Procedure extractWords
#	(Used to extract the info from the Words tier)
# 
# --------------------
procedure extractWords
	selectObject: theTg

	# Query TG tier 'tierWords' for number of intervals
	numWords = Get number of intervals: tierWords
	for x to numWords
		selectObject: theTg
		.recordingEnd = Get end time
		.theWord$ = Get label of interval: tierWords, x
		.wordIntStart = Get start time of interval: tierWords, x
		.wordIntEnd = Get end time of interval: tierWords, x

		#Timing wrt Phones
		.thePhones$ = "NA"
		if tierPhones > 0
			.firstPhonesInt = Get interval at time: tierPhones, .wordIntStart
			.lastPhonesInt = Get interval at time: tierPhones, .wordIntEnd

			#when the time is precisely at the boundary between two intervals, "Get interval at time" seems to select the second interval. when the time is precisely at the end of the file, it reports the last interval.
			#so the last phone is the one previous to the one identified by the tiem of the word interval end (above) -- i.e., we need to subtract one:
			#but if the last word interval goes until the end of the recording, don't subtract one
			if .wordIntEnd < .recordingEnd
				.lastPhonesInt = .lastPhonesInt - 1
			endif

			.thePhones$ = "«"
			for .iCnt from .firstPhonesInt to .lastPhonesInt
				.l$ = Get label of interval: tierPhones, .iCnt
				.thePhones$ += .l$
			endfor
			.thePhones$ += "»"
		endif

		#F0-related values
		selectObject: thePitch
		.startF0 = Get value at time: .wordIntStart, "Hertz", "nearest"
		.endF0 = Get value at time: .wordIntEnd, "Hertz", "nearest"
		.avgF0 = Get mean: .wordIntStart, .wordIntEnd, "Hertz"

		#Intensity-related values
		selectObject: theIntensity
		.startIntensity = Get value at time: .wordIntStart, "nearest"
		.endIntensity = Get value at time: .wordIntEnd, "nearest"
		.avgIntensity = Get mean: .wordIntStart, .wordIntEnd, "energy"

		extractedWordsInfo$ = soundName$ + tab$ +
			... "Words" + tab$ + 
			... "«"+.theWord$+"»" + tab$ + 
			... string$(.wordIntStart) + tab$ + 
			... string$(.wordIntEnd) + tab$ + 
			... "NA" + tab$ + 
			... .thePhones$ + tab$ + 
			... string$(.startF0) + tab$ + 
			... string$(.endF0) + tab$ + 
			... string$(.avgF0) + tab$ + 
			... "NA" + tab$ + 
			... "NA" + tab$ + 
			... string$(.startIntensity) + tab$ + 
			... string$(.endIntensity) + tab$ + 
			... string$(.avgIntensity)

		@writeThisInfo: extractedWordsInfo$
	endfor
endproc


# --------------------
# 
#	Procedure overall
#	(Used to extract the info from the Words tier)
# 
# --------------------
procedure overall
	selectObject: theTg

	.file.start = Get start time
	.file.end = Get end time

	selectObject: thePitch
	.startF0 = Get value at time: .file.start, "Hertz", "nearest"
	.endF0 = Get value at time: .file.end, "Hertz", "nearest"
	.avgF0 = Get mean: .file.start, .file.end, "Hertz"

	.rangeF0$ = string$(globalMin) + "-" + string$(globalMax)

	#Intensity-related values
	selectObject: theIntensity
	.startIntensity = Get value at time: .file.start, "nearest"
	.endIntensity = Get value at time: .file.end, "nearest"
	.avgIntensity = Get mean: .file.start, .file.end, "energy"


	extractedWordsInfo$ = soundName$ + tab$ +
		... "Overall" + tab$ + 
		... "" + tab$ + 
		... string$(.file.start) + tab$ + 
		... string$(.file.end) + tab$ + 
		... "NA" + tab$ + 
		... "" + tab$ + 
		... string$(.startF0) + tab$ + 
		... string$(.endF0) + tab$ + 
		... string$(.avgF0) + tab$ + 
		... .rangeF0$ + tab$ + 
		... "NA" + tab$ + 
		... string$(.startIntensity) + tab$ + 
		... string$(.endIntensity) + tab$ + 
		... string$(.avgIntensity)

	@writeThisInfo: extractedWordsInfo$
endproc


# --------------------
# 
#	Procedure extractPhones
#	(Used to extract the info from the Phones tier)
# 
# --------------------
procedure extractPhones
	selectObject: theTg

	# Query TG tier 'tierPhones' for number of intervals
	numPhones = Get number of intervals: tierPhones
	for x to numPhones
		selectObject: theTg
		.recordingEnd = Get end time
		.thePhone$ = Get label of interval: tierPhones, x
		.phoneIntStart = Get start time of interval: tierPhones, x
		.phoneIntEnd = Get end time of interval: tierPhones, x

		#Timing wrt Words
		.theWords$ = "NA"
		if tierWords > 0
			.wordsIntAtStart = Get interval at time: tierWords, .phoneIntStart
			.wordsIntAtEnd = Get interval at time: tierWords, .phoneIntEnd

			#when the Phone is not at the end of a Word interval AND does not straddle Word intervals
			if .wordsIntAtStart = .wordsIntAtEnd
				.l$ = Get label of interval: tierWords, .wordsIntAtStart
				.theWords$ = "in «" + .l$ + "»"
			endif

			#when the Phone is at the end of a Word interval OR straddles Word intervals
			if .wordsIntAtStart <> .wordsIntAtEnd
				.thisWordIntStartTime = Get start time of interval: tierWords, .wordsIntAtEnd

				#when the Phone interval is at the end of a Word interval
				if .phoneIntEnd = .thisWordIntStartTime
					.l$ = Get label of interval: tierWords, .wordsIntAtStart
					.theWords$ = "in «" + .l$ + "»"					
				endif

				#when the Phone interval straddles Word intervals
				if .phoneIntEnd > .thisWordIntStartTime
					.l1$ = Get label of interval: tierWords, .wordsIntAtStart
					.l2$ = Get label of interval: tierWords, .wordsIntAtEnd
					.theWords$ = "in «" + .l1$ + "…" + .l2$ + "»"					

				endif
			endif
		endif

		#F0-related values
		selectObject: thePitch
		.startF0 = Get value at time: .phoneIntStart, "Hertz", "nearest"
		.endF0 = Get value at time: .phoneIntEnd, "Hertz", "nearest"
		.avgF0 = Get mean: .phoneIntStart, .phoneIntEnd, "Hertz"

		#Intensity-related values
		selectObject: theIntensity
		.startIntensity = Get value at time: .phoneIntStart, "nearest"
		.endIntensity = Get value at time: .phoneIntEnd, "nearest"
		.avgIntensity = Get mean: .phoneIntStart, .phoneIntEnd, "energy"

		extractedWordsInfo$ = soundName$ + tab$ +
			... "Phones" + tab$ + 
			... "«"+.thePhone$+"»" + tab$ + 
			... string$(.phoneIntStart) + tab$ + 
			... string$(.phoneIntEnd) + tab$ + 
			... .theWords$ + tab$ + 
			... "NA" + tab$ +
			... string$(.startF0) + tab$ + 
			... string$(.endF0) + tab$ + 
			... string$(.avgF0) + tab$ + 
			... "NA" + tab$ + 
			... "NA" + tab$ + 
			... string$(.startIntensity) + tab$ + 
			... string$(.endIntensity) + tab$ + 
			... string$(.avgIntensity)

		@writeThisInfo: extractedWordsInfo$
	endfor
endproc

# --------------------
# 
#	Procedure extractPrStr
#	(Used to extract the info from the PrStr tier)
# 
# --------------------
procedure extractPrStr
	selectObject: theTg

	# Query TG tier 'tierPrStr' for number of points
	numPrStr = Get number of points: tierPrStr
	for x to numPrStr
		selectObject: theTg
		.thePrStr$ = Get label of point: tierPrStr, x
		.theTime = Get time of point: tierPrStr, x

		.thePrStrWord$ = "NA"
		if tierWords > 0
			.wordsInt = Get interval at time: tierWords, .theTime
			#when the time is precisely at the boundary between two intervals, "Get interval at time" seems to select the second interval. when the time is precisely at the end of the file, it reports the last interval.

			.wordsIntStart = Get start time of interval: tierWords, .wordsInt
			.wordsIntEnd = Get end time of interval: tierWords, .wordsInt
			.lastWordsInt = Get number of intervals: tierWords
			.lastWordEnd = Get end time of interval: tierWords, .lastWordsInt

			# The if/else-if/else statements below are used to relate the time of the PrStr point to some interval in the Words tier
			#this tests if it's in the middle of an interval
			if .theTime > .wordsIntStart
				.l$ = Get label of interval: tierWords, .wordsInt
				.thePrStrWord$ = "in «" + .l$ + "»"

			#this tests if the PrStr point is at a boundary between two intervals
			elsif .theTime = .wordsIntStart and .wordsInt > 1
				.l$ = Get label of interval: tierWords, .wordsInt-1
				.thePrStrWord$ = "after «" + .l$ + "»"

			#this tests if it's at the end of the last interval
			elsif .theTime = .lastWordEnd
				.l$ = Get label of interval: tierWords, .wordsInt
				.thePrStrWord$ = "after «" + .l$ + "»"

			#this tests if it's at the beginning of the first interval
			elsif .theTime = .wordsIntStart and .wordsInt = 1
				.l$ = Get label of interval: tierWords, .wordsInt
				.thePrStrWord$ = "before «" + .l$ + "»"

			#I don't think there are other scenarios, but in case there are
			else
				.thePrStrWord$ = "--undefined--"
			endif
		endif

		.thePrStrPhone$ = "NA"
		if tierPhones > 0
			.phonesInt = Get interval at time: tierPhones, .theTime
			#when the time is precisely at the boundary between two intervals, "Get interval at time" seems to select the second interval. when the time is precisely at the end of the file, it reports the last interval.

			.phonesIntStart = Get start time of interval: tierPhones, .phonesInt
			.phonesIntEnd = Get end time of interval: tierPhones, .phonesInt
			.lastPhonesInt = Get number of intervals: tierPhones
			.lastPhoneEnd = Get end time of interval: tierPhones, .lastWordsInt

			# The if/else-if/else statements below are used to relate the time of the PrStr point to some interval in the Words tier
			#this tests if it's in the middle of an interval
			if .theTime > .phonesIntStart
				.l$ = Get label of interval: tierPhones, .phonesInt
				.thePrStrPhone$ = "in «" + .l$ + "»"

			#this tests if the PrStr point is at a boundary between two intervals
			elsif .theTime = .phonesIntStart and .phonesInt > 1
				.l$ = Get label of interval: tierPhones, .phonesInt-1
				.thePrStrPhone$ = "after «" + .l$ + "»"

			#this tests if it's at the end of the last interval
			elsif .theTime = .lastPhoneEnd
				.l$ = Get label of interval: tierPhones, .phonesInt
				.thePrStrPhone$ = "after «" + .l$ + "»"

			#this tests if it's at the beginning of the first interval
			elsif .theTime = .wordsIntStart and .wordsInt = 1
				.l$ = Get label of interval: tierPhones, .phonesInt
				.thePrStrPhone$ = "before «" + .l$ + "»"

			#I don't think there are other scenarios, but in case there are
			else
				.thePrStrPhone$ = "--undefined--"
			endif
		endif

		#F0-related values
		selectObject: thePitch
		.startF0 = Get value at time: .theTime, "Hertz", "nearest"

		#Intensity-related values
		selectObject: theIntensity
		.startIntensity = Get value at time: .theTime, "nearest"

		extractedPrStrInfo$ = soundName$ + tab$ +
			... "PrStr" + tab$ + 
			... .thePrStr$ + tab$ + 
			... string$(.theTime) + tab$ + 
			... "NA" + tab$ + 
			... .thePrStrWord$ + tab$ + 
			... .thePrStrPhone$ + tab$ + 
			... string$(.startF0) + tab$ + 
			... "NA" + tab$ + 
			... "NA" + tab$ +
			... "NA" + tab$ + 
			... "NA" + tab$ +
			... string$(.startIntensity) + tab$ + 
			... "NA" + tab$ + 
			... "NA"

		@writeThisInfo: extractedPrStrInfo$
	endfor
endproc


# --------------------
# 
#	Procedure extractPseudo
#	(Used to extract the info from the Pseudo tier)
# 
# --------------------
procedure extractPseudo
	selectObject: theTg

	# Query TG tier 'tierPseudo' for number of points
	numPseudo = Get number of points: tierPseudo
	for x to numPseudo
		selectObject: theTg
		.thePseudo$ = Get label of point: tierPseudo, x
		.theTime = Get time of point: tierPseudo, x

		.thePseudoWord$ = "NA"
		if tierWords > 0
			.wordsInt = Get interval at time: tierWords, .theTime
			#when the time is precisely at the boundary between two intervals, "Get interval at time" seems to select the second interval. when the time is precisely at the end of the file, it reports the last interval.

			.wordsIntStart = Get start time of interval: tierWords, .wordsInt
			.wordsIntEnd = Get end time of interval: tierWords, .wordsInt
			.lastWordsInt = Get number of intervals: tierWords
			.lastWordEnd = Get end time of interval: tierWords, .lastWordsInt

			# The if/else-if/else statements below are used to relate the time of the Pseudo point to some interval in the Words tier
			#this tests if it's in the middle of an interval
			if .theTime > .wordsIntStart
				.l$ = Get label of interval: tierWords, .wordsInt
				.thePseudoWord$ = "in «" + .l$ + "»"

			#this tests if the Pseudo point is at a boundary between two intervals
			elsif .theTime = .wordsIntStart and .wordsInt > 1
				.l$ = Get label of interval: tierWords, .wordsInt-1
				.thePseudoWord$ = "after «" + .l$ + "»"

			#this tests if it's at the end of the last interval
			elsif .theTime = .lastWordEnd
				.l$ = Get label of interval: tierWords, .wordsInt
				.thePseudoWord$ = "after «" + .l$ + "»"

			#this tests if it's at the beginning of the first interval
			elsif .theTime = .wordsIntStart and .wordsInt = 1
				.l$ = Get label of interval: tierWords, .wordsInt
				.thePseudoWord$ = "before «" + .l$ + "»"

			#I don't think there are other scenarios, but in case there are
			else
				.thePseudoWord$ = "--undefined--"
			endif
		endif

		.thePseudoPhone$ = "NA"
		if tierPhones > 0
			.phonesInt = Get interval at time: tierPhones, .theTime
			#when the time is precisely at the boundary between two intervals, "Get interval at time" seems to select the second interval. when the time is precisely at the end of the file, it reports the last interval.

			.phonesIntStart = Get start time of interval: tierPhones, .phonesInt
			.phonesIntEnd = Get end time of interval: tierPhones, .phonesInt
			.lastPhonesInt = Get number of intervals: tierPhones
			.lastPhoneEnd = Get end time of interval: tierPhones, .lastWordsInt

			# The if/else-if/else statements below are used to relate the time of the Pseudo point to some interval in the Words tier
			#this tests if it's in the middle of an interval
			if .theTime > .phonesIntStart
				.l$ = Get label of interval: tierPhones, .phonesInt
				.thePseudoPhone$ = "in «" + .l$ + "»"

			#this tests if the Pseudo point is at a boundary between two intervals
			elsif .theTime = .phonesIntStart and .phonesInt > 1
				.l$ = Get label of interval: tierPhones, .phonesInt-1
				.thePseudoPhone$ = "after «" + .l$ + "»"

			#this tests if it's at the end of the last interval
			elsif .theTime = .lastPhoneEnd
				.l$ = Get label of interval: tierPhones, .phonesInt
				.thePseudoPhone$ = "after «" + .l$ + "»"

			#this tests if it's at the beginning of the first interval
			elsif .theTime = .wordsIntStart and .wordsInt = 1
				.l$ = Get label of interval: tierPhones, .phonesInt
				.thePseudoPhone$ = "before «" + .l$ + "»"

			#I don't think there are other scenarios, but in case there are
			else
				.thePseudoPhone$ = "--undefined--"
			endif
		endif

		#F0-related values
		selectObject: thePitch
		.startF0 = Get value at time: .theTime, "Hertz", "nearest"

		#Intensity-related values
		selectObject: theIntensity
		.startIntensity = Get value at time: .theTime, "nearest"

		extractedPseudoInfo$ = soundName$ + tab$ +
			... "Pseudo" + tab$ + 
			... .thePseudo$ + tab$ + 
			... string$(.theTime) + tab$ + 
			... "NA" + tab$ + 
			... .thePseudoWord$ + tab$ + 
			... .thePseudoPhone$ + tab$ + 
			... string$(.startF0) + tab$ + 
			... "NA" + tab$ + 
			... "NA" + tab$ +
			... "NA" + tab$ + 
			... "NA" + tab$ +
			... string$(.startIntensity) + tab$ + 
			... "NA" + tab$ + 
			... "NA"

		@writeThisInfo: extractedPseudoInfo$
	endfor
endproc


# --------------------
# 
#	Procedure extractPoints
#	(Used to extract the info from the Points tier, along with Levels and Ranges, if they exist)
# 
# --------------------
procedure extractPoints
	selectObject: theTg
	# Query TG tier 'tierPoints' for number of intervals
	numPoints = Get number of points: tierPoints

	selectObject: thePitch

	# Check to see whether Levels info is available; first assumption is that it's unavailable.
	# If the Levels tier exists and has the same number of points as the Points tier, don't skip it.
	skipLevels = 1
	if tierLevels > 0
		selectObject: theTg
		.numLvlPts = Get number of points: tierLevels
		if .numLvlPts = numPoints
			skipLevels = 0
		else
			skipLevels = 1
			@logging: ">> WARNING about the file named """ + tgName$ + """:"
			@logging: ">>>>  The Levels and Points tiers have different numbers of points is not the same as the number of Points tier points."
			@logging: ">>>>  Did you forget to label the Levels tier?"
			@logging: ""
			numWarnings += 1
		endif
	endif

	for x to numPoints
		selectObject: theTg
		.thePoint$ = Get label of point: tierPoints, x
		.theTime = Get time of point: tierPoints, x

		@getF0Here: .theTime, .thePoint$, thePitch
		.startF0 = getF0Here.thisF0

		#write to file
		extractedPointsInfo$ = "Points" + tab$ + .thePoint$ + tab$ + string$(.theTime) + tab$

		# Append filename before this:
		extractedPointsInfo$ = soundName$ + tab$ + extractedPointsInfo$

		.thePointsWord$ = "NA"
		if tierWords > 0
			selectObject: theTg
			.wordsInt = Get interval at time: tierWords, .theTime
			.word$ = Get label of interval: tierWords, .wordsInt
			.thePointsWord$ = "in «" + .word$ + "»"
		endif

		.thePointsPhone$ = "NA"
		if tierPhones > 0
			selectObject: theTg
			.phonesInt = Get interval at time: tierPhones, .theTime
			.phone$ = Get label of interval: tierPhones, .phonesInt
			.thePointsPhone$ = "in «" + .phone$ + "»"
		endif

		.theLevel$ = "NA"
		if skipLevels = 0
			selectObject: theTg
			.theLevel$ = tab$
			.levelPt = Get nearest index from time: tierLevels, .theTime
			.theLevel$ = Get label of point: tierLevels, .levelPt
		endif

		.thePointsRange$ = "NA"
		if tierRanges > 0
			selectObject: theTg
			.rangesInt = Get interval at time: tierRanges, .theTime
			.range$ = Get label of interval: tierRanges, .rangesInt
			@parseRanges: .range$
			if parseRanges.localMin <> undefined and parseRanges.localMax <> undefined
				.thePointsRange$ = string$(parseRanges.localMin) + "-" + string$(parseRanges.localMax)
			else
				@logging: ">> WARNING about the file named """ + tgName$ + """:"
				@logging: ">>>>  The there is a Points tier object at " + string$(.theTime) + ", and this is in a Range interval without a proper label."
				@logging: ">>>>  Did you label your Ranges tier correctly?"
				@logging: ""
				numWarnings += 1
				.thePointsRange$ = "--cannot be parsed--"
			endif
		endif

		#Intensity-related values
		selectObject: theIntensity
		.startIntensity = Get value at time: .theTime, "nearest"

		extractedPointsInfo$ = soundName$ + tab$ +
			... "Points" + tab$ + 
			... .thePoint$ + tab$ + 
			... string$(.theTime) + tab$ + 
			... "NA" + tab$ + 
			... .thePointsWord$ + tab$ + 
			... .thePointsPhone$ + tab$ + 
			... string$(.startF0) + tab$ + 
			... "NA" + tab$ + 
			... "NA" + tab$ +
			... .thePointsRange$ + tab$ + 
			... .theLevel$ + tab$ +
			... string$(.startIntensity) + tab$ + 
			... "NA" + tab$ + 
			... "NA"

		@writeThisInfo: extractedPointsInfo$
	endfor
endproc


# --------------------
# 
#	Procedure extractRanges
#	(Used to extract the info from the Ranges tier)
# 
# --------------------
procedure extractRanges
	selectObject: theTg

	# Query TG tier 'tierRanges' for number of intervals
	.numRanges = Get number of intervals: tierRanges

	for x to .numRanges
		selectObject: theTg
		.theRange$ = Get label of interval: tierRanges, x
		@parseRanges: .theRange$
		
		#if this Range interval is parse-able, output the start/end time
		if parseRanges.localMin <> undefined and parseRanges.localMax <> undefined
			.rangeStartTime = Get start time of interval: tierRanges, x
			.rangeEndTime = Get end time of interval: tierRanges, x
			
			#if there is a Words tier, output the words that make up this range
			if tierWords > 0
				.wordsInt = Get interval at time: tierWords, .rangeStartTime
				.lastWordsInt = Get interval at time: tierWords, .rangeEndTime
				.theWords$ = "«"
				for xWord from .wordsInt to .lastWordsInt
					.wordStartTime = Get start time of interval: tierWords, xWord
					.wordEndTime = Get end time of interval: tierWords, xWord
					if .wordEndTime <= .rangeEndTime
						.xWord$ = Get label of interval: tierWords, xWord
						if .xWord$ <> ""
							.theWords$ = .theWords$ + .xWord$
						endif
						if xWord < .lastWordsInt and .xWord$ <> ""
							.theWords$ = .theWords$ + " "
						endif
					endif
					if xWord = .lastWordsInt and .wordStartTime < .rangeEndTime
						.xWord$ = Get label of interval: tierWords, xWord
						.theWords$ = .theWords$ + " " + .xWord$
					endif
				endfor
				while right$(.theWords$,1) = " "
					.wordsLen = length(.theWords$)
					.theWords$ = left$(.theWords$, .wordsLen-1)
				endwhile
				.theWords$ = .theWords$ + "»"
			endif

			#if there is a Phones tier, output the phones that make up this range
			if tierPhones > 0
				.phonesInt = Get interval at time: tierPhones, .rangeStartTime
				.lastPhonesInt = Get interval at time: tierPhones, .rangeEndTime
				.thePhones$ = "«"
				for xPhone from .phonesInt to .lastPhonesInt
					.phoneStartTime = Get start time of interval: tierPhones, xPhone
					.phoneEndTime = Get end time of interval: tierPhones, xPhone
					if .phoneEndTime <= .rangeEndTime
						.xPhone$ = Get label of interval: tierPhones, xPhone
						if .xPhone$ <> ""
							.thePhones$ = .thePhones$ + .xPhone$
						endif
					endif
					if xPhone = .lastPhonesInt and .phoneStartTime < .rangeEndTime
						.xPhone$ = Get label of interval: tierPhones, xPhone
						.thePhones$ = .thePhones$ + .xPhone$
					endif
				endfor
				while right$(.thePhones$,1) = " "
					.phonesLen = length(.thePhones$)
					.thePhones$ = left$(.thePhones$, .phonesLen-1)
				endwhile
				.thePhones$ = .thePhones$ + "»"
			endif

			#F0-related values
			selectObject: thePitch
			.startF0 = Get value at time: .rangeStartTime, "Hertz", "nearest"
			.endF0 = Get value at time: .rangeEndTime, "Hertz", "nearest"
			.avgF0 = Get mean: .rangeStartTime, .rangeEndTime, "Hertz"

			#Intensity-related values
			selectObject: theIntensity
			.startIntensity = Get value at time: .rangeStartTime, "nearest"
			.endIntensity = Get value at time: .rangeEndTime, "nearest"
			.avgIntensity = Get mean: .rangeStartTime, .rangeEndTime, "energy"

			extractedRangesInfo$ = soundName$ + tab$ +
				... "Ranges" + tab$ + 
				... .theRange$ + tab$ + 
				... string$(.rangeStartTime) + tab$ + 
				... string$(.rangeEndTime) + tab$ + 
				... .theWords$ + tab$ + 
				... .thePhones$ + tab$ + 
				... string$(.startF0) + tab$ + 
				... string$(.endF0) + tab$ + 
				... string$(.avgF0) + tab$ + 
				... "NA" + tab$ + 
				... "NA" + tab$ + 
				... string$(.startIntensity) + tab$ + 
				... string$(.endIntensity) + tab$ + 
				... string$(.avgIntensity)
			
			@writeThisInfo: extractedRangesInfo$
		endif
	endfor
endproc


# --------------------
# 
#	Procedure writeThisInfo
#	(Output a string to the Info window or to a file)
# 
# --------------------
procedure writeThisInfo: .message$
	if outToFile = 1
		@outputToFile: .message$
	else
		@logging: .message$
	endif
endproc


# --------------------
# 
#	Procedure outputToFile
#	(Output a string to a file)
# 
# --------------------
procedure outputToFile: .message$
	if not variableExists("output_File_Name$")
		outName$ = tgName$ + ".tsv"
		beginPause: "Where should the output file be saved?"
			comment: "Enter the desired filename below;"
			comment: "then click ""Choose Folder"" to choose where to save it."
			sentence: "Output File Name", outName$
		endPause: "Cancel", "Choose Folder", 2
		outDir$ = chooseDirectory$: "Choose the folder to save the .TSV file"
		outputDirFile$ = outDir$ + "/" + output_File_Name$
	else
		if numOutputs = 0
			numOutputs = 1
			writeFileLine: outputDirFile$, .message$
		else
			appendFileLine: outputDirFile$, .message$
		endif
	endif
endproc


include PoLaR-praat-procedures.praat


################################################################
###  
### end of PoLaR-Extract-Info-to-TSV-CORE
### 
################################################################