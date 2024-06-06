################################################################
###
### PoLaR-momel-labels-CORE
### v.2024.06.06
###
###
### This script uses Momel algorithms and executables to generate fully automated 
### Points and Ranges labels (with PoLaR algorithms then yielding Levels labels).
### These automated labels are very good, but often require at least a little bit of
### hand-correction to match human perception, so after the first-pass of labels is
### created, the user is shown a Manipulation window where they can audio/visually
### adjust turning points, which then feed back into the TextGrid.
### 
### 
### Notes:
###  - Any preexisting Points/Levels/Ranges labels >> WILL BE DELETED <<
###      * Only run this algorithm when you want to replace such labels
###  - Momel is created by Daniel Hirst and Robert Espesser
###      * The executables and algorithms used here derived from this Praat plugin:
###        https://www.researchgate.net/publication/342039069_plugin_momel-intsint
###      * And further information can be found in https://doi.org/10.4000/tipa.6059
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
#	Procedure momelBasedLabelsMain
#	(Used to draft PoLaR labels on the basis of the Momel algorithms)
# 
# --------------------
procedure momelBasedLabelsMain: .snd, .name$, .tg, .pt
	#@saveSelection
	numLogs=0
	#@versionChecker: 6, 1, 0

	if not variableExists("fromTGE")
		fromTGE = 0
	endif
	if not variableExists("saveToDir")
		saveToDir = 0
	endif

	# check to make sure the PoLaR-momel-labels-Settings is loaded… if not, define the variables
	# (for some reason this settings file isn't always being loaded when I call it)
	if not variableExists("pitch_step")
		momel_parameters$ = "30 60 750 1.04 20 5 0.05"
		pitch_step = 0.01
		time_step = 0.001
		sil_thresh = -25.0
		sil_label$ = "#"
		snd_label$ = "sound"

		number_of_candidates = 15
		very_accurate = 1
		silence_threshold = 0.03
		voicing_threshold = 0.5
		octave_cost = 0.05
		octave_jump_cost = 0.5
		voice_unvoiced_cost = 0.2
	endif

	# Suppress the "running script…" message, when being called from the TextGrid Editor window
	if fromTGE <> 1
		@logging: date$ () + newline$ + "Running script for generating Points, Levels, and Ranges labels, based on Momel algorithms"
	endif

	@prepTextGrid: .tg
	
	# set directory location for momel executables
	if windows
		momelDir$ = "momelFiles\"
	else
		momelDir$ = "momelFiles/"
	endif
		
	@createPitchFromSound: .snd, pitch_step
	.thePitch = createPitchFromSound.thePitch
	minf0 = createPitchFromSound.min_f0
	maxf0 = createPitchFromSound.max_f0
	selectObject: .thePitch
	.theMatrix = To Matrix
	
	# if this function was passed "0" for the pitchtier object, create one; else, use the pitchtier object passed to this function
	if (.pt=0)
		@momelCreatePitchTier: .snd, .name$
		.thePT = momelCreatePitchTier.thePT
	else
		.thePT = .pt
	endif

	@momelCalculate: .snd, .tg, .theMatrix, .thePT, minf0, maxf0
	selectObject: .thePitch, .theMatrix
	Remove

	if (manipulate = 1)
		@handEditPoints: .snd, .tg, .thePT
		.thePT = handEditPoints.thePT
	endif

	# if a new pitchtier was created and the saveToDir variable is set to 1…
	if ((saveToDir = 1) & (.pt = 0))
		selectObject: .thePT
		Save as text file: outDir$ + .name$ + ".PitchTier"
		Remove
	endif
endproc



# --------------------
# 
#	Procedure prepTextGrid
#	(Used to )
# 
# --------------------
procedure prepTextGrid: .theTg
	@findPoLaRTiers: .theTg

	numTiers = Get number of tiers

	if tierPrStr = 0
		tierPrStr=numTiers+1
		Insert point tier: tierPrStr, "PrStr"
		numTiers+=1
	endif

	if tierPoints = 0
		tierPoints=tierPrStr+1
		Insert point tier: tierPoints, "Points"
		numTiers+=1
	else
		@findPoLaRTiers: .theTg
		Remove tier: tierPoints
		Insert point tier: tierPoints, "Points"
	endif

	if tierLevels = 0
		tierLevels=tierPoints+1
		Insert point tier: tierLevels, "Levels"
		numTiers+=1
	else
		@findPoLaRTiers: .theTg
		Remove tier: tierLevels
		Insert point tier: tierLevels, "Levels"
	endif

	if tierRanges = 0
		tierRanges=tierLevels+1
		Insert interval tier: tierRanges, "Ranges"
		numTiers+=1
	else
		@findPoLaRTiers: .theTg
		Remove tier: tierRanges
		Insert interval tier: tierRanges, "Ranges"
	endif

	if tierMisc = 0
		tierMisc=tierRanges+1
		Insert point tier: tierMisc, "misc"
		numTiers+=1
	endif
	
	@findPoLaRTiers: .theTg

endproc



# --------------------
# 
#	Procedure momelCreatePitchTier 
#	(Used to create an empty PitchTier object)
# 
# --------------------
procedure momelCreatePitchTier: .theSnd, .baseName$
	selectObject: .theSnd	
	.duration = Get total duration
	.thePT = Create PitchTier: .baseName$, 0, .duration
endproc




# --------------------
# 
#	Procedure momelCalculate 
#	(Used to create Matrix and PitchTier objects and do Momel calculations and save results to a PitchTier and TextGrid)
# 
# --------------------
procedure momelCalculate: .theSnd, .theTg, .theMatrix, .thePT, .min_f0, .max_f0
	selectObject: .theMatrix	
	nColumns = Get number of columns

	selectObject: .theSnd	
	.duration = Get total duration

	# calculate location of sound / silence
	selectObject: .theSnd
	.silTg = To TextGrid (silences): 70, pitch_step, sil_thresh, 0.25, 0.05, sil_label$, snd_label$
	nIntervals = Get number of intervals: 1

	# find all the sound intervals
	# the interval indices of each "sound"-lablled interval is in 'sndIntervals[]' (which has 'nSoundIntervals'-many elements)
	# the time starts/ends of those intervals are in starts[]/ends[]
	# the matrix fram starts/ends of those intervals are in intStarts[]/intEnds[]
	nSoundIntervals = 0
	for iInterval from 1 to nIntervals
		select .silTg
		label$ = Get label of interval: 1, iInterval
		if label$ = snd_label$
			nSoundIntervals = nSoundIntervals+1
			sndIntervals[nSoundIntervals] = iInterval
			starts[nSoundIntervals] = Get start time of interval: 1, iInterval
			ends[nSoundIntervals] = Get end time of interval: 1, iInterval

			intStarts[nSoundIntervals] = ceiling(starts[nSoundIntervals] / pitch_step)
			if intStarts[nSoundIntervals] < 1
				intStarts[nSoundIntervals] = 1
			endif

			intEnds[nSoundIntervals] = floor(ends[nSoundIntervals] / pitch_step)
			if intEnds[nSoundIntervals] > nColumns
				intEnds[nSoundIntervals] = nColumns
			endif

		endif
	endfor
    
	if macintosh
		momel$ = "./" + momelDir$ + "momel_osx_intel"
#		momel$ = "./" + momelDir$ + "momel_osx_ppc"		
	elsif unix
		momel$ = momelDir$ + "momel_linux"
	elsif windows
		momel$ = momelDir$ + "momel_win"
	else
		exit Sorry your system does not seem to be supported by Momel. Contact daniel.hirst@lpl-aix.fr
	endif


	# for identifying the f0min/max in this recording
	tempF0min = 10000
	tempF0max = 0


	# cycle through each interval labelled "sound"  
	for x from 1 to nSoundIntervals
		sndInterval$ = "part_"+"'x'"

		# define the output file for the f0 values
		f0File$ = momelDir$ +sndInterval$+".f0"

		# define the output file for the momel executable
		momelFile$ = momelDir$ +sndInterval$+".model"
		
		# if the f0 file or momel file already exists, delete it/them
		if (fileReadable(f0File$))
			deleteFile: f0File$
		endif
		if (fileReadable(momelFile$))
			deleteFile: momelFile$
		endif

		# get start time of the beginning of the interval
		start = starts[x]

		# get the pitch values and put them in an .f0 file
		for iPitch from intStarts[x] to intEnds[x]
			selectObject: .theMatrix
			pitch = Get value in cell: 1, iPitch
			appendFileLine: f0File$, pitch
		endfor

		# send the .f0 file to momel, which outputs a .momel file
		momelCmd$ = momel$ + " >""" + momelFile$ +""" " + momel_parameters$ + " <""" + f0File$ + """"
		runSystem: momelCmd$
		# system 'momelCmd$'
		# the following deletes the temporary file that momel creates:
		deleteFile: "tmp.txt"

		# read .momel file in
		myStrings = Read Strings from raw text file: momelFile$
		nStrings = Get number of strings

		# write .momel file contents to the PitchTier and to the Points tier of the TextGrid
		for iString from 1 to nStrings
			select myStrings
			string$ = Get string: iString
			ms = extractNumber(string$,"")
			if ms = undefined
				printline String ['iString'] ('string$') doesn't contain a number
			else
				secs = ms/1000
				f0 = extractNumber(string$, " ")
				if f0 > .max_f0
					f0 = .max_f0
				elsif f0 < .min_f0
					f0 = .min_f0
				endif
				time = secs+start
				if time <0
					time = 0
				elsif time > .duration
					time = .duration
				endif	

				# tracking global min/max:
				if (f0 > tempF0max) 
					tempF0max = f0
				endif
				if (f0 < tempF0min)
					tempF0min = f0
				endif

				selectObject: .thePT
				Add point: time, f0

				selectObject: .theTg
				point$ = "0," + string$(floor(f0))
				Insert point: tierPoints, time, point$
			endif
		endfor ; iString
		
		select myStrings
		Remove
		deleteFile: f0File$
		deleteFile: momelFile$
	endfor
	
	# round the global min/max down/up to the nearest 10
	.rangeF0min = floor(tempF0min/10)*10
	.rangeF0max = ceiling(tempF0max/10)*10
	
	# write the global min/max as a first-pass Ranges label
	selectObject: .theTg
	range$ = string$(.rangeF0min)+"-"+string$(.rangeF0max)
	Set interval text: tierRanges, 1, range$
	
	@pitchTierToLevelsLabels: .theTg, .thePT, .rangeF0min, .rangeF0max

	selectObject: .silTg
	Remove
endproc




################################################################
###  
### end of PoLaR-momel-labels-CORE
### 
################################################################