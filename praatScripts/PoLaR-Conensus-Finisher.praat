################################################################
###
### PoLaR-Conensus-Finisher
### v.2022.05.04
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

soundInfo$= Sound info
sndLen = extractNumber(soundInfo$, "End time: ")
if sndLen = undefined
	beginPause: "ERROR"
		comment: "You can only run this command if a TextGrid and Sound object are opened together!"
	endPause: "Quit", 1, 1
	exitScript() 
endif
sndN$ = extractWord$ (soundInfo$, "Object name: ")
Select: 0.0, sndLen
Extract selected sound (time from 0)
sndObj = selected()
endeditor
Rename: sndN$

selectObject: tgObj, sndObj


# Now we can move onto the actual labelling:

fromTGE=1 
viewandedit=0
@consensusFinisherMain

selectObject: sndObj
Remove

@returnSelection


# --------------------
# 
#	Procedure consensusMain
#	(The main function)
# 
# --------------------
procedure consensusFinisherMain
	@versionChecker: 6, 1, 38

	# to-do: make this run syntax-checker too
	# to-do: check for 1s and 5s in each Range

	# delete the DISCUSS tier
	selectObject: tgObj
	@findPoLaRConsensusTiers: tgObj
	# if tierDiscuss > 0
	# 	Remove tier: tierDiscuss
	# endif
	
	# if there is a tier called "Ranges" with some numbers in it, delete "Ranges-A"/"Ranges-B"/"Levels-A"/"Levels-B" tiers that exist
	selectObject: tgObj
	@findPoLaRConsensusTiers: tgObj
	numRangesWithNumbers = 0
	if tierRanges > 0
		numRangesWithNumbers = Count intervals where: tierRanges, "matches (regex)", "\d+"
		if numRangesWithNumbers > 0
			if tierRangesA > 0
				Remove tier: tierRangesA
				if tierLevelsA > 0
					Remove tier: tierLevelsA
				endif
			endif
			@findPoLaRConsensusTiers: tgObj
			if tierRangesB > 0
				Remove tier: tierRangesB
				if tierLevelsB > 0
					Remove tier: tierLevelsB
				endif
			endif
			@findPoLaRConsensusTiers: tgObj
			selectObject: tgObj, sndObj
			viewandedit=0
			fromTGE=1
			@levelsLabellerMain
			selectObject: tgObj
		else
			if tierRangesA > 0 && tierRangesB == 0
				Set tier name: tierRangesA, "Ranges"
				Set tier name: tierLevelsA, "Levels"
				Remove tier: tierRanges
				Remove tier: tierLevels
			elsif tierRangesB > 0 && tierRangesA == 0
				Set tier name: tierRangesB, "Ranges"
				Set tier name: tierLevelsB, "Levels"
				Remove tier: tierRanges
				Remove tier: tierLevels
			endif
		endif
	else 
		if tierRangesA > 0 && tierRangesB == 0
			Set tier name: tierRangesA, "Ranges"
		elsif tierRangesB > 0 && tierRangesA == 0
			Set tier name: tierRangesB, "Ranges"
		endif
	endif

	# if there is only one of the following "Words-A"/"Words-B", rename it to "Words"
	selectObject: tgObj
	@findPoLaRConsensusTiers: tgObj
	if tierWordsA > 0 && tierWordsB == 0
		Set tier name: tierWordsA, "Words"
	elsif tierWordsB > 0 && tierWordsA == 0
		Set tier name: tierWordsB, "Words"
	endif

	# if there is only one of the following "Phones-A"/"Phones-B", rename it to "Phones"
	selectObject: tgObj
	@findPoLaRConsensusTiers: tgObj
	if tierPhonesA > 0 && tierPhonesB == 0
		Set tier name: tierPhonesA, "Phones"
	elsif tierPhonesB > 0 && tierPhonesA == 0
		Set tier name: tierPhonesB, "Phones"
	endif

	# cycle through all the PrStr points and delete all the "A:" or "B:"s
	selectObject: tgObj
	@findPoLaRConsensusTiers: tgObj
	numPrStr = Get number of points: tierPrstr
	for x from 1 to numPrStr
		label$ = Get label of point: tierPrstr, x
		label$ = replace$ (label$, "A:", "", 0)
		label$ = replace$ (label$, "B:", "", 0)
		Set point text: tierPrstr, x, label$
	endfor

	# cycle through all the Points points and delete all the "A:" or "B:"s
	selectObject: tgObj
	@findPoLaRConsensusTiers: tgObj
	numPoints = Get number of points: tierPoints
	for x from 1 to numPoints
		label$ = Get label of point: tierPoints, x
		label$ = replace$ (label$, "A:", "", 0)
		label$ = replace$ (label$, "B:", "", 0)
		Set point text: tierPoints, x, label$
	endfor

endproc

procedure findPoLaRConsensusTiers: .theTg
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
### end of PoLaR-Conensus-Finisher
### 
################################################################

