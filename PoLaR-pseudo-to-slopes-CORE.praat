################################################################
###  
### PoLaR-pseudo-to-slopes-CORE
### v.2021.12.05
###

### 
### 
###
###	Byron Ahn
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
	header$ = "Filename" + tab$ + "Tier name" + tab$ + "Label" + tab$ + "(Start) Time [sec]" + tab$ + "Timing wrt Words" + tab$ + "Timing wrt Phones" + tab$ + "Rise min [Hz]" + tab$ + "Rise max [Hz]" + tab$ + "Rise change [Hz]" + tab$ + "Rise start [sec]" + tab$ + "Rise end [sec]" + tab$ + "Rise time [sec]" + tab$ + "Rise slope" + tab$ + "F0 Range (Hz)"

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


	# Discover the tier number in the TextGrid for each of the PoLaR tiers
	selectObject: theTg
	@findPoLaRTiers: theTg
	if tierPseudo = 0
		exitScript: "The TextGrid must contain Pseudo labels"
	else
		numPseudo = Get number of points: tierPseudo
		if numPseudo = 0
			exitScript: "The TextGrid must contain Pseudo labels"
		endif
	endif


	#create a pitch object
	@findGlobalMinMax: theTg
	f0Min = findGlobalMinMax.globalMin
	f0Max = findGlobalMinMax.globalMax
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
	selectObject: theSound
	thePitch = To Pitch (ac): time_step, f0Min, number_of_candidates, very_accurate, silence_threshold, voicing_threshold, octave_cost, octave_jump_cost, voice_unvoiced_cost, f0Max


	selectObject: theTg
	pseudoLabel$# = empty$# (numPseudo)
	times# = zero# (numPseudo)
	prstrType$# = empty$# (numPseudo)
	numStars = 0
	prStrStars# = zero# (numPseudo)
	numBrackets = 0
	prStrBrackets# = zero# (numPseudo)

	for x from 1 to numPseudo
		thePseudo$ = Get label of point: tierPseudo, x
		pseudoLabel$# [x] = thePseudo$
		times# [x] = Get time of point: tierPseudo, x
		if index(thePseudo$, "*") > 0
			prstrType$# [x] = "*"
			numStars += 1
			# if the xth PrStr object is a *, save the value of x in the list of PrStr stars:
			prStrStars# [numStars] = x
		elsif index(thePseudo$, "]") > 0
			prstrType$# [x] = "]"
			numBrackets += 1
			# if the xth PrStr object is a ], save the value of x in the list of PrStr brackets:
			prStrBrackets# [numBrackets] = x
		else
			prstrType$# [x] = "??"
		endif
	endfor

	for y from 1 to numStars
		#appendInfoLine: "star number " + string$(y)
		z = prStrStars# [y]
		@parsePseudoStar: pseudoLabel$# [z]
		if parsePseudoStar.levels# != {undefined}
			@findPseudoPoints: pseudoLabel$# [z], parsePseudoStar.levels#, parsePseudoStar.leadingLen, parsePseudoStar.starLen, parsePseudoStar.trailingLen, times# [z]
			@findPeakValley: parsePseudoStar.levels#
			@slopeCalc: findPeakValley.valleyIndex, findPeakValley.peakIndex
			#appendInfoLine: "Slope for " + pseudoLabel$#[prStrStars#[y]] + ": " + string$(slopeCalc.slope)
			@writePseudo: prStrStars#[y]
		endif
	endfor

	selectObject: thePitch
	Remove
endproc




procedure writePseudo: x
	selectObject: theTg
	# Query TG tier 'tierPseudo' for number of points
	numPseudo = Get number of points: tierPseudo

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

		.thePseudoRange$ = "NA"
		if tierRanges > 0
			.rangesInt = Get interval at time: tierRanges, .theTime
			#when the time is precisely at the boundary between two intervals, "Get interval at time" seems to select the second interval. when the time is precisely at the end of the file, it reports the last interval.

			.rangesIntStart = Get start time of interval: tierRanges, .rangesInt
			.rangesIntEnd = Get end time of interval: tierRanges, .rangesInt
			.lastRangesInt = Get number of intervals: tierRanges
			.lastWordEnd = Get end time of interval: tierRanges, .lastRangesInt

			# The if/else-if/else statements below are used to relate the time of the Pseudo point to some interval in the Ranges tier
			#this tests if it's in the middle of an interval
			if .theTime > .rangesIntStart
				.rangelabel$ = Get label of interval: tierRanges, .rangesInt

			#this tests if the Pseudo point is at a boundary between two intervals
			elsif .theTime = .rangesIntStart and .rangesInt > 1
				.rangelabel$ = Get label of interval: tierRanges, .rangesInt-1

			#this tests if it's at the end of the last interval
			elsif .theTime = .lastWordEnd
				.rangelabel$ = Get label of interval: tierRanges, .rangesInt

			#this tests if it's at the beginning of the first interval
			elsif .theTime = .rangesIntStart and .rangesInt = 1
				.rangelabel$ = Get label of interval: tierRanges, .rangesInt

			#I don't think there are other scenarios, but in case there are
			else
				.rangelabel$ = "--undefined--"
			endif
		endif

		extractedPseudoInfo$ = soundName$ + tab$ +
			... "Pseudo" + tab$ + 
			... .thePseudo$ + tab$ + 
			... string$(.theTime) + tab$ + 
			... .thePseudoWord$ + tab$ + 
			... .thePseudoPhone$ + tab$ + 
			... string$(slopeCalc.minf0) + tab$ + 
			... string$(slopeCalc.maxf0) + tab$ + 
			... string$(slopeCalc.slopeRise) + tab$ + 
			... string$(slopeCalc.mintime) + tab$ + 
			... string$(slopeCalc.maxtime) + tab$ + 
			... string$(slopeCalc.slopeRun) + tab$ + 
			... string$(slopeCalc.slope) + tab$ +
			... .rangelabel$

		@writeThisInfo: extractedPseudoInfo$

endproc





# --------------------
# 
#	Procedure slopeCalc
#	(Find the Points tier labels that map onto a Pseudo label)
# 
# --------------------
procedure slopeCalc: .mini, .maxi
	selectObject: theTg
	if .mini <> undefined
		.mintime = Get time of point: tierPoints, .mini
		.minLabel$ = Get label of point: tierPoints, .mini
		.maxtime = Get time of point: tierPoints, .maxi
		.maxLabel$ = Get label of point: tierPoints, .maxi
		@getF0Here: .mintime, .minLabel$, thePitch
		.minf0 = getF0Here.thisF0
		@getF0Here: .maxtime, .maxLabel$, thePitch
		.maxf0 = getF0Here.thisF0
		.slopeRise = (.maxf0 - .minf0)
		.slopeRun = (.maxtime - .mintime)
		.slope = .slopeRise / .slopeRun
	else
		.slope = undefined
	endif
endproc


# --------------------
# 
#	Procedure findPseudoPoints
#	(Find the Points tier labels that map onto a Pseudo label)
# 
# --------------------
procedure findPseudoPoints: .label$, .levels#, .numL, .numS, .numT, .starTime
	selectObject: theTg
	.index# = zero# (size(.levels#))
	c = 1
	.int = Get interval at time: tierPhones, .starTime
	.phoneLow = Get start time of interval: tierPhones, .int
	.phoneHigh = Get end time of interval: tierPhones, .int
	.pointsNumMax = Get number of points: tierPoints

	if .numS > 0
		.temp = .numS
		#@warningMsg: "temp for numS: " + string$(.temp)
		#@warningMsg: "Get high index from time:" + string$(.phoneLow) + " on tier " + string$(tierPoints)
		.s = Get high index from time: tierPoints, .phoneLow
		.sTime = Get time of point: tierPoints, .s
		#@warningMsg: "It's " + string$(.sTime)
		while .sTime <= .phoneHigh & .s < .pointsNumMax
			.sLabel$ = Get label of point: tierPoints, .s
			if index_regex(.sLabel$, "\*[@<>]") > 0
				.temp -= 1
				.index#[c] = .s
				c = c+ 1
			endif
			.s = .s + 1
			#@warningMsg: "Point number " + string$(.s)
			.sTime = Get time of point: tierPoints, .s
		endwhile
	endif

	if .numL > 0
		.temp = .numL
		#@warningMsg: "temp for numL: " + string$(.temp)
		.prev = Get low index from time: tierPoints, .phoneLow
		while .temp > 0
			.prevLabel$ = Get label of point: tierPoints, .prev
			if index(.prevLabel$, "*>") > 0
				.temp -= 1
				.index#[c] = .prev
				c = c+ 1
			endif
			.prev = .prev - 1
		endwhile
	endif

	if .numT > 0
		.temp = .numT
		#@warningMsg: "temp for numT: " + string$(.temp)
		.next = Get high index from time: tierPoints, .phoneHigh
		while .temp > 0 & .next < .pointsNumMax
			.nextLabel$ = Get label of point: tierPoints, .next
			if index(.nextLabel$, "*<") > 0
				.temp -= 1
				.index#[c] = .next
				c = c+ 1
			endif
			.next = .next + 1
		endwhile
	endif

	.index# = sort#(.index#)
	#appendInfoLine: "index is "
	#appendInfoLine: .index#
endproc



# --------------------
# 
#	Procedure findPeakValley
#	(Find the peak/valley Points for which slope will be calculated)
# 
# --------------------
procedure findPeakValley: .levels#
	.peak = 0
	.max = 0
	for x from 1 to size(.levels#)
		if .levels#[x] > .max
			.max = .levels#[x]
			.peak = x
		endif
	endfor
	.peakIndex = findPseudoPoints.index#[.peak]
	#appendInfoLine: "peak is " + string$(.peakIndex)

# valley now…

	.min = 5
	#appendInfoLine(findPseudoPoints.index#)

	#if the peak is the first in the file… no slope possible:
	if .peakIndex == 1
		.valleyIndex = undefined

	#if the peak is the first Level in the Pseudo label string, just go to whatever the previous Point is:
	elsif .peak == 1 
		#@warningMsg: "peak is first in the label string"
		.valleyIndex = .peakIndex - 1


	#the elsewhere case: there's a min in Pseudo label that comes before the peak:
	else
		for x from 1 to .peak-1
			if .levels#[.peak - x] < .min
				.min = .levels#[x]
				.valley = x
			endif
		endfor
		#@warningMsg: "valley is " + string$(.valley)
		.valleyIndex = findPseudoPoints.index#[.valley]
	endif
	#appendInfoLine: "valley is " + string$(.valleyIndex)
endproc


# --------------------
# 
#	Procedure parsePseudoStar
#	(Parse the Pseudo label to find Levels information related to *s)
# 
# --------------------
procedure parsePseudoStar: .label$
	.star$ = ""
	.leading$ = ""
	.trailing$ = ""
	@extractNumbers(.label$)
	.numNumbers = extractNumbers.numNums
	if .numNumbers == 0
		.levels# = {undefined}
		.leadingLen = 0
		.starLen = 0
		.trailingLen = 0
	else
		.starLoc = index(.label$, "*")
		.lDelim = index(.label$, "+")
		.rDelim = rindex(.label$, "+")
		#writeInfoLine: string$(.lDelim) + ":" + string$(.rDelim)+ ":" + string$(.rDelim-.lDelim)
		#appendInfoLine: pseudoLabel$# [z]
		if .rDelim-.lDelim == 0
			if .lDelim < .starLoc
				.leading$ = left$ (.label$, .lDelim-1)
				.star$ = mid$ (.label$, .lDelim+1, length(.label$)-.lDelim)
				#appendInfoLine: "Leading: " + parsePseudoStar.leading$
				#appendInfoLine: "Star: " + parsePseudoStar.star$
			endif
			if .lDelim > .starLoc
				.trailing$ = right$ (.label$, length(.label$)-.lDelim)
				.star$ = left$ (.label$, .lDelim-1)
				#appendInfoLine: "Star: " + parsePseudoStar.star$
				#appendInfoLine: "Trailing: " + parsePseudoStar.trailing$
			endif
		else
			.leading$ = left$ (.label$, .lDelim-1)
			.trailing$ = right$ (.label$, length(.label$)-.rDelim)
			midLen = length(.label$)-(length(.label$)-.rDelim + .lDelim)
			.star$ = mid$ (.label$, .lDelim+1, midLen-1)
			#appendInfoLine: "Leading: " + parsePseudoStar.leading$
			#appendInfoLine: "Star: " + parsePseudoStar.star$
			#appendInfoLine: "Trailing: " + parsePseudoStar.trailing$
		endif
		#@warningMsg:"OK"
		@extractNumbers(.label$)
		.levels# = extractNumbers.nums#
		@extractNumbers(.leading$)
		.leadingLen = size(extractNumbers.nums#)
		@extractNumbers(.star$)
		.starLen = size(extractNumbers.nums#)
		@extractNumbers(.trailing$)
		.trailingLen = size(extractNumbers.nums#)
	endif
	#appendInfoLine: "(L)" + .leading$ + "(S)" + .star$ + "(T)" + .trailing$
	#appendInfoLine: .levels#
endproc


procedure extractNumbers: .str$
	.numNums = 0
	.temp$ = .str$
	while (index_regex(.temp$, "[12345]") > 0)
		.index = index_regex(.temp$, "[12345]")
		.numNums += 1
		.temp$ = right$(.temp$, length(.temp$) - .index)
	endwhile
	.nums# = zero# (.numNums)
	.temp$ = .str$
	for x from 1 to .numNums
		.index = index_regex(.temp$, "[12345]")
		.nums# [x] = number(mid$ (.temp$, .index, 1))
		.temp$ = right$(.temp$, length(.temp$)-.index)
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
### end of PoLaR-pseudo-to-slopes-CORE
### 
################################################################