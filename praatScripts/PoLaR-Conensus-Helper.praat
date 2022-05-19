################################################################
###
### PoLaR-Conensus-Helper
### v.2022.05.06
###
###
### This script allows you to automate some portion of the consensus process. It is built on the algorithm described
### in this PoLaR-Conensus-Helper.html, which is provided alongside this script.
### 
### Notes:
###  - Select the Sound object and two TextGrid objects that you're reaching consensus on.
###  - Your TextGrid(s) must have PoLaR tiers named appropriately, and have labels
###      * i.e., "PrStr", "Points", "Levels", and "Ranges"
###      * even better if you have a "Words" tier!
###  - If any tiers / labels are missing, the script may not run
###
###
###         > > >  NOTE  < < <
###  If you are having troubles, make sure your PoLaR tiers are labelled and are named appropriately
###
###
###
###	Byron Ahn (bta@princeton.edu)
###	Attribution-ShareAlike 2.5 license
###
################################################################

include PoLaR-Levels-labeller-Quick-Settings.praat

@consensusMain

# --------------------
# 
#	Procedure consensusMain
#	(The main function)
# 
# --------------------
procedure consensusMain
	# @versionChecker: 6, 1, 38

	numLogs=0

	# Ensure that exactly at least two TextGrid object are selected, possibly one Sound
	if numberOfSelected ("TextGrid") <> 2
		exitScript: "Select exactly two TextGrid files (and one sound file)"
	elsif numberOfSelected ("Sound") <> 1
		exitScript: "Select one Sound file"
	else
		origSoundName$ = selected$ ("Sound", 1)
		origSound = selected ("Sound", 1)
		tgNameA$ = selected$ ("TextGrid", 1)
		tgNameB$ = selected$ ("TextGrid", 2)
		tgA = selected ("TextGrid", 1)
		tgB = selected ("TextGrid", 2)
	endif
	@saveSelection
	
	selectObject: tgA
	@findPoLaRTiers: tgA
	tgAwords = tierWords
	tgAphones = tierPhones
	tgAprstr = tierPrStr 
	tgApoints = tierPoints 
	tgAlevels = tierLevels 
	tgAstlevels = tierSTLevels
	tgAranges = tierRanges
	tgAmisc = tierMisc
	tgApseudo = tierPseudo

	selectObject: tgB
	@findPoLaRTiers: tgB
	tgBwords = tierWords
	tgBphones = tierPhones
	tgBprstr = tierPrStr 
	tgBpoints = tierPoints 
	tgBlevels = tierLevels 
	tgBstlevels = tierSTLevels
	tgBranges = tierRanges
	tgBmisc = tierMisc
	tgBpseudo = tierPseudo

	selectObject: tgA
	tgstart = Get start time
	tgend = Get end time
	tgC = Create TextGrid: tgstart, tgend, "Words Phones PrStr Points Levels Ranges misc DELETED DISCUSS", "PrStr Points Levels misc DELETED DISCUSS"
	tgNameC$ = origSoundName$ + "-consensus"
	Rename: tgNameC$
	tgCwords = 1
	tgCwordsB = 0
	tgCphones = 2
	tgCphonesB = 0
	tgCprstr = 3 
	tgCpoints = 4 
	tgClevels = 5
	tgCranges = 6
	tgClevelsA = 0 
	tgClevelsB = 0 
	tgCrangesA = 0
	tgCrangesB = 0
	tgCmisc = 7
	tgCdeleted = 8
	tgCdiscuss = 9

	@consensusWords
	@consensusPhones
	@consensusPrStr
	@consensusPoints
	@consensusRanges
	@combineMiscTiers
	@cleanUpDiscuss
	
	selectObject: tgC
	Remove tier: tgCdeleted

	selectObject: origSound, tgC
	View & Edit
	
	@returnSelection
endproc

# --------------------
# 
#	Procedure consensusWords
#	(make sure the Words tier has consensus labels)
# 
# --------------------
procedure consensusWords
	.areThereDiffs = 0
	selectObject: tgA
	numWdsA = Get number of intervals: tgAwords
	wordsA$ = ""

	# cycle through all the words intervals in textgrid A and add them to textgrid C
	# also check if there are word boundaries in textgrid A that aren't in textgrid B
	for x from 1 to numWdsA-1
		selectObject: tgA
		wordEnd = Get end time of interval: tgAwords, x
		word$ = Get label of interval: tgAwords, x
		wordsA$ = wordsA$ + word$

		selectObject: tgB
		checkInterval = Get interval boundary from time: tgBwords, wordEnd
		if checkInterval < 1
			.areThereDiffs = 1
			selectObject: tgC	
			@addToTier: tgCdiscuss, wordEnd, "check word boundary"
		endif
		selectObject: tgC	
		Insert boundary: tgCwords, wordEnd
		Set interval text: tgCwords, x, word$
	endfor

	# cycle through all the words intervals in textgrid B
	# also check if there are word boundaries in textgrid B that aren't in textgrid A
	selectObject: tgB
	numWdsB = Get number of intervals: tgBwords
	wordsB$ = ""
	for x from 1 to numWdsB-1
		selectObject: tgB
		wordEnd = Get end time of interval: tgBwords, x
		word$ = Get label of interval: tgBwords, x
		wordsB$ = wordsB$ + word$
		selectObject: tgC	
		checkInterval = Get interval boundary from time: tgCwords, wordEnd
		if checkInterval < 1
			.areThereDiffs = 1
			@addToTier: tgCdiscuss, wordEnd, "check word boundary"
		endif
	endfor

	# see if the string of characters in the Words tier is different across textgrid files
	if wordsA$ <> wordsB$
		.areThereDiffs = 1
		selectObject: tgC
		tgCstart = Get start time
		@addToTier: tgCdiscuss, tgCstart, "Words: labellers have different labels for some interval(s)! compare visually."
	endif

	# if there are different boundaries or diferent characters:
	# then cycle through all the words intervals in textgrid B and add them to textgrid C
	if .areThereDiffs == 1
		tgCwords = tgCwords
		tgCwordsB = tgCwords + 1
		tgCphones = tgCphones + 1
		tgCprstr = tgCprstr + 1
		tgCpoints = tgCpoints + 1
		tgClevels = tgClevels + 1
		tgCranges = tgCranges + 1
		tgCmisc = tgCmisc + 1
		tgCdeleted = tgCdeleted + 1
		tgCdiscuss = tgCdiscuss + 1
		selectObject: tgC
		Set tier name: tgCwords, "Words-A"
		Insert interval tier: tgCwordsB, "Words-B"

		for x from 1 to numWdsB
			selectObject: tgB
			wordEnd = Get end time of interval: tgBwords, x
			word$ = Get label of interval: tgBwords, x

			selectObject: tgC
			if x < numWdsB
				# this if-statement is necessary because if there are x words, there are x-1 boundaries
				Insert boundary: tgCwordsB, wordEnd
			endif
			Set interval text: tgCwordsB, x, word$
		endfor
	endif

endproc



# --------------------
# 
#	Procedure consensusPhones
#	(make sure the Phones tier has consensus labels)
# 
# --------------------
procedure consensusPhones
	.areThereDiffs = 0
	selectObject: tgA
	numPhnA = Get number of intervals: tgAphones
	phonesA$ = ""
	for x from 1 to numPhnA-1
		selectObject: tgA
		phoneEnd = Get end time of interval: tgAphones, x
		phone$ = Get label of interval: tgAphones, x
		phonesA$ = phonesA$ + phone$

		selectObject: tgB
		checkInterval = Get interval boundary from time: tgBphones, phoneEnd
		if checkInterval < 1
			.areThereDiffs = 1
			selectObject: tgC	
			@addToTier: tgCdiscuss, phoneEnd, "check phone boundary"
		endif
		selectObject: tgC	
		Insert boundary: tgCphones, phoneEnd
		Set interval text: tgCphones, x, phone$
	endfor

	selectObject: tgB
	numPhnB = Get number of intervals: tgBphones
	phonesB$ = ""
	for x from 1 to numPhnB-1
		selectObject: tgB
		phoneEnd = Get end time of interval: tgBphones, x
		phone$ = Get label of interval: tgBphones, x
		phonesB$ = phonesB$ + phone$
		selectObject: tgC	
		checkInterval = Get interval boundary from time: tgCphones, phoneEnd
		if checkInterval < 1
			.areThereDiffs = 1
			@addToTier: tgCdiscuss, phoneEnd, "check phone boundary"
		endif
	endfor

	if phonesA$ <> phonesB$
		.areThereDiffs = 1
		selectObject: tgC
		tgCstart = Get start time
		@addToTier: tgCdiscuss, tgCstart+0.01, "Phones: labellers have different labels for some interval(s)! compare visually."
	endif

	# if there are different boundaries or diferent characters:
	# then cycle through all the words intervals in textgrid B and add them to textgrid C
	if .areThereDiffs == 1
		tgCphonesB = tgCphones + 1
		tgCprstr = tgCprstr + 1
		tgCpoints = tgCpoints + 1
		tgClevels = tgClevels + 1
		tgCranges = tgCranges + 1
		tgCmisc = tgCmisc + 1
		tgCdeleted = tgCdeleted + 1
		tgCdiscuss = tgCdiscuss + 1
		selectObject: tgC
		Set tier name: tgCphones, "Phones-A"
		Insert interval tier: tgCphonesB, "Phones-B"

		for x from 1 to numPhnB
			selectObject: tgB
			phoneEnd = Get end time of interval: tgBphones, x
			phone$ = Get label of interval: tgBphones, x

			selectObject: tgC
			if x < numPhnB
				# this if-statement is necessary because if there are x phones, there are x-1 boundaries
				Insert boundary: tgCphonesB, phoneEnd
			endif
			Set interval text: tgCphonesB, x, phone$
		endfor
	endif

endproc



# --------------------
# 
#	Procedure consensusPrStr
#	(make sure the PrStr tier has consensus labels)
# 
# --------------------
procedure consensusPrStr
	selectObject: tgA
	numPSA = Get number of points: tgAprstr
	for x to numPSA
		selectObject: tgA
		psTimeA = Get time of point: tgAprstr, x
		psA$ = Get label of point: tgAprstr, x

		selectObject: tgB

		# check to see if this is *only* in file A, by seeing if psTimeA doesn't correspond to the time of a PrStr label in file B (psTimeB)
		@testPointExists: tgBprstr, psTimeA
		matchedPointExists = testPointExists.result
		if matchedPointExists == 0
			# being here means it's only in file A
			# so add to the consensus textgrid (tgC) a point at this time noting the difference
			selectObject: tgC	
			@addToTier: tgCdiscuss, psTimeA, "PrStr: only labeller A"
		endif
		selectObject: tgC	
		Insert point: tgCprstr, psTimeA, psA$
	endfor

	selectObject: tgB
	numPSB = Get number of points: tgBprstr
	for x from 1 to numPSB
		selectObject: tgB
		psTimeB = Get time of point: tgBprstr, x
		psB$ = Get label of point: tgBprstr, x

		# look to see if there is a PrStr label already at this time (the time of a PrStr label on tgB) in tgC
		# start by finding the nearest index already in tgC, given the time of the label on tgB
		selectObject: tgC	

		@testPointExists: tgCprstr, psTimeB
		matchedPointExists = testPointExists.result

		# if the time of that index from tgA that's already in tgC (psTimeC) is the same as the time of the PrStr label we're looking at in tgB (at time psTimeB)…
		if matchedPointExists == 1
			# then we're going to try to resolve some of this!

			# start by getting the label of the existing point
			nearestIndexC = testPointExists.nearestIndex
			psC$ = Get label of point: tgCprstr, nearestIndexC

			# now, categorize the labels of psB and psC
			@prstrType: psB$
			psBtype$ = prstrType.result$
			@prstrType: psC$
			psCtype$ = prstrType.result$

			# IF they the same type (*, ], [) and…
			if psBtype$ == psCtype$
				# …IF one of them have a ? in it while the other one doesn't, then remove the ?
				if index(psC$, "?") <> 0 && index(psB$, "?") == 0
					psC$ = replace$ (psC$, "?", "", 0)
				elsif index(psC$, "?") == 0 && index(psB$, "?") <> 0
					psB$ = replace$ (psB$, "?", "", 0)
				endif

				# …IF one of them is more complex (** vs *, *#NS vs *, etc.), go with the more complex label
				if index(psC$, psB$) > 0
					psCnew$ = psC$
				elsif index(psB$, psC$) > 0
					psCnew$ = psB$
				else
					psCnew$ = psC$ + " --vs-- " + psB$
					@addToTier: tgCdiscuss, psTimeB, "PrStr"
				endif
			else
				psCnew$ = "discuss label"
			endif

			Set point text: tgCprstr, nearestIndexC, psCnew$
		else
			Insert point: tgCprstr, psTimeB, psB$
			@addToTier: tgCdiscuss, psTimeB, "PrStr: only labeller B"
		endif
	endfor

	# cycle through all PrStr objects in textgrid C and see if there are identical PrStr labels in the same Phones label
	selectObject: tgC
	numPSC = Get number of points: tgCprstr
	psPhoneIndex = -1
	psPhoneIndexB = -1
	prevpsPhoneIndex = -1
	prevpsPhoneIndexB = -1
	prevpsC$ = "xxxxxxxx"
	.numRemoved = 0
	for x from 1 to numPSC
		.removeMe = 0
		.adjustedX = x - .numRemoved
		psTimeC = Get time of point: tgCprstr, .adjustedX
		psC$ = Get label of point: tgCprstr, .adjustedX
		psPhoneIndex = Get interval at time: tgCphones, psTimeC
		# if there is a 2nd phones tier, check that they're in the same label there too
		if tgCphonesB > 0
			psPhoneIndexB = Get interval at time: tgCphonesB, psTimeC
		endif

		# if the current PrStr label matches exactly the previous one
		if psC$ == prevpsC$
			# if the current PrStr label is in the same Phones tier phone as the last one
			if psPhoneIndex == prevpsPhoneIndex
				# if there is a 2nd phones tier, check that they're in the same label there too
				if tgCphonesB > 0
					# if the current PrStr labels is in the same Phones-B tier phone as the last one
					if psPhoneIndexB == prevpsPhoneIndexB
						# being in here should mean the PrStr Label is in the same Phones-A tier label AND the same Phones-B tier label
						.removeMe = 1
						prevpsTimeC = Get time of point: tgCprstr, .adjustedX-1
					endif
				else
					# being in here should mean the PrStr Label is in the same Phones tier label (and there's no Phones-B tier)
					.removeMe = 1
					prevpsTimeC = Get time of point: tgCprstr, .adjustedX-1
				endif
			endif
		endif
		prevpsPhoneIndex = psPhoneIndex
		prevpsPhoneIndexB = psPhoneIndexB
		prevpsC$ = psC$
		if .removeMe == 1
			.numRemoved = .numRemoved + 1
			# remove repeated PrStr label
			Remove point: tgCprstr, .adjustedX

			# add to the "deleted" tier a note that we've deleted a PrStr label that is repeated within the same Phone label
			@addToTier: tgCdeleted, psTimeC, "PrStr: label repeated w/in Phone"
			
			# remove previously added "discuss" information for the deleted point… because we've deleted that label now!
			.discussInd = Get nearest index from time: tgCdiscuss, psTimeC
			.discussLabel$ = Get label of point: tgCdiscuss, .discussInd
			if .discussLabel$ == "PrStr: only labeller A" || .discussLabel$ == "PrStr: only labeller B"
				Remove point: tgCdiscuss, .discussInd
			else
				if index(.discussLabel$, "/ PrStr: only labeller") > 0
					.discussLabel$ = replace$(.discussLabel$, " / PrStr: only labeller A", "", 0)
					.discussLabel$ = replace$(.discussLabel$, " / PrStr: only labeller B", "", 0)
				elsif index(.discussLabel$, "PrStr: only labeller A /") > 0
					.discussLabel$ = replace$(.discussLabel$, "PrStr: only labeller A / ", "", 0)
				elsif index(.discussLabel$, "PrStr: only labeller B /") > 0
					.discussLabel$ = replace$(.discussLabel$, "PrStr: only labeller B / ", "", 0)
				endif
				Set point text: tgCdiscuss, .discussInd, .discussLabel$
			endif			

			# remove previously added "discuss" information for the remaining point… because we've deleted that label now!
			.discussInd = Get nearest index from time: tgCdiscuss, prevpsTimeC
			.discussLabel$ = Get label of point: tgCdiscuss, .discussInd
			if .discussLabel$ == "PrStr: only labeller A" || .discussLabel$ == "PrStr: only labeller B"
				Remove point: tgCdiscuss, .discussInd
			else
				if index(.discussLabel$, "/ PrStr: only labeller") > 0
					.discussLabel$ = replace$(.discussLabel$, " / PrStr: only labeller A", "", 0)
					.discussLabel$ = replace$(.discussLabel$, " / PrStr: only labeller B", "", 0)
				elsif index(.discussLabel$, "PrStr: only labeller A /") > 0
					.discussLabel$ = replace$(.discussLabel$, "PrStr: only labeller A / ", "", 0)
				elsif index(.discussLabel$, "PrStr: only labeller B /") > 0
					.discussLabel$ = replace$(.discussLabel$, "PrStr: only labeller B / ", "", 0)
				endif
				Set point text: tgCdiscuss, .discussInd, .discussLabel$
			endif
		endif
	endfor

endproc



# --------------------
# 
#	Procedure consensusPoints
#	(make sure the Points tier has consensus labels)
# 
# --------------------
procedure consensusPoints
	selectObject: tgA
	tgApointsOnly = Extract one tier: tgApoints
	tableA = Down to Table: 0, 6, 1, 1
	selectObject: tgApointsOnly
	Remove

	selectObject: tgB
	tgBpointsOnly = Extract one tier: tgBpoints
	tableB = Down to Table: 0, 6, 1, 1
	selectObject: tgBpointsOnly
	Remove

	# look for Points that labeller A, including where they overlap with labeller B
	selectObject: tgA
	numPointsA = Get number of points: tgApoints
	for x to numPointsA
		numCommas = 0
		# numCommas has 4 possible values (determined by adding 1 to this value if A has a comma override and adding 2 to this value if B does):
		#	0: neither A nor B has a comma overrride
		#	1: only A has a comma override
		#	2: only B has a comma override
		#	3: both A + B have a comma override

		numAdv = 0
		# numAdv has 4 possible values (determined by adding 1 to this value if A has an advanced label and adding 2 to this value if B does):
		#	0: neither A nor B has an advanced label
		#	1: only A has an advanced label
		#	2: only B has an advanced label
		#	3: both A + B have an advanced label

		selectObject: tgA
		pointTimeA = Get time of point: tgApoints, x
		pointA$ = Get label of point: tgApoints, x
		@testCommaLabel: pointA$
		commaLabelA = testCommaLabel.commaOverride
		if commaLabelA <> -1
			# being in here means A has a comma override
			# setting this variable to be equal to 1; see description of values for numCommas at the beginning of this for-loop
			numCommas = 1
		endif
		pointAnocomma$ = testCommaLabel.beforeTheComma$
		@pointType: pointA$
		thisPointTypeA$ = pointType.result$
		if thisPointTypeA$ <> "0"
			# being in here means A has an advanced label
			# setting this variable to be equal to 1; see description of values for numAdv at the beginning of this for-loop
			numAdv = 1
		endif

		# check to see if there is a corresponding point on tgB within a short window of time
		selectObject: tgB
		@testNearbyPointExists: tableB, tgBpoints, pointTimeA

		# get a list of the number of Points on tgB that are nearby this Point (from tgA)
		numNearbyPoints = testNearbyPointExists.result

		if numNearbyPoints == 0
			# being here means there are no nearby points

			# if it is a non-"0"-type label or has a comma override
			if thisPointTypeA$ <> "0" || commaLabelA >= 0
				selectObject: tgC
				#@logging: "adding " + pointA$ + " at " + string$(pointTimeA) + " (code 1)"
				@addToTier: tgCpoints, pointTimeA, pointA$
				@addToTier: tgCdiscuss, pointTimeA, "Points: only labeller A"				
			else
				selectObject: tgC
				@addToTier: tgCdeleted, pointTimeA, "Points: from labeller A"
			endif
		else
			# being here means there's at least 1 nearby point
			for y from 1 to numNearbyPoints
				numCommasB = numCommas
				numAdvB = numAdv

				#reminder: testNearbyPointExists.nearbyPoints#[y] is a list of the index vales from **tgB** of the Points label(s) that are near this time from tgA
			
				# get the time and label of the Point from tgB's Points tier
				pointTimeB = object[tableB, testNearbyPointExists.nearbyPoints#[y], "tmin"]
				pointB$ = object$[tableB, testNearbyPointExists.nearbyPoints#[y], "text"]
				
				# run a function to check if there's a comma label in this label, and get the value from that function
				@testCommaLabel: pointB$
				commaLabelB = testCommaLabel.commaOverride
				
				if commaLabelB <> -1
					# being in here means B has a comma override
					# adding 2 to this value; see description of values for numCommas at the beginning of this for-loop
					numCommasB = numCommas + 2
				endif
				pointBnocomma$ = testCommaLabel.beforeTheComma$
				@pointType: pointB$
				thisPointTypeB$ = pointType.result$
				if thisPointTypeB$ <> "0"
					# being in here means B has an advanced label
					# adding 2 to this value; see description of values for numAdv at the beginning of this for-loop
					numAdvB = numAdv + 2
				endif
				
				#if they have the same label, add just one of them (randomly), and mark on the deleted one on the DISCUSS tier
				if pointA$ == pointB$
					selectObject: tgC
					@testPointExists: tgCpoints, pointTimeA
					#when two points are near each other, "testNearbyPointExists" will find the points twice: once looking at the first point (finding the later one as "nearby") and once looking at the second (finding the earlier one as "nearby")
					#since we don't want both added, this test will make sure that a Point hasn't been added to tgC yet
					if testPointExists.result == 0
						#@logging: "adding " + pointA$ + " at " + string$(pointTimeA) + " (code 2)"
						# to-do MAKE RANDOM:
						Insert point: tgCpoints, pointTimeA, pointA$
						@addToTier: tgCdeleted, pointTimeA, "Points: from labeller B"				
					endif
				else
					#being in here means they have the different labels…

					if numAdvB == 0
						# no advanced label by A or by B
						coreLabel$ = "0"
					elsif numAdvB == 1
						# advanced label by A, but not B
						coreLabel$ = pointAnocomma$
						timing = pointTimeA
					elsif numAdvB == 2
						# advanced label by B, but not A
						coreLabel$ = pointBnocomma$
						timing = pointTimeB
					elsif numAdvB == 3
						# advanced label both by A and by B
						@compareAdvLabels: pointAnocomma$, pointBnocomma$
						coreLabel$ = compareAdvLabels.adv$
						numAdvB = compareAdvLabels.which
					else
						@logging: "OOPS! Why is numAdv not some integer between 0 and 3 (inclusive)??"
						coreLabel$ = ""
					endif

					if numCommasB == 0
						# no comma ovverride by A or by B
						timing = (pointTimeA + pointTimeB) / 2
						comma = -1
					elsif numCommasB == 1
						# comma override by A, but not B
						timing = pointTimeA
						comma = commaLabelA
					elsif numCommasB == 2
						# comma override by B, but not A
						timing = pointTimeB
						comma = commaLabelB
					elsif numCommasB == 3
						# comma override both by A and by B
						@compareCommaLabels: commaLabelA, pointTimeA, commaLabelB, pointTimeB
						timing = compareCommaLabels.pointTime
						comma = compareCommaLabels.comma
					else
						@logging: "OOPS! Why is numCommas not some integer between 0 and 3 (inclusive)??"
						comma = -1
					endif
					

					selectObject: tgC
					
					# if there is a comma override, the numerical value will be stored in "comma" (otherwise "comma" has a value of -1)
					if comma > 0
						pointC$ = coreLabel$ + "," + string$(comma)
						if coreLabel$ <> "" && numCommasB == 3
							pointTimeC = (pointTimeA + pointTimeB) / 2
							@addToTier: tgCdiscuss, pointTimeC, "Points: averaged comma override"
						endif
					else
						pointC$ = coreLabel$
						pointTimeC = (pointTimeA + pointTimeB) / 2
						#hm… not sure why the line below was incluced. seems like a mistake. leaving it here for now.
						#to-do resolve this
						#@addToTier: tgCdiscuss, pointTimeC, "Points: decide between these comma overrride values (use ""sensitive view""!)"
					endif
					
					if coreLabel$ == ""
						# add both points
						#@logging: "adding " + pointA$ + " at " + string$(pointTimeA) + " (code 3)"
						@addToTier: tgCpoints, pointTimeA, pointA$
						#@logging: "adding " + pointB$ + " at " + string$(pointTimeB) + " (code 4)"
						@addToTier: tgCpoints, pointTimeB, pointB$
						pointTimeC = (pointTimeA + pointTimeB) / 2
						@addToTier: tgCdiscuss, pointTimeC, "Points: different advanced labels"
					else 
						# add point at time 'timing' with label 'pointC$' on 'tgCpoints' tier
						@testPointExists: tgCpoints, timing
						if testPointExists.result == 0
							#@logging: "adding " + pointC$ + " at " + string$(timing) + " (code 5)"
							Insert point: tgCpoints, timing, pointC$
							if numAdvB == 1
								# deleted note at time pointTimeB
								@addToTier: tgCdeleted, pointTimeB, pointB$
							elsif numAdvB == 2
								# deleted note at time pointTimeA
								@addToTier: tgCdeleted, pointTimeA, pointA$
							endif
						endif
					endif
				endif
			endfor
		endif
	endfor

	# now look for Points that only labeller B has
	selectObject: tgB
	numPointsB = Get number of points: tgBpoints
	for x to numPointsB
		numCommas = 0
		numAdv = 0
		selectObject: tgB
		pointTimeB = Get time of point: tgBpoints, x
		pointB$ = Get label of point: tgBpoints, x
		@testCommaLabel: pointB$
		commaLabelB = testCommaLabel.commaOverride
		pointBnocomma$ = testCommaLabel.beforeTheComma$
		@pointType: pointB$
		thisPointTypeB$ = pointType.result$

		# check to see if there is a corresponding point on tgB within a short window of time
		selectObject: tgA
		@testNearbyPointExists: tableA, tgApoints, pointTimeB

		# get a list of the number of Points on tgB that are nearby this Point (from tgA)
		numNearbyPoints = testNearbyPointExists.result

		if numNearbyPoints == 0
			# being here means there are no nearby points

			# if it is a non-"0"-type label or has a comma override
			if thisPointTypeB$ <> "0" || commaLabelB >= 0
				selectObject: tgC
				#@logging: "adding " + pointB$ + " at " + string$(pointTimeB) + " (code 6)"
				@addToTier: tgCpoints, pointTimeB, pointB$
				@addToTier: tgCdiscuss, pointTimeB, "Points: only labeller B"
			else
				selectObject: tgC
				@addToTier: tgCdeleted, pointTimeB, "Points: from labeller B"
			endif
			
		endif
	endfor

	selectObject: tableB, tableA
	Remove

endproc



# --------------------
# 
#	Procedure consensusRanges
#	(make sure the Ranges tier has consensus labels)
# 
# --------------------
procedure consensusRanges
	selectObject: tgA
	tgArangesOnly = Extract one tier: tgAranges
	tableA = Down to Table: 0, 6, 1, 1

	selectObject: tgB
	tgBrangesOnly = Extract one tier: tgBranges
	tableB = Down to Table: 0, 6, 1, 1
	
	# identify the number of labelled ranges in tgA
	# parse out the lowest range min
	# parse out the highest range max
	selectObject: tableA
	.numRangesA = Get number of rows
	.numLabeledRangesA = 0
	
	# create a vector to keep track of parens in Ranges labels
	.hasParensA# = zero#(.numRangesA)
	
	.globalAMin = 10000
	.globalAMax = 0
	.rangeLabelsA$ = ""
	for x to .numRangesA
		.intervalLabel$ = object$[tableA, x, "text"]
		.rangeLabelsA$ = .rangeLabelsA$ + .intervalLabel$
		@parseRanges: .intervalLabel$
		if parseRanges.localMin = undefined or parseRanges.localMax = undefined
			.numLabeledRangesA = .numLabeledRangesA
		else
			.numLabeledRangesA += 1
		endif
		if parseRanges.localMin < .globalAMin
			.globalAMin = parseRanges.localMin
		endif
		if parseRanges.localMax > .globalAMax
			.globalAMax = parseRanges.localMax
		endif
		
		# check to see if there are any parens in this label:
		if parseRanges.llParen > 0 || parseRanges.rlParen > 0
			.hasParensA#[x] = 1
		endif
		
	endfor
	if .numLabeledRangesA = 0
		globalArangeMin$ = "no valid min"
		globalArangeMax$ = "no valid max"
	else
		globalArangeMin$ = string$(.globalAMin)
		globalArangeMax$ = string$(.globalAMax)
	endif

	# identify the number of labelled ranges in tgB
	# parse out the lowest range min
	# parse out the highest range max
	selectObject: tableB
	.numRangesB = Get number of rows
	.numLabeledRangesB = 0
	
	# create a vector to keep track of parens in Ranges labels
	.hasParensB# = zero#(.numRangesB)
	
	.globalBMin = 10000
	.globalBMax = 0
	.rangeLabelsB$ = ""
	for x to .numRangesB
		.intervalLabel$ = object$[tableB, x, "text"]
		.rangeLabelsB$ = .rangeLabelsB$ + .intervalLabel$
		@parseRanges: .intervalLabel$
		if parseRanges.localMin = undefined or parseRanges.localMax = undefined
			.numLabeledRangesB = .numLabeledRangesB
		else
			.numLabeledRangesB += 1
		endif
		if parseRanges.localMin < .globalBMin
			.globalBMin = parseRanges.localMin
		endif
		if parseRanges.localMax > .globalBMax
			.globalBMax = parseRanges.localMax
		endif
		
		# check to see if there are any parens in this label:
		if parseRanges.llParen > 0 || parseRanges.rlParen > 0
			.hasParensB#[x] = 1
		endif
		
	endfor
	if .numLabeledRangesB = 0
		globalBrangeMin$ = "no valid min"
		globalBrangeMax$ = "no valid max"
	else
		globalBrangeMin$ = string$(.globalBMin)
		globalBrangeMax$ = string$(.globalBMax)
	endif


	# count up the number of differences between the values just measured
	.rangeDiffs = 0
	if globalArangeMin$ <> globalBrangeMin$
		.rangeDiffs = .rangeDiffs + 1
	endif
	if globalArangeMax$ <> globalBrangeMax$
		.rangeDiffs = .rangeDiffs + 1
	endif
	##this is commented out, because it's a sub-case of .rangeLabelsA$ <> .rangeLabelsB$:
	# if .numLabeledRangesA <> .numLabeledRangesB
	# 	.rangeDiffs = .rangeDiffs + 1
	# endif
	if .rangeLabelsA$ <> .rangeLabelsB$
		.rangeDiffs = .rangeDiffs + 1
	endif
	
	
	if .rangeDiffs == 1
		# if there there is only one difference, try to resolve it
		
		# start by run the levels labeller to make sure Levels are up to date:
		selectObject: tgC
		tgCpointsOnly = Extract one tier: tgCpoints
		selectObject: tgCpointsOnly, tgArangesOnly
		tempForLevelsA = Merge
		selectObject: tgCpointsOnly, tgBrangesOnly
		tempForLevelsB = Merge
		
		selectObject: tempForLevelsA, origSound
		viewandedit=0
		fromTGE=1
		@levelsLabellerMain
		selectObject: tempForLevelsB, origSound
		viewandedit=0
		fromTGE=1
		@levelsLabellerMain

		# if they have different overall min/max values determined by Ranges interval values
		if globalArangeMin$ <> globalBrangeMin$ || globalArangeMax$ <> globalBrangeMax$
			.numDiffLvls = 0
			selectObject: tempForLevelsA
			.numLvls = Get number of points: 2
			for x from 1 to .numLvls
				selectObject: tempForLevelsA
				.lvlA = Get label of point: 2, x
				selectObject: tempForLevelsB
				.lvlB = Get label of point: 2, x
				if .lvlA <> .lvlB
					.numDiffLvls = .numDiffLvls + 1
				endif
			endfor
			
			# if there are no differences in Levels labels
			if .numDiffLvls == 0
				# go with the narrower Range (i.e. the one that has a smaller max-min value)!
				
				# to do that, go through each Range interval and determining the Range interval label
				for x to .numRangesA
					.intervalLabelA$ = object$[tableA, x, "text"]
					@parseRanges: .intervalLabelA$
					minA = parseRanges.localMin
					maxA = parseRanges.localMax
					
					.intervalLabelB$ = object$[tableB, x, "text"]
					@parseRanges: .intervalLabelB$
					minB = parseRanges.localMin
					maxB = parseRanges.localMax
					.from$ = "both labellers"
					
					if maxA-minA < maxB-minB
						# A is narrower than B
						.rangeC$ = .intervalLabelA$
						.from$ = "labeller A"
					elsif maxA-minA > maxB-minB
						# B is narrower than A
						.rangeC$ = .intervalLabelB$
						.from$ = "labeller B"
					elsif maxA-minA == maxB-minB && minA > minB
						# A and B are the same size, but A has a higher min
						.rangeC$ = .intervalLabelA$
						.from$ = "labeller A"
					else
						# elsewhere
						.rangeC$ = .intervalLabelB$
						.from$ = "labeller B"
					endif

					# here's where we add the range label, as determined above
					selectObject: tgC
					if x < .numRangesA
						# this if-statement is necessary because if there are x ranges, there are x-1 boundaries
						Insert boundary: tgCranges, object[tableA, x, "tmax"]
					endif

					Set interval text: tgCranges, x, .rangeC$
					
					# keep track of this on the Discuss tier
					@addToTier: tgCdiscuss, (object[tableA, x, "tmin"]+object[tableA, x, "tmax"])/2, "Ranges: from " + .from$
				endfor
				
			# 	if Levels labels are different…
			else
				# just alert user
				selectObject: tgC
				tgCstart = Get start time
				@addToTier: tgCdiscuss, tgCstart+0.02, "Ranges: tiers are too different to automatically resolve"
			endif
		endif

		# another possibility of a single difference between Ranges: the labels themselves are different (somehow or another)
		if .rangeLabelsA$ <> .rangeLabelsB$

			# amaybe there are a different number of Ranges
			if .numLabeledRangesA == .numLabeledRangesB
				# to-do get rid of this temporary solution (where it just includes tgA ranges as "Ranges")
				selectObject: tgC
				for x from 1 to .numRangesA
					if x < .numRangesA
						# this if-statement is necessary because if there are x ranges, there are x-1 boundaries
						Insert boundary: tgCranges, object[tableA, x, "tmax"]
					endif
					Set interval text: tgCranges, x, object$[tableA, x, "text"]
				endfor	

				# to-do!
				# one possibility: each of the range labels is identical *except* for ()s
				#	use the label that is ()'d
				#	encourage discussion
				# 	guidance: are there other cues to a phrase boundary? if so, consider using the non-() version, because this might be phrase-induced pitch reset	
				# to-do!
				# another possibility: some range(s) are narrower on one tg but not the other, but global min/max are the same
				# 	if Levels labels are identical: go with the narrower Range (i.e. the one that has a smaller max-min value)
				# 	if Levels labels are different: XXXXX
				selectObject: tgC
				tgCstart = Get start time
				@addToTier: tgCdiscuss, tgCstart+0.02, "Ranges: CHECK THIS! (randomly) used labeller A's"
			else
				#	use the Ranges tier where there are more labelled Ranges
				# 	# more ranges = better… if it makes a difference on Levels associated with *s
				# 	# 	if no effect on Levels: fewer is better
				if .numLabeledRangesA > .numLabeledRangesB
					selectObject: tgC
					for x from 1 to .numRangesA
						if x < .numRangesA
							# this if-statement is necessary because if there are x ranges, there are x-1 boundaries
							Insert boundary: tgCranges, object[tableA, x, "tmax"]
						endif
						Set interval text: tgCranges, x, object$[tableA, x, "text"]
					endfor	
				elsif .numLabeledRangesA < .numLabeledRangesB
					selectObject: tgC
					for x from 1 to .numRangesB
						if x < .numRangesB
							# this if-statement is necessary because if there are x ranges, there are x-1 boundaries
							Insert boundary: tgCranges, object[tableB, x, "tmax"]
						endif
						Set interval text: tgCranges, x, object$[tableB, x, "text"]
					endfor	
				endif
				
				selectObject: tgC
				tgCstart = Get start time
				@addToTier: tgCdiscuss, tgCstart+0.02, "Ranges: used tier with more intervals; CHECK this"
			endif
		endif

		# at this point there should be 1 tier named "Ranges" that is labelled: re-run Levels labeller based on any new Ranges labels
		selectObject: tgC, origSound
		viewandedit=0
		fromTGE=1
		@levelsLabellerMain
		
		# check that all Range intervals have a 1 and 5, and if not, warn the user
		selectObject: tgC
		tgClevelsOnly = Extract one tier: tgClevels
		tgClTable = Down to Table: 0, 6, 1, 1

		selectObject: tgC
		tgCrangesOnly = Extract one tier: tgCranges
		tgCrTable = Down to Table: 0, 6, 1, 1
		.numRangesC = Get number of rows

		# looping through Ranges intervals (and then Levels labels within each interval)
		for x from 1 to .numRangesC
			.currentTmin = object[tgCrTable, x, "tmin"]
			.currentTmax = object[tgCrTable, x, "tmax"]
			selectObject: tgClTable
			.thelvlrows# = List row numbers where: "self[row, ""tmax""] > '.currentTmin' && self[row,""tmax""] <= '.currentTmax'"
			.numLvls = size(.thelvlrows#)
			.lvlone = 0
			.lvlfive = 0
			for y from 1 to .numLvls
				if object[tgClTable, .thelvlrows#[y], "text"] == 1
					.lvlone = 1
				elsif object[tgClTable, .thelvlrows#[y], "text"] == 5
					.lvlfive = 1
				endif
			endfor
			if .lvlone == 0
				selectObject: tgC
				@addToTier: tgCdiscuss, (.currentTmin+.currentTmax)/ 2, "Ranges: no ""1"" Level, consider narrowing range"
			endif
			if .lvlfive == 0
				selectObject: tgC
				@addToTier: tgCdiscuss, (.currentTmin+.currentTmax)/ 2, "Ranges: no ""5"" Level, consider narrowing range"
			endif
		endfor

		# remove objects created for this part of the script
		selectObject: tgCpointsOnly, tempForLevelsA, tempForLevelsB, tgClevelsOnly, tgCrangesOnly, tgClTable, tgCrTable
		Remove

	# now if there are 2+ differences…
	elsif .rangeDiffs >= 2
		# don't try to resove them, just put all the labels together and tell the user
		
		# the output should have a "Ranges" and "Levels" tier that's blank, alongside "Ranges-A"/"Levels-A" and "Ranges-B"/"Levels-B"

		# labeller is flagged about ranges
		selectObject: tgC
		tgCstart = Get start time
		@addToTier: tgCdiscuss, tgCstart+0.02, "Ranges: tiers are too different to automatically resolve"

	# now if there are 0 differences between the tgA and tgC in Ranges
	else
		#just copy over Ranges from tgA to tgC:
		selectObject: tgC
		for x from 1 to .numRangesA
			if x < .numRangesA
				# this if-statement is necessary because if there are x ranges, there are x-1 boundaries
				Insert boundary: tgCranges, object[tableA, x, "tmax"]
			endif
			Set interval text: tgCranges, x, object$[tableA, x, "text"]
		endfor	

		#and re-run the levels labeller:
		selectObject: tgC, origSound
		viewandedit=0
		fromTGE=1
		@levelsLabellerMain
	endif
	
	# if there are any differences, at all create "Ranges-A"/"Levels-A" and "Ranges-B"/"Levels-B" with the original labels from each labeller
	if .rangeDiffs > 0
		# make space for an additional Ranges and Levels tier
		tgClevelsA = tgCranges + 1
		tgCrangesA = tgClevelsA + 1
		tgClevelsB = tgCrangesA + 1
		tgCrangesB = tgClevelsB + 1
		tgCmisc = tgCmisc + 4
		tgCdeleted = tgCdeleted + 4
		tgCdiscuss = tgCdiscuss + 4
		selectObject: tgC
		Insert point tier: tgClevelsA, "Levels-A"
		Insert interval tier: tgCrangesA, "Ranges-A"
		Insert point tier: tgClevelsB, "Levels-B"
		Insert interval tier: tgCrangesB, "Ranges-B"

		# copy all of the levels from tgA to Levels-A
		selectObject: tgA
		.numLevelsA = Get number of points: tgAlevels
		for x from 1 to .numLevelsA
			selectObject: tgA
			timex = Get time of point: tgAlevels, x
			labelx$ = Get label of point: tgAlevels, x
			selectObject: tgC
			Insert point: tgClevelsA, timex, labelx$
		endfor
	
		# copy all of the ranges from tgA to Ranges-A
		selectObject: tgC
		for x from 1 to .numRangesA
			if x < .numRangesA
				# this if-statement is necessary because if there are x ranges, there are x-1 boundaries
				Insert boundary: tgCrangesA, object[tableA, x, "tmax"]
			endif
			Set interval text: tgCrangesA, x, object$[tableA, x, "text"]
		endfor

		# copy all of the levels from tgB to Levels-B
		selectObject: tgB
		.numLevelsB = Get number of points: tgBlevels
		for x from 1 to .numLevelsB
			selectObject: tgB
			timex = Get time of point: tgBlevels, x
			labelx$ = Get label of point: tgBlevels, x
			selectObject: tgC
			Insert point: tgClevelsB, timex, labelx$
		endfor
	
		# copy all of the ranges from tgB to Ranges-B
		selectObject: tgC
		for x from 1 to .numRangesB
			if x < .numRangesB
				# this if-statement is necessary because if there are x ranges, there are x-1 boundaries
				Insert boundary: tgCrangesB, object[tableB, x, "tmax"]
			endif
			Set interval text: tgCrangesB, x, object$[tableB, x, "text"]
		endfor
	endif


	selectObject: tgArangesOnly, tableA, tgBrangesOnly, tableB
	Remove
endproc


# --------------------
# 
#	Procedure consensusRanges
#	(make sure the Ranges tier has consensus labels)
# 
# --------------------
procedure combineMiscTiers
	selectObject: tgA
	.numMiscA = Get number of points: tgAmisc
	if .numMiscA > 0
		for x from 1 to .numMiscA
			selectObject: tgA
			timex = Get time of point: tgAmisc, x
			labelx$ = Get label of point: tgAmisc, x
			labelx$ = "A: " + labelx$
			selectObject: tgC
			@addToTier: tgCmisc, timex, labelx$
		endfor
	endif

	selectObject: tgB
	.numMiscB = Get number of points: tgBmisc
	if .numMiscB > 0
		for x from 1 to .numMiscB
			selectObject: tgB
			timex = Get time of point: tgBmisc, x
			labelx$ = Get label of point: tgBmisc, x
			labelx$ = "B: " + labelx$
			selectObject: tgC
			@addToTier: tgCmisc, timex, labelx$
		endfor
	endif
endproc


# --------------------
# 
#	Procedure pointType
#	(determine which type of Points label a label is)
# 
# --------------------
procedure pointType: label$
	zeroType = index (label$, "0")
	starType = index (label$, "*")
	phraseEndType = index (label$, "]")
	phraseStartType = index (label$, "[")
	if zeroType == 0 && starType <> 0 && phraseEndType == 0 && phraseStartType == 0
		.result$ = "*"
	elsif zeroType == 0 && starType == 0 && phraseEndType <> 0 && phraseStartType == 0
		.result$ = "]"
	elsif zeroType == 0 && starType == 0 && phraseEndType == 0 && phraseStartType <> 0
		.result$ = "["
	elsif zeroType <> 0 && starType == 0 && phraseEndType == 0 && phraseStartType == 0
		.result$ = "0"
	else
		.result$ = "??"
	endif

endproc



# --------------------
# 
#	Procedure prstrType
#	(determine which type of PrStr label a label is)
# 
# --------------------
procedure prstrType: label$
	starType = index (label$, "*")
	phraseEndType = index (label$, "]")
	phraseStartType = index (label$, "[")
	if starType <> 0 && phraseEndType == 0 && phraseStartType == 0
		.result$ = "*"
	elsif starType == 0 && phraseEndType <> 0 && phraseStartType == 0
		.result$ = "]"
	elsif starType == 0 && phraseEndType == 0 && phraseStartType <> 0
		.result$ = "["
	else
		.result$ = "??"
	endif

endproc



# --------------------
# 
#	Procedure testPointExists
#	(test to see if there is a point on a certain tier at a specific time)
#	(NOTE: the relevant textgrid object needs to already be selected when this is called)
# 
# --------------------
procedure testPointExists: .tier, .time
	.nearestIndex = Get nearest index from time: .tier, .time
	if .nearestIndex > 0
		.nearestTime = Get time of point: .tier, .nearestIndex
		if .nearestTime == .time
			.result = 1
		else
			.result = 0
		endif
	else
		.result = 0
	endif
endproc



# --------------------
# 
#	Procedure testNearbyPointExists
#	(test to see if there is a point on a certain tier around a specific time)
#	(NOTE: the relevant textgrid object needs to already be selected when this is called)
# 
# --------------------
procedure testNearbyPointExists: .table, .tier, .time
	.nearestIndex = Get nearest index from time: .tier, .time
	if .nearestIndex > 0
		.nearestTime = Get time of point: .tier, .nearestIndex
		selectObject: .table
		.nearbyPoints# = List row numbers where: ".time - 0.05 <= self[row,""tmin""] && self[row,""tmin""] <= .time + 0.05"
		.result = size(.nearbyPoints#)
		endif
	else
		.result = 0
	endif
endproc



# --------------------
# 
#	Procedure addToTier
#	(add some text to the a particular tier)
# 
# --------------------
procedure addToTier: .tier, .time, .text$
	# first check to see if a point already exists on the target tier
	@testPointExists: .tier, .time
	if testPointExists.result == 1
		.existingText$ = Get label of point: .tier, testPointExists.nearestIndex
		.newText$ = .existingText$ + " / " + .text$
		Set point text: .tier, testPointExists.nearestIndex, .newText$
	else
		Insert point: .tier, .time, .text$
	endif
endproc


# --------------------
# 
#	Procedure cleanUpDiscuss
#	(clean up the Discuss tier)
# 
# --------------------
procedure cleanUpDiscuss
	selectObject: tgC
	.numDiscuss = Get number of points: tgCdiscuss
	.numRemoved = 0
	
	for x from 1 to .numDiscuss
		.adjustedX = x-.numRemoved
		.label$ = Get label of point: tgCdiscuss, .adjustedX
		if (index(.label$, "PrStr: only labeller")>0)
			.length = length(.label$)
			.start = index(.label$, "PrStr: only labeller")-1
			.end = index(.label$, "PrStr: only labeller")+22
			.labeller$ = mid$(.label$, .start+22, 1)
			if (index(.label$, "PrStr: only labeller A /")>0) || (index(.label$, "PrStr: only labeller B /")>0)
				.end = index(.label$, "PrStr: only labeller")+25
			endif
			.ll$ = left$(.label$, .start)
			.rl$ = mid$(.label$, .end, .length-.end+1)
			.label$ = .ll$ + .rl$
			.time = Get time of point: tgCdiscuss, .adjustedX
			@prependToLabel: tgCprstr, .time, .labeller$
		endif
		if (index(.label$, "Points: only labeller")>0)
			.length = length(.label$)
			.start = index(.label$, "Points: only labeller")-1
			.end = index(.label$, "Points: only labeller")+23
			.labeller$ = mid$(.label$, .start+23, 1)
			if (index(.label$, "Points: only labeller A /")>0) ||(index(.label$, "Points: only labeller B /")>0)
				.end = index(.label$, "Points: only labeller")+26
			endif
			.ll$ = left$(.label$, .start)
			.rl$ = mid$(.label$, .end, .length-.end+1)
			.label$ = .ll$ + .rl$
			.time = Get time of point: tgCdiscuss, .adjustedX
			@prependToLabel: tgCpoints, .time, .labeller$
		endif
		if (index_regex(.label$, " / $")>0)
			.label$ = left$(.label$, index_regex(.label$, " / $")-1)
		endif
		Set point text: tgCdiscuss, .adjustedX, .label$
		if index_regex (.label$, "^\s*$") > 0
			Remove point: tgCdiscuss, .adjustedX
			.numRemoved = .numRemoved + 1
		endif
	endfor
endproc


# --------------------
# 
#	Procedure prependToLabel
#	(add some text to the a particular label)
# 
# --------------------
procedure prependToLabel: .tier, .time, .text$
	# first ensure that a point already exists on the target tier
	@testPointExists: .tier, .time
	if testPointExists.result == 1
		.existingText$ = Get label of point: .tier, testPointExists.nearestIndex
		.newText$ = .text$ + ":" + .existingText$
		Set point text: .tier, testPointExists.nearestIndex, .newText$
	endif
endproc


# --------------------
# 
#	Procedure testCommaLabel
#	(test to see if a Points tier has a comma label)
# 
# --------------------
procedure testCommaLabel: .label$
	.commaSep$ = "[,(]"

	if index_regex(.label$, .commaSep$) > 0
		# If there is a comma in the Points tier object, parse it out
		.commaPos = rindex_regex (.label$, .commaSep$)
		.afterTheComma$ = mid$(.label$, (.commaPos+1), (length(.label$)-.commaPos))
		.beforeTheComma$ = left$(.label$, .commaPos-1)

		# Parse out a number from after the comma
		.commaOverride = extractNumber (.afterTheComma$, "")

		# Check to see if the parse was successful
		if .commaOverride = undefined
			# If parse was unsuccessful…
			# …first tell the user this happened
				@logging: tab$ + ">> ALERT <<" + newline$ + tab$ + tab$ + "A Points tier label had a “comma label” that could not be parsed, at time " + string$(getF0Here.thePointTime) + newline$ + tab$ + tab$ + "The F0 was measured directly at this time, instead of using a comma override label."
			# …and then set it to -1
				.commaOverride = -1
		endif
	else
		# If there is no comma in the Points tier object, set the variables to indicate that
		.commaOverride = -1
		.afterTheComma$ = ""
		.beforeTheComma$ = .label$
		.result = 0
	endif
endproc



# --------------------
# 
#	Procedure compareAdvLabels
# 
# --------------------
procedure compareAdvLabels: .labelA$, .labelB$
	.adv$ = ""
	.which = -1
	if .labelA$ <> .labelB$
		if index(pointA$, pointB$) > 0
			.adv$ = pointA$
			.which = 1
		elsif index(pointB$, pointA$) > 0
			.adv$ = pointB$
			.which = 2
		endif
	else
		# to-do MAKE RANDOM
		.adv$ = .labelA$
		.which = 1
	endif
endproc



# --------------------
# 
#	Procedure compareCommaLabels
# 
# --------------------
procedure compareCommaLabels: .commaLabelA, .pointTimeA, .commaLabelB, .pointTimeB
	.comma = -1
	.pointTime = (.pointTimeA + .pointTimeB) / 2
 	if abs(.commaLabelA - .commaLabelB) <= 10
 		.comma = round((.commaLabelA + .commaLabelB) / 2)
 		.pointTime = (.pointTimeA + .pointTimeB) / 2
	endif
endproc




include PoLaR-praat-procedures.praat
include PoLaR-Levels-labeller-CORE.praat

################################################################
###  
### end of PoLaR-Conensus-Helper
### 
################################################################
