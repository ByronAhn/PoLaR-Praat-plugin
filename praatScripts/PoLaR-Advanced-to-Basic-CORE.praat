################################################################
###
### PoLaR-Advanced-to-Basic-CORE
### v.2021.11.08
###
###
### This script converts advanced PoLaR labels into basic PoLaR labels
### 
### Instructions:
###  - Select at least one TextGrid file in the Praat objects window
###  - Click the button on the righthand side of the objects window, titled "PoLaR Adv.-to-Basic ▾"
###  - You're done! For each original TextGrid, a new one ending in "-basics" will have appeared in the Praat objects window
###
###
###         > > >  NOTE  < < <
###
###  YOU MUST SAVE THE TEXTGRID MANUALLY!
###  The script itself does not save the TextGrid object it creates
###
###
###
###	Byron Ahn (bta@princeton.edu)
###	Attribution-ShareAlike 2.5 license
###
################################################################

numLogs=0
@logging: date$ () + newline$ + "Running script for converting Advanced PoLaR labels to Basic ones"

# Cycle through each TextGrid object that is selected
@saveSelection
for z to numberOfSelected ("TextGrid")
	tgName$ = selected$ ("TextGrid", z)
	origTg = selected ("TextGrid", z)
	selectObject: origTg

	basciTgName$ = tgName$ + "-basic"
	Copy: basciTgName$
	basicTg = selected ("TextGrid", 1)

	@findPoLaRTiers: basicTg
	if make_PrStr_Basic
		@makePrStrBasic: basicTg
	endif
	if make_Points_Basic
		@makePointsBasic: basicTg
	endif
	if make_Ranges_Basic
	@makeRangesBasic: basicTg
	endif
	@returnSelection
endfor


# --------------------
# 
#	Procedure makePrStrBasic
#	(Used to make the PrStr tier labels basic lables)
# 
# --------------------
procedure makePrStrBasic: .theTg
	numDelete = 0
	# Query TG tier 'tierPrStr' for number of intervals
	numPrStr = Get number of points: tierPrStr
	for x to numPrStr
		selectObject: .theTg
		.thePrStr$ = Get label of point: tierPrStr, x
		.basicPrStr$ = .thePrStr$
		if index (.thePrStr$, "*") > 0
			if index (.thePrStr$, "?*") > 0
				.basicPrStr$ = "?*"
			else
				.basicPrStr$ = "*"
			endif
		endif
		if index (.thePrStr$, "]") > 0
			if index (.thePrStr$, "?]") > 0
				.basicPrStr$ = "?]"
			else
				.basicPrStr$ = "]"
			endif
		endif
		if index (.thePrStr$, "[") > 0
			.basicPrStr$ = ""
			numDelete += 1
		endif
		Set point text: tierPrStr, x, .basicPrStr$
	endfor
	while numDelete > 0
	for x to numPrStr
		backwardsCount = numPrStr - x + 1
		.thePrStr$ = Get label of point: tierPrStr, backwardsCount
		if .thePrStr$ = ""
			Remove point: tierPrStr, backwardsCount
		endif
	endwhile
endproc


# --------------------
# 
#	Procedure makePointsBasic
#	(Used to make the Points tier labels basic lables)
# 
# --------------------
procedure makePointsBasic: .theTg
	# Query TG tier 'tierPoints' for number of intervals
	numPoints = Get number of points: tierPoints
	for x to numPoints
		selectObject: .theTg
		.thePoint$ = Get label of point: tierPoints, x
		.basicPoint$ = .thePoint$

		commaSep$ = "[,(]"
		commaPos = index_regex(.thePoint$, commaSep$)
		afterTheComma$ = mid$(.thePoint$, (commaPos+1), (length(.thePoint$)-commaPos))

		if commaPos > 0
			.basicPoint$ = "0," + string$(extractNumber(afterTheComma$, ""))
		else
			.basicPoint$ = "0"
		endif
		Set point text: tierPoints, x, .basicPoint$
	endfor
endproc


# --------------------
# 
#	Procedure makeRangesBasic
#	(Used to make the Ranges tier labels basic lables)
# 
# --------------------
procedure makeRangesBasic: .theTg
	# Query TG tier 'tierRanges' for number of intervals
	numRanges = Get number of intervals: tierRanges

	# This for loop takes Ranges intervals one at a time, and then
	# remove all parentheses from the Ranges intervals
	for x to numRanges
		selectObject: .theTg

		localMin = undefined
		localMax = undefined

		intervalLabel$ = Get label of interval... 'tierRanges' 'x'

		@parseRangesIgnoreParens: intervalLabel$
		localMin = parseRangesIgnoreParens.localMin
		localMax = parseRangesIgnoreParens.localMax

		# When parsing fails for a Ranges tier interval, give a warning and skip to the next interval
		if localMin = undefined or localMax = undefined
			Set interval text: tierRanges, x, ""
		else
			newRangeLabel$ = string$(localMin) + "-" + string$(localMax)
			Set interval text: tierRanges, x, newRangeLabel$
		endif	
	endfor

	# This for loop takes Ranges intervals two at a time, and then
	# compares them. If they are identical, they are merged.
	y = numRanges-1
	while y > 0
		selectObject: .theTg

		intervalLabelA$ = Get label of interval: tierRanges, y
		intervalLabelB$ = Get label of interval: tierRanges, y+1

		# When parsing fails for a Ranges tier interval, give a warning and skip to the next interval
		if intervalLabelA$ = intervalLabelB$
			Remove right boundary: tierRanges, y
			Set interval text: tierRanges, y, intervalLabelB$
		endif
		y-=1
	endwhile
endproc


include PoLaR-praat-procedures.praat


################################################################
###  
### end of PoLaR-Advanced-to-Basic
### 
################################################################