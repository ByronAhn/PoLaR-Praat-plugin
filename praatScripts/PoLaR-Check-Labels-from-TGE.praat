################################################################
###
### PoLaR-Check-Labels
### v.2023.11.09
###
###
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

# to do for future versions: run a syntax-checker that ensures PoLaR labels follow an expected syntax (and corrects common errors such as "*?" for "?*")

include PoLaR-Levels-labeller-Quick-Settings.praat

@saveSelection

# First we need to select the TextGrid and Sound objects that are open in the TextGridEditor.
# This works in a weird way: Praat loads a TextGrid and Sound in the "View & Edit" window by loading the TextGrid directly,
# but the Sound object is a copy of the original Sound object. (So the original Sound object cannot be referred to directly.)
# To get around this (in case the relevant Sound object is not currently selected), this script selects the entire Sound file
# and extracts it to the Objects window. So the TextGrid that is used by this script is the original, and the Sound object
# that is used is a copy.

editorInfo$= Editor info
tgObj = extractNumber(editorInfo$, "Editor name: ")

soundInfo$ = nocheck Sound info
if soundInfo$ == ""
	# being in here means that a LongSound has been loaded
	soundInfo$ = nocheck LongSound info
	sndLen = extractNumber(soundInfo$, "Duration: ")
	
	if soundInfo$ == ""
		# being in here means that no Sound/LongSound has been loaded
		beginPause: "ERROR"
			comment: "You can only run this command if a TextGrid and Sound object are opened together!"
		endPause: "Quit", 1, 1
		exitScript() 		
	endif
else
	# being in here means that a Sound has been loaded
	sndLen = extractNumber(soundInfo$, "End time: ")
endif

sndN$ = extractWord$ (soundInfo$, "Object name: ")
Select: 0.0, sndLen
Extract selected sound (time from 0)
sndObj = selected()
endeditor
Rename: sndN$

selectObject: tgObj, sndObj


# Now we can move onto the actual textgrid formatting:

fromTGE=1 
viewandedit=0
@polarFormattingMain

selectObject: sndObj
Remove

@returnSelection


# --------------------
# 
#	Procedure polarFormattingMain
#	(The main function)
# 
# --------------------
procedure polarFormattingMain
	@versionChecker: 6, 1, 38

	# select just the textgrid now
	selectObject: tgObj

	# run this before *each* time you try to delete a tier
	# AND after each time a tier is deleted
	@findPoLaRTiersMaximumSet: tgObj


	############################
	## dealing with Discuss (Consensus Helper labels only)
	############################
		
	# delete the Discuss tier if there is nothing in it
	if tierDiscuss > 0
		selectObject: tgObj
		n = Get number of points: tierDiscuss
		if n = 0
			@findPoLaRTiersMaximumSet: tgObj
			Remove tier: tierDiscuss
			@findPoLaRTiersMaximumSet: tgObj
		endif
	endif
	

	############################
	## dealing with Ranges and Levels
	############################
	
	# we'll be resolving Ranges and Levels, which gets especially complicated if this is coming from Consensus Helper
	# if there is a tier called "Ranges" with some numbers in it, delete "Ranges-A"/"Ranges-B"/"Levels-A"/"Levels-B" tiers that exist
	selectObject: tgObj
	numRangesWithNumbers = 0
	if tierRanges > 0
		# how many intervals contain a number on the "Ranges" tier?
		numRangesWithNumbers = Count intervals where: tierRanges, "matches (regex)", ".*\d+.*"
		# if there are any…
		if numRangesWithNumbers > 0
			# and if there is a "Ranges-A" tier…
			if tierRangesA > 0
				# remove that "Ranges-A" tier
				@findPoLaRTiersMaximumSet: tgObj
				Remove tier: tierRangesA
				@findPoLaRTiersMaximumSet: tgObj
			endif
			# and if there is a "Ranges-B" tier…
			if tierRangesB > 0
				# remove that "Ranges-B" tier
				@findPoLaRTiersMaximumSet: tgObj
				Remove tier: tierRangesB
				@findPoLaRTiersMaximumSet: tgObj
			endif

			# if there is a "Levels-A" tier…
			if tierLevelsA > 0
				# remove that "Levels-A" tier
				@findPoLaRTiersMaximumSet: tgObj
				Remove tier: tierLevelsA
				@findPoLaRTiersMaximumSet: tgObj
			endif
			# if there is a "Levels-B" tier…
			if tierLevelsB > 0
				# remove that "Levels-B" tier
				@findPoLaRTiersMaximumSet: tgObj
				Remove tier: tierLevelsB
				@findPoLaRTiersMaximumSet: tgObj
			endif

			# Now run the levels labeller
			@findPoLaRTiersMaximumSet: tgObj
			selectObject: tgObj, sndObj
			viewandedit=0
			fromTGE=1
			@levelsLabellerMain

			# and just in case, make sure jus the textgrid is selected
			selectObject: tgObj

		# if there are no labelled intervals on a "Ranges" tier…
		else
			# we'll try to resolve to a Ranges tier, if possible
			resolvedRanges$=""
			
			# if there is a "Ranges-A" tier, but not a "Ranges-B" tier…
			if tierRangesA > 0 && tierRangesB == 0
				@findPoLaRTiersMaximumSet: tgObj
				Remove tier: tierRanges
				@findPoLaRTiersMaximumSet: tgObj
				Set tier name: tierRangesA, "Ranges"
				@findPoLaRTiersMaximumSet: tgObj
				resolvedRanges$="A"
			# if there is a "Ranges-B" tier, but not a "Ranges-A" tier…
			elsif tierRangesB > 0 && tierRangesA == 0
				@findPoLaRTiersMaximumSet: tgObj
				Remove tier: tierRanges
				@findPoLaRTiersMaximumSet: tgObj
				Set tier name: tierRangesB, "Ranges"
				@findPoLaRTiersMaximumSet: tgObj
				resolvedRanges$="B"
			# if there are both "Ranges-A" and "Ranges-B" tiers…
			elsif tierRangesA > 0 && tierRangesB > 0
				# check if one of them has labels and the other doesn't
				nA = Count intervals where: tierRangesA, "matches (regex)", ".*\d+.*"
				nB = Count intervals where: tierRangesB, "matches (regex)", ".*\d+.*"
				# if Ranges-A has labels and Ranges-B doesn't…
				if nA > 0 && nB = 0
					@findPoLaRTiersMaximumSet: tgObj
					Remove tier: tierRanges
					@findPoLaRTiersMaximumSet: tgObj
					Remove tier: tierRangesB
					@findPoLaRTiersMaximumSet: tgObj
					Set tier name: tierRangesA, "Ranges"
					@findPoLaRTiersMaximumSet: tgObj
					resolvedRanges$="A"
				# if Ranges-B has labels and Ranges-A doesn't…					
				elsif nA = 0 && nB > 0
					@findPoLaRTiersMaximumSet: tgObj
					Remove tier: tierRanges
					@findPoLaRTiersMaximumSet: tgObj
					Remove tier: tierRangesA
					@findPoLaRTiersMaximumSet: tgObj
					Set tier name: tierRangesB, "Ranges"
					@findPoLaRTiersMaximumSet: tgObj
					resolvedRanges$="B"
				endif
			endif
			
			# just in case anything has changed, find the tier names again
			@findPoLaRTiersMaximumSet: tgObj
			
			# modify Levels tiers based on whether we resolved to Ranges-A or Ranges-B
			if resolvedRanges$ = "A"
				# delete any existing "Levels" tier
				if tierLevels > 0
					Remove tier: tierLevels
					@findPoLaRTiersMaximumSet: tgObj
				endif
				# delete any existing "Levels-B" tier
				if tierLevelsB > 0
					Remove tier: tierLevelsB
					@findPoLaRTiersMaximumSet: tgObj
				endif
				Set tier name: tierLevelsA, "Levels"
				@findPoLaRTiersMaximumSet: tgObj

				# Now run the levels labeller
				selectObject: tgObj, sndObj
				viewandedit=0
				fromTGE=1
				@levelsLabellerMain
			elsif resolvedRanges$ = "B"
				# delete any existing "Levels" tier
				if tierLevels > 0
					Remove tier: tierLevels
					@findPoLaRTiersMaximumSet: tgObj
				endif
				# delete any existing "Levels-A" tier
				if tierLevelsA > 0
					Remove tier: tierLevelsA
					@findPoLaRTiersMaximumSet: tgObj
				endif
				Set tier name: tierLevelsB, "Levels"
				@findPoLaRTiersMaximumSet: tgObj

				# Now run the levels labeller
				selectObject: tgObj, sndObj
				viewandedit=0
				fromTGE=1
				@levelsLabellerMain
			endif
		endif

	# if there is no "Ranges" tier…
	else 
		# …but there is a Ranges-A (and no Ranges-B)…
		if tierRangesA > 0 && tierRangesB == 0
			Set tier name: tierRangesA, "Ranges"
			@findPoLaRTiersMaximumSet: tgObj
			# delete any existing "Levels" tier
			if tierLevels > 0
				Remove tier: tierLevels
				@findPoLaRTiersMaximumSet: tgObj
			endif
			# delete any existing "Levels-B" tier
			if tierLevelsB > 0
				Remove tier: tierLevelsB
				@findPoLaRTiersMaximumSet: tgObj
			endif
			Set tier name: tierLevelsA, "Levels"
			@findPoLaRTiersMaximumSet: tgObj

			# Now run the levels labeller
			selectObject: tgObj, sndObj
			viewandedit=0
			fromTGE=1
			@levelsLabellerMain

		# …but there is a Ranges-B (and no Ranges-A)…
		elsif tierRangesB > 0 && tierRangesA == 0
			Set tier name: tierRangesB, "Ranges"
			@findPoLaRTiersMaximumSet: tgObj
			# delete any existing "Levels" tier
			if tierLevels > 0
				Remove tier: tierLevels
				@findPoLaRTiersMaximumSet: tgObj
			endif
			# delete any existing "Levels-A" tier
			if tierLevelsA > 0
				Remove tier: tierLevelsA
				@findPoLaRTiersMaximumSet: tgObj
			endif
			Set tier name: tierLevelsB, "Levels"
			@findPoLaRTiersMaximumSet: tgObj

			# Now run the levels labeller
			selectObject: tgObj, sndObj
			viewandedit=0
			fromTGE=1
			@levelsLabellerMain
		endif
	endif
	
	# now that Ranges/Levels have been resolved as much as possible, check to see if there is a Ranges tier and a Levels tier with labels
	if tierRanges > 0 && tierLevels > 0
		selectObject: tgObj
		numLevels = Get number of points: tierLevels
		numRangesWithNumbers = Count intervals where: tierRanges, "matches (regex)", ".*\d+.*"
		# if there are there are labels on both tiers…
		if numRangesWithNumbers > 0 && numLevels > 0
			# check if there are 1s and 5s in each Ranges tier label
			# if there is a tier without a 1 or a 5, warn the user
			@checkRangesTiers: tgObj
		endif
	endif
	


	############################
	## dealing with Words
	############################

	# this should only come up if we're using this after the Consensus Helper has been used
	# if there is only one of the following "Words-A"/"Words-B", rename it to "Words"
	selectObject: tgObj
	if tierWordsA > 0 && tierWordsB == 0
		Set tier name: tierWordsA, "Words"
		@findPoLaRTiersMaximumSet: tgObj
	elsif tierWordsB > 0 && tierWordsA == 0
		Set tier name: tierWordsB, "Words"
		@findPoLaRTiersMaximumSet: tgObj
	endif


	############################
	## dealing with Phones
	############################

	# this should only come up if we're using this after the Consensus Helper has been used
	# if there is only one of the following "Phones-A"/"Phones-B", rename it to "Phones"
	selectObject: tgObj
	if tierPhonesA > 0 && tierPhonesB == 0
		Set tier name: tierPhonesA, "Phones"
		@findPoLaRTiersMaximumSet: tgObj
	elsif tierPhonesB > 0 && tierPhonesA == 0
		Set tier name: tierPhonesB, "Phones"
		@findPoLaRTiersMaximumSet: tgObj
	endif


	############################
	## dealing with PrStr
	############################

	# this should only come up if we're using this after the Consensus Helper has been used
	# cycle through all the PrStr points and delete all the "A:" or "B:"s
	selectObject: tgObj
	numPrStr = Get number of points: tierPrstr
	for x from 1 to numPrStr
		label$ = Get label of point: tierPrstr, x
		label$ = replace$ (label$, "A:", "", 0)
		label$ = replace$ (label$, "B:", "", 0)
		Set point text: tierPrstr, x, label$
	endfor


	############################
	## dealing with Points
	############################

	# this should only come up if we're using this after the Consensus Helper has been used
	# cycle through all the Points points and delete all the "A:" or "B:"s
	selectObject: tgObj
	numPoints = Get number of points: tierPoints
	for x from 1 to numPoints
		label$ = Get label of point: tierPoints, x
		label$ = replace$ (label$, "A:", "", 0)
		label$ = replace$ (label$, "B:", "", 0)
		Set point text: tierPoints, x, label$
	endfor
	
	############################
	## Rearrange core tiers so they are in an order of:
	## Words < Phones < PrStr < Points < Levels < Ranges < misc
	############################
	@findPoLaRTiersMaximumSet: tgObj
	# first ensure that there are tiers for all tiers that are being sorted
	# if not, create blank ones
	if tierWords = 0
		Insert interval tier: 1, "Words"
	endif
	if tierPhones = 0
		Insert interval tier: 1, "Phones"
	endif
	if tierPrstr = 0
		Insert point tier: 1, "PrStr"
	endif
	if tierPoints = 0
		Insert point tier: 1, "Points"
	endif
	if tierLevels = 0
		Insert point tier: 1, "Levels"
	endif
	if tierRanges = 0
		Insert interval tier: 1, "Ranges"
	endif
	if tierMisc = 0
		Insert point tier: 1, "Misc"
	endif
	@findPoLaRTiersMaximumSet: tgObj
	
	while ((tierWords > tierPhones) || (tierPhones > tierPrstr) || (tierPhones > tierPrstr) || (tierPrstr > tierPoints) || (tierPoints > tierLevels) || (tierLevels > tierRanges) || (tierRanges > tierMisc))
		if tierWords > tierPhones || tierPrstr > tierPoints || tierPrstr > tierLevels || tierPrstr > tierRanges || tierPrstr > tierMisc
			new = tierPhones
			old = tierWords + 1
			Duplicate tier: tierWords, new, "Words"
			Remove tier: old
			@findPoLaRTiersMaximumSet: tgObj
		endif
		if tierPhones > tierPrstr || tierPrstr > tierPoints || tierPrstr > tierLevels || tierPrstr > tierRanges || tierPrstr > tierMisc
			new = tierPrstr
			old = tierPhones + 1
			Duplicate tier: tierPhones, new, "Phones"
			Remove tier: old
			@findPoLaRTiersMaximumSet: tgObj
		endif
		if tierPrstr > tierPoints || tierPrstr > tierLevels || tierPrstr > tierRanges || tierPrstr > tierMisc
			new = tierPoints
			old = tierPrstr + 1
			Duplicate tier: tierPrstr, new, "PrStr"
			Remove tier: old
			@findPoLaRTiersMaximumSet: tgObj
		endif
		if tierPrstr > tierPoints || tierPrstr > tierLevels || tierPrstr > tierRanges || tierPrstr > tierMisc
			new = tierPoints
			old = tierPrstr + 1
			Duplicate tier: tierPrstr, new, "PrStr"
			Remove tier: old
			@findPoLaRTiersMaximumSet: tgObj
		endif
		if tierPoints > tierLevels || tierPoints > tierRanges || tierPoints > tierMisc
			new = tierLevels
			old = tierPoints + 1
			Duplicate tier: tierPoints, new, "Points"
			Remove tier: old
			@findPoLaRTiersMaximumSet: tgObj
		endif
		if tierLevels > tierRanges || tierLevels > tierMisc
			new = tierRanges
			old = tierLevels + 1
			Duplicate tier: tierLevels, new, "Levels"
			Remove tier: old
			@findPoLaRTiersMaximumSet: tgObj
		endif
		if tierRanges > tierMisc
			new = tierMisc
			old = tierRanges + 1
			Duplicate tier: tierRanges, new, "Ranges"
			Remove tier: old
			@findPoLaRTiersMaximumSet: tgObj
		endif
	endwhile
endproc


# procedure for finding all PoLaR tiers that are expectable in a PoLaR-labelled file, including tiers that only show up after using the Consensus Helper
procedure checkRangesTiers: .theTg
	selectObject: .theTg
	@findPoLaRTiersMaximumSet: .theTg
	nInt = Get number of intervals: tierRanges
	for x to nInt
		rangeLab$ = Get label of interval: tierRanges, x
		if index_regex(rangeLab$ , ".*\d.*") > 0
			start = Get start time of interval: tierRanges, x
			end = Get end time of interval: tierRanges, x
			firstLevel = Get high index from time: tierLevels, start
			lastLevel =  Get low index from time: tierLevels, end
			has1 = 0
			has5 = 0
			for l from firstLevel to lastLevel
				lab$ = Get label of point: tierLevels, l
				if lab$ == "1"
					has1 = 1
				endif
				if lab$ = "5"
					has5 = 1
				endif
			endfor
			if has1 == 0
				@logging: ">>> WARNING <<<"
				@logging: tab$ + "There are no Levels labelled ‘1’ within the Ranges interval " + string$(x) + " (labelled ‘" + rangeLab$ + "’)"
				@logging: tab$ + "Make sure this is consistent with your intentions."
			endif
			if has5 == 0
				@logging: ">>> WARNING <<<"
				@logging: tab$ + "There are no Levels labelled ‘5’ within the Ranges interval " + string$(x) + " (labelled ‘" + rangeLab$ + "’)"
				@logging: tab$ + "Make sure this is consistent with your intentions."
			endif
		endif
	endfor
endproc


# procedure for finding all PoLaR tiers that are expectable in a PoLaR-labelled file, including tiers that only show up after using the Consensus Helper
procedure findPoLaRTiersMaximumSet: .theTg
	selectObject: .theTg
	nTiers = Get number of tiers
	tierWords = 0
	tierWordsA = 0
	tierWordsB = 0
	tierPhones = 0
	tierPhonesA = 0
	tierPhonesB = 0
	tierPrstr = 0
	tierPoints = 0 
	tierLevels = 0
	tierRanges = 0
	tierLevelsA = 0 
	tierLevelsB = 0 
	tierRangesA = 0
	tierRangesB = 0
	tierMisc = 0
	tierDeleted = 0
	tierDiscuss = 0
	#Words Phones PrStr Points Levels Ranges misc DELETED DISCUSS
	for x to nTiers
		thisTierName$ = Get tier name: x
		# First, transform to lower case to avoid issues there
		lowercaseTierName$ = replace_regex$ (thisTierName$, "[A-Z]", "\L&", 0) 
		if lowercaseTierName$ == "words"
			tierWords = x
		elsif lowercaseTierName$ == "words-a"
			tierWordsA = x
		elsif lowercaseTierName$ == "words-b"
			tierWordsB = x
		elsif lowercaseTierName$ == "phones"
			tierPhones = x
		elsif lowercaseTierName$ == "phones-a"
			tierPhonesA = x
		elsif lowercaseTierName$ == "phones-b"
			tierPhonesB = x
		elsif lowercaseTierName$ == "prstr"
			tierPrstr = x
		elsif lowercaseTierName$ == "points"
			tierPoints = x
		elsif lowercaseTierName$ == "levels"
			tierLevels = x
		elsif lowercaseTierName$ == "levels-a"
			tierLevelsA = x
		elsif lowercaseTierName$ == "levels-b"
			tierLevelsB = x
		elsif lowercaseTierName$ == "ranges"
			tierRanges = x
		elsif lowercaseTierName$ == "ranges-a"
			tierRangesA = x
		elsif lowercaseTierName$ == "ranges-b"
			tierRangesB = x
		elsif lowercaseTierName$ == "discuss"
			tierDiscuss = x
		elsif lowercaseTierName$ == "misc"
			tierMisc = x
		endif
	endfor
endproc

include PoLaR-praat-procedures.praat
include PoLaR-Levels-labeller-CORE.praat

################################################################
###  
### end of PoLaR-Check-Labels
### 
################################################################

