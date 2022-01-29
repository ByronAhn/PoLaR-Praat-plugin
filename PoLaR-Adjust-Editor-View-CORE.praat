################################################################
###
### PoLaR-Adjust-Editor-View-CORE
### v.2022.01.28
###
###
### This script adjusts the editor view in order to optimize 
### the viewer for editing
### 
### Instructions:
###  - From within an editor window, open the "Tier" menu
###  - Select "PoLaR: Automatic Editor View Settings"
###
###
###	Byron Ahn (bta@princeton.edu)
###	Attribution-ShareAlike 2.5 license
###
################################################################

procedure mainAdjust:
################################################################
# Get the object number for the TextGrid in the Objects list
################################################################
editorInfo$= Editor info
tgObj = extractNumber(editorInfo$, "Editor name: ")

################################################################
# Switch commands back to the Objects window
################################################################
endeditor

################################################################
# Find out information about the TextGrid
################################################################
selectObject: tgObj
nTiers = Get number of tiers
tierRanges = 0
for x to nTiers
	thisTierName$ = Get tier name: x
	# First, transform to lower case to avoid issues there
	lowercaseTierName$ = replace_regex$ (thisTierName$, "[A-Z]", "\L&", 0) 
	if index_regex (lowercaseTierName$, "range") > 0
		tierRanges = x
	endif
endfor


################################################################
# If there is a Ranges tier, use that to determine the right 
# view settings
################################################################
foundFromRanges = 0
if tierRanges > 0
	@findRangesMinMax: tgObj
	f0MinAnalysis = findRangesMinMax.rangesMin
	f0MaxAnalysis = findRangesMinMax.rangesMax

	################################################################
	# Switch commands back to the Editor window
	################################################################
	editor

	################################################################
	# If the Ranges tier didn't help, set min/max based from the
	# Editor window
	################################################################
	if foundFromRanges = 0
		Pitch settings: 55, 650, "Hertz", "autocorrelation", "speckles"
		endTime = extractNumber(editorInfo$, "Editor end: ")
		Select... 0 endTime
		f0MinAnalysis = Get minimum pitch
		f0MaxAnalysis = Get maximum pitch
	endif

################################################################
# If there is no Ranges tier, set min/max based from the Editor
# window
################################################################
else
	################################################################
	# Switch commands back to the Editor window
	################################################################
	editor

	Pitch settings: 55, 650, "Hertz", "autocorrelation", "speckles"
	endTime = extractNumber(editorInfo$, "Editor end: ")
	Select... 0 endTime
	f0MinAnalysis = Get minimum pitch
	f0MaxAnalysis = Get maximum pitch
endif

################################################################
# Give some margins to the min/max
################################################################
if f0MinAnalysis <> 55
	temp = f0MinAnalysis / 25
	@roundTo(temp, 0)
	temp = roundTo.result * 25 - 50
	if temp < 75
		f0MinAnalysis = 65
	else
		f0MinAnalysis = temp
	endif
endif
if f0MaxAnalysis <> 700
	temp = f0MaxAnalysis / 25
	@roundTo(temp, 0)
	temp = roundTo.result * 25 + 50
	f0MaxAnalysis = temp
endif

################################################################
# Set the view settings
################################################################
Pitch settings: f0MinAnalysis, f0MaxAnalysis, "Hertz", "autocorrelation", "speckles"
Advanced pitch settings: 0.0, 0.0, very_accurate, number_of_candidates, silence_threshold, voicing_threshold, octave_cost, octave_jump_cost, voice_unvoiced_cost
Time step settings: "fixed", time_step, 100
Spectrogram settings: 0.0, 7000.0, 0.005, 40.0

# debugging:
# writeInfoLine: f0MinAnalysis, newline$, f0MaxAnalysis, newline$, time_step, newline$, number_of_candidates, newline$, very_accurate, newline$, silence_threshold, newline$, voicing_threshold, newline$, octave_cost, newline$, octave_jump_cost, newline$, voice_unvoiced_cost
endproc


# --------------------
# 
#	Procedure findRangesMinMax
#	(Used to extract F0 min/max information encoded in the Ranges tier, if it exists)
# 
# --------------------
procedure findRangesMinMax: .theTg
	.rangesMin = 55
	.rangesMax = 700
	if tierRanges >0
		.rangesMin = 10000
		.rangesMax = 0
		foundFromRanges = 1
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
			if parseRanges.localMin < .rangesMin
				.rangesMin = parseRanges.localMin
			endif
			if parseRanges.localMax > .rangesMax
				.rangesMax = parseRanges.localMax
			endif
		endfor

		#if there are no (validly) labelled Ranges intervals…
		# just use some decently wide pitch settings
		if .numLabeledRanges = 0
			foundFromRanges = 0
		endif
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
	# Check if there are parentheses labels. If so, extract the number that comes after the open-parens.
	# If not, extract the number from the left-side of the dash.
	llParen = index_regex (.leftOfSep$, "\(")
	if llParen > 0
		.localMin = extractNumber(.leftOfSep$, "(")
	else
		.localMin = extractNumber(.leftOfSep$, "")
	endif

	# For the right side of the dash (i.e., the max):
	# Check if there are parentheses labels. If so, extract the number that comes after the open-parens.
	# If not, extract the number from the right-side of the dash.
	.rlParen = index_regex (.rightOfSep$, "\(")
	if .rlParen > 0
		.localMax = extractNumber(.rightOfSep$, "(")
	else
		.localMax = extractNumber(.rightOfSep$, "")
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

################################################################
###  
### end of PoLaR-Adjust-Editor-View-CORE
### 
################################################################