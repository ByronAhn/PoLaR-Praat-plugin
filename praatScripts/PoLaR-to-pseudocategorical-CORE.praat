################################################################
###  
### PoLaR-to-pseudocategorical-CORE
### v.2021.11.08
### 
### 
###  >>>>> IMPORTANT NOTE
###  >>>>> This script requires PRAAT VERSION 6.1.38 OR LATER (released Jan 2021)
### 
###
### This script creates "pseudo-categorical" labels (modelled after ToBI Tones labels), from the PoLaR PrStr / Levels / (advanced) Points labels.
### 
### 
### Instructions:
###  To run from the Praat objects window, select at least one TextGrid object
###       - Choose the appropriate script: Quick or Advanced
###       - When running the Quick version, the script loads with all the (Advanced) Pitch Settings parameters that are described in the PoLaR guidelines.
###       - When running the Advanced version, you can adjust settings manually.
### 
###  For this script to work correclty, labels on the following tiers are required:
###       - PrStr
###       - Points (must be Advanced labels!)
###       - Levels
###       - Phones
### 
### Results:
### 
### After running the script, the newly edited TextGrid file will be opened
###         > > >  NOTE  < < <
###  YOU MUST SAVE THE TEXTGRID MANUALLY!
###  The script itself does not save the TextGrid object it creates
###
### 
### Troubleshooting:
###  - Make sure your TextGrid file has one tier named "Points", with PoLaR labels
###       - If you have multiple tiers named "Points", this script will reference the last one
###       - If your Points tier is named something different (e.g., "Point", "Pnts", etc.), then the script MAY NOT find it
###  - Make sure your Points tier is labelled with Advanced PoLaR labels
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
	@versionChecker: 6, 1, 38

	numLogs=0
	# Ensure that exactly one TextGrid object is selected
	if numberOfSelected () <> 1
		exitScript: "Select exactly one TextGrid file."
	else
		theTg = selected ("TextGrid", 1)
		if new_TextGrid_file_in_Object_List = 1
			tgName$ = selected$ ("TextGrid", 1)
			tgName$ = "NEW_" + tgName$
			Copy... 'tgName$'
			selectObject: "TextGrid " + tgName$
			theTg = selected("TextGrid", 1)	
		endif
	endif

	@findPoLaRTiers: theTg
	if tierPseudo > 0
		Remove tier: tierPseudo
		@findPoLaRTiers: theTg
	endif
	if tierPhones == 0
		@logging: "Please add a tier called 'Phones' that has time-aligned intervals with the segmental phonetic transcription."
		@logging: "This is necessary to create the pseudo-categorical labels, what are defined in part by how phonetic segment intervals, PrStr * and ] labels, and Points labels are timed with respect to one another."
		exitScript: "See error message in the info window / log file."
	endif
	numPhoneIntervals = Get number of intervals: tierPhones
	phoneTierEnd = Get end time of interval: tierPhones, numPhoneIntervals
	
	fileEndTime = Get end time
	numPoints = Get number of points: tierPoints
	numLevels = Get number of points: tierLevels
	numPRSTR = Get number of points: tierPrStr
	prstrLabel$# = empty$# (numPRSTR)
	prstrTime# = zero# (numPRSTR)
	prstrType$# = empty$# (numPRSTR)
	numStars = 0
	prStrStars# = zero# (numPRSTR)
	numBrackets = 0
	prStrBrackets# = zero# (numPRSTR)
	prstrPhoneSpanMin# = zero# (numPRSTR)
	prstrPhoneSpanMax# = zero# (numPRSTR)
	prstrTimeDomainMin# = zero# (numPRSTR)
	prstrTimeDomainMax# = zero# (numPRSTR)
	levelsLabel$# = empty$# (numLevels)
	levelsTime# = zero# (numLevels)
	pointsLabel$# = empty$#(numPoints)
	pseudoTobi$# = empty$#(numPRSTR)

	if numPoints <> numLevels
		beginPause: "ERROR"
			comment: "Your Points tier and Levels tier differ in number of labels"
			comment: "CHECK YOUR LABELS (and possibly re-run the Levels labeller)"
		endPause: "Quit", 1, 1
		exitScript() 
	endif

	#this for-loop collects all the Levels tier objects into one vector
	for x from 1 to numLevels
		levelsLabel$# [x] = Get label of point: tierLevels, x
		levelsTime# [x] = Get time of point: tierLevels, x
		pointsLabel$# [x] = Get label of point: tierPoints, x
	endfor


	#this for-loop collects information about all PrStr objects into various vectors
	for x from 1 to numPRSTR
		thePrStr$ = Get label of point: tierPrStr, x
		prstrLabel$# [x] = thePrStr$
		prstrTime# [x] = Get time of point: tierPrStr, x
		if index(thePrStr$, "*") > 0
			prstrType$# [x] = "*"
			numStars += 1

			# if the xth PrStr object is a *, save the value of x in the list of PrStr stars:
			prStrStars# [numStars] = x
		elsif index(thePrStr$, "]") > 0
			prstrType$# [x] = "]"
			numBrackets += 1

			# if the xth PrStr object is a ], save the value of x in the list of PrStr brackets:
			prStrBrackets# [numBrackets] = x
		else
			prstrType$# [x] = "??"
		endif

		thisTime = Get time of point: tierPrStr, x
		if thisTime > phoneTierEnd
			@logging: "Error: the time domain of your Phones tier is unexpectedly shortler than the time at which you have a PrStr label."
			@logging: "Please adjust your Phones tier so that it is appropriately long."
			exitScript: "See error message in the info window / log file."
		endif
		if thisTime = 0
			thisPhoneInt = 1
		else
			thisPhoneInt = Get low interval at time: tierPhones, thisTime
		endif
		thisPhone$ = Get label of interval: tierPhones, thisPhoneInt
		prstrPhoneSpanMin# [x] = Get start time of interval: tierPhones, thisPhoneInt
		prstrPhoneSpanMax# [x] = Get end time of interval: tierPhones, thisPhoneInt

	endfor

	#this for-loop collects goes through each PrStr object, and finds its "time domain" for the Levels/Points to be collected into its label
	#the "domain"s are specific to each object type; e.g., the domain of a * foes from the previous * to the next *, regardless of any intervening non-* PrStr objects
	xStar = 1
	xBracket = 1
	for x from 1 to numPRSTR
	
		# collect time domain minimums
		if (prstrType$# [x] = "*")
			if xStar = 1
				# the first * has a domain minimum of the beginning of the file
				timeDomainMin = 0.0
			else
				# for other *s, the domain minimum is the time at which the previous star occurs
				lastStar = prStrStars# [xStar-1]
				timeDomainMin = prstrTime# [lastStar]
			endif
		elsif (prstrType$# [x] = "]")
			if xBracket = 1
				# the first ] has a domain minimum of the beginning of the file
				timeDomainMin = 0.0
			else
				# for other ]s, the domain minimum is the time at which the previous bracket occurs
				lastBracket = prStrBrackets# [xBracket-1]
				timeDomainMin = prstrTime# [lastBracket]
			endif
		endif

		# collect time domain maximums
		if (prstrType$# [x] = "*")
			if xStar = numStars
				# the last * has a domain maximum of the end of the file
				timeDomainMax = fileEndTime
			else
				# for other *s, the domain maximum is the time at which the next star occurs
				nextStar = prStrStars# [xStar+1]
				timeDomainMax = prstrTime# [nextStar]
			endif
		elsif (prstrType$# [x] = "]")
			if xBracket = numBrackets
				# the last ] has a domain maximum of the end of the file
				timeDomainMax = fileEndTime
			else
				# for other ]s, the domain maximum is the time at which the next bracket occurs
				nextBracket = prStrBrackets# [xBracket+1]
				timeDomainMax = prstrTime# [nextBracket]
			endif
		endif

		#step the relevant counter
		if prstrType$# [x] = "*"
			xStar += 1
		elsif prstrType$# [x] = "]"
			xBracket += 1
		elsif prstrType$# [x] = "*]"
			xBracket += 1
			xStar += 1
		endif

		prstrTimeDomainMin# [x] = timeDomainMin
		prstrTimeDomainMax# [x] = timeDomainMax
	endfor

	@levelsToPseudotobi

	@newTier

	if viewandedit = 1
		View & Edit
	endif

endproc


# --------------------
# 
#	Procedure levelsToPseudotobi
#	(This builds up a pseudo-ToBI string for the */]s, based on Levels tier objects)
# 
# --------------------
procedure levelsToPseudotobi
#this for-loop goes through each PrStr and its "time domain"
for x from 1 to numPRSTR
	atLevelObj = 1
	pseudoT$ = ""
	whileTest = 1
	
	if prstrType$# [x] = "*"
		preStar$ = ""
		duringStar$ = ""
		postStar$ = ""
		
		#the following cycles through Levels objects, running a while loop for as long as the current Levels object is timed within the current *'s time domain
		while whileTest = 1
			if levelsTime# [atLevelObj] > prstrTimeDomainMin# [x]
				thePoint$ = pointsLabel$# [atLevelObj]
				if index(thePoint$, "*") > 0

					# for levels that precede the *'d phone
					if levelsTime# [atLevelObj] < prstrPhoneSpanMin# [x]
						# if the point is *>…
						if (index(thePoint$, "*>") > 0) and (levelsTime# [atLevelObj] < prstrTime# [x])
							if preStar$ <> ""
								preStar$ += ","
							endif
							preStar$ += levelsLabel$# [atLevelObj]
						
						# if the point is *@…
						elsif (index(thePoint$, "*@") > 0) and (levelsTime# [atLevelObj] = prstrTime# [x])
							if preStar$ <> ""
								preStar$ += ","
							endif
							preStar$ += levelsLabel$# [atLevelObj]

						# if the point is *<…
						elsif (index(thePoint$, "*<") > 0) and (levelsTime# [atLevelObj] > prstrTime# [x])
							if preStar$ <> ""
								preStar$ += ","
							endif
							preStar$ += levelsLabel$# [atLevelObj]

						endif

					# for levels that occur during the *'d phone
					elsif (prstrPhoneSpanMin# [x] <= levelsTime# [atLevelObj]) and (levelsTime# [atLevelObj] <= prstrPhoneSpanMax# [x])
						# if the point is *>…
						if (index(thePoint$, "*>") > 0) and (levelsTime# [atLevelObj] < prstrTime# [x])
							if duringStar$ <> ""
								duringStar$ += ","
							endif
							duringStar$ += levelsLabel$# [atLevelObj]
						
						# if the point is *@…
						elsif (index(thePoint$, "*@") > 0) and (levelsTime# [atLevelObj] = prstrTime# [x])
							if duringStar$ <> ""
								duringStar$ += ","
							endif
							duringStar$ += levelsLabel$# [atLevelObj]

						# if the point is *<…
						elsif (index(thePoint$, "*<") > 0) and (levelsTime# [atLevelObj] > prstrTime# [x])
							if duringStar$ <> ""
								duringStar$ += ","
							endif
							duringStar$ += levelsLabel$# [atLevelObj]

						endif

					# for levels that occur after the *'d phone
					elsif prstrPhoneSpanMax# [x] < levelsTime# [atLevelObj]
						# if the point is *>…
						if (index(thePoint$, "*>") > 0) and (levelsTime# [atLevelObj] < prstrTime# [x])
							if postStar$ <> ""
								postStar$ += ","
							endif
							postStar$ += levelsLabel$# [atLevelObj]
						
						# if the point is *@…
						elsif (index(thePoint$, "*@") > 0) and (levelsTime# [atLevelObj] = prstrTime# [x])
							if postStar$ <> ""
								postStar$ += ","
							endif
							postStar$ += levelsLabel$# [atLevelObj]

						# if the point is *<…
						elsif (index(thePoint$, "*<") > 0) and (levelsTime# [atLevelObj] > prstrTime# [x])
							if postStar$ <> ""
								postStar$ += ","
							endif
							postStar$ += levelsLabel$# [atLevelObj]

						endif

					endif
				endif
			endif
			atLevelObj += 1
			if atLevelObj = numLevels+1
				whileTest = 0
			elsif (levelsTime# [atLevelObj] > prstrTimeDomainMax# [x])
				whileTest = 0
			endif
		endwhile

		
		# all levels labels during the "*" marked segment are followed by a *
		if duringStar$ <> ""
			if index(duringStar$, ",") > 0
				duringStar$ = "[" + duringStar$ + "]*"
			else
				duringStar$ = duringStar$ + "*"
			endif
		else
			duringStar$ = "*"
		endif
		
		# all levels labels before the "*" marked segment are followed by a +
		if preStar$ <> ""
			if index(preStar$, ",") > 0
				preStar$ = "[" + preStar$ + "]+"
			else
				preStar$ = preStar$ + "+"
			endif
		endif
		
		# all levels labels after the "*" marked segment are preceded by a +
		if postStar$ <> ""
			if index(postStar$, ",") > 0
				postStar$ = "+[" + postStar$ + "]"
			else
				postStar$ = "+" + postStar$
			endif
		endif
		
		pseudoT$ = preStar$ + duringStar$ + postStar$
		
	elsif prstrType$# [x] = "]"
		preBracket$ = ""
		duringBracket$ = ""
		postBracket$ = ""
		pseudoT$ = "" 
		
		#the following cycles through Levels objects, running a while loop for as long as the current Levels object is timed within the current ]'s time domain
		while whileTest = 1
			if levelsTime# [atLevelObj] > prstrTimeDomainMin# [x]
				thePoint$ = pointsLabel$# [atLevelObj]
				if index(thePoint$, "]") > 0
					if levelsTime# [atLevelObj] < prstrPhoneSpanMin# [x]
						if index(thePoint$, "]>") > 0
							if preBracket$ <> ""
								preBracket$ += ","
							endif
							preBracket$ += levelsLabel$# [atLevelObj]
						endif
					elsif (prstrPhoneSpanMin# [x] <= levelsTime# [atLevelObj]) and (levelsTime# [atLevelObj] <= prstrPhoneSpanMax# [x])
						if index(thePoint$, "]") > 0
							if duringBracket$ <> ""
								duringBracket$ += ","
							endif
							duringBracket$ += levelsLabel$# [atLevelObj]
						endif
					elsif prstrPhoneSpanMax# [x] < levelsTime# [atLevelObj]
						if index(thePoint$, "]<") > 0
							if postBracket$ <> ""
								postBracket$ += ","
							endif
							postBracket$ += levelsLabel$# [atLevelObj]
						endif
					endif
				endif
			endif
			atLevelObj += 1
			if atLevelObj = numLevels+1
				whileTest = 0
			elsif (levelsTime# [atLevelObj] > prstrTimeDomainMax# [x])
				whileTest = 0
			endif
		endwhile
		
		# all levels labels before the "]" marked segment are followed by a -
		if preBracket$ <> ""
			if index(preBracket$, ",") > 0
				preBracket$ = "[" + preBracket$ + "]-"
			else
				preBracket$ = preBracket$ + "-"
			endif
		endif
		
		duringAndPostB$ = duringBracket$ + postBracket$
		if duringAndPostB$ <> ""
			if index(duringAndPostB$, ",") > 0
				duringAndPostB$ = "[" + duringAndPostB$ + "]%"
			else
				duringAndPostB$ = duringAndPostB$ + "%"
			endif
		else
			duringAndPostB$ = "%"
		endif
	
		pseudoT$ = preBracket$ + duringAndPostB$
	else
		pseudoT$ = ""
	endif
	pseudoTobi$# [x] = pseudoT$
endfor
endproc



# --------------------
# 
#	Procedure newTier
#	(Creates a tier called "Pseudo")
# 
# --------------------
procedure newTier
	Duplicate tier: tierPrStr, tierPrStr, "Pseudo"
	for x from 1 to numPRSTR
		Set point text: tierPrStr, x, pseudoTobi$# [x]
	endfor
endproc


include PoLaR-praat-procedures.praat


################################################################
###  
### end of PoLaR-pseudotobi-CORE
### 
################################################################