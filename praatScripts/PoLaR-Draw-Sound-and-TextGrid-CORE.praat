################################################################
###  
### PoLaR-Draw-Sound-and-TextGrid-CORE
### v.2022.02.07
###
### This script creates drawing for spectrograms, pitch tracks, and TextGrids.
### Based on a script by Pauline Welby (welby@ling.ohio-state.edu, welby@icp.inpg.fr) from November 20, 2005
###
### Instructions:
###     To run from the Praat Objects window:
###         - Select exactly one TextGrid file in the Praat objects window, to make the "PoLaR TextGrids" button appear on the right side of the objects window
###         - Select one of the the menu items whose name begins "Draw Sound and TextGrid"
###     To run from an Editor window:
###         - Click the Tier menu button
###         - Select the menu item whose name begins "Draw Sound and TextGrid"
###     If you chose a menu item with "advanced" in the name:
###         - A pop-up will ask you to provide values for settings
###     After the script runs:
###         - A drawing will appear in the Praat Picture window
###     Note NOTHING IS AUTOMATICALLY SAVED
###
### Byron Ahn
###	Attribution-ShareAlike 2.5 license
###
################################################################

procedure main
	if numberOfSelected ("Sound") = 0
		exitScript: "Select one Sound object (and maybe one matching TextGrid object)"
	elsif numberOfSelected ("Sound") > 1
		exitScript: "Select at most one Sound object and one matching TextGrid object"
	elsif numberOfSelected ("TextGrid") = 0
		use_Ranges_tier_as_draw_range = 0
		tierRanges = 0
		soundName$ = selected$ ("Sound", 1)
		theSound = selected ("Sound", 1)
		@soundAlone
	elsif numberOfSelected ("TextGrid") > 1
		exitScript: "Select at most one TextGrid file"
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
		@soundAndTextgrid
	endif
endproc


# --------------------
# 
#	Procedure soundAlone
#	(When just a Sound object alone is selected)
# 
# --------------------
procedure soundAlone
#	Do calculations for time, frequency, etc.
	@figureThingsOut

# 	Do the drawing of the pitch and spectrogram
	@drawPitchSpec
	sTextName$ =  replace$("'soundName$'", "_", "\_ ", 0)
	@decorateImage: sTextName$

#	Re-select the original sound
	select theSound

#	Write to a file (depending on which boxes were ticked)
	saveAsName$ = "'soundName$'--Sound"
	@saveIfTrue
endproc


# --------------------
# 
#	Procedure soundAndTextgrid
#	(When a Sound object and a TextGrid are both selected)
# 
# --------------------
procedure soundAndTextgrid
	select TextGrid 'tgName$'
	if numberOfSelected () > 0
		totalTiers = Get number of tiers
	endif

	if draw_all_TextGrid_tiers = 0
	beginPause: "TextGrid tiers to include in drawing:"
		for iTier from 1 to totalTiers
			tierNames$ [iTier] = Get tier name... 'iTier'
			tierNameVar$ [iTier] =  replace$(tierNames$ [iTier], " ", "\_ ", 0)
			tierNameVar$ [iTier] =  replace_regex$ (tierNames$ [iTier], "[^0-9a-zA-Z_]", "_", 0)
			tierNameVar$ [iTier] = "draw_" + tierNameVar$ [iTier] + "_tier"
			boolean: tierNameVar$[iTier], 1
		endfor
	clicked = endPause: "Draw These", 1
	endif

#	Discover the tier number in the TextGrid for each of the PoLaR tiers
	@findPoLaRTiers: theTg

#	Do calculations for time, frequency, etc.
	@figureThingsOut

#	Adjust TextGrid to contain the right tiers
	select TextGrid 'tgName$'
	copyName$ = tgName$ + "_copy"
	Copy... 'copyName$'
	select TextGrid 'copyName$'
	if draw_all_TextGrid_tiers = 0
		for i from 1 to totalTiers
			xTier = totalTiers - i + 1
			drawMeVarName$ = tierNameVar$ [xTier]
			drawMe = 'drawMeVarName$'
			if drawMe = 0
				Remove tier... xTier
			endif
		endfor
	endif
	nTiers = Get number of tiers
	tierFrac = 'nTiers'/(4+'nTiers')

	#	Calculate the size of the image, based on number of tiers and size of spectrogram / pitch track
		if 'nTiers'=2
			tgridBot = ('pitchAndSpecBot'-0.43-(('nTiers'-3)*('tierFrac'/('nTiers'+0.8))))/(1-'tierFrac')
		elsif 'nTiers'=1
			tgridBot = ('pitchAndSpecBot'-0.46-(('nTiers'-3)*('tierFrac'/('nTiers'+0.46))))/(1-'tierFrac')
		else
			tgridBot = ('pitchAndSpecBot'-0.4-(('nTiers'-3)*('tierFrac'/('nTiers'+2.5))))/(1-'tierFrac')
		endif
	###		(I don't know why these fractions work out the way they do
	###		based on how big TextGrids should be, the equation should be:
	###			tgridBot = ('pitchAndSpecBot'-0.5)/(1-'tierFrac')
	###		but this produces too much whitespace.)
	figBot = 'tgridBot'


# 	Do the drawing of the pitch and spectrogram
	@drawPitchSpec

#		Define size and position of TextGrid
#			Weirdly, where to place the top of the TextGrid drawing
#			depends on the number of tiers
		select TextGrid 'copyName$'
		nTiers = Get number of tiers
		if 'nTiers' > 8
			tgridTop = 0.15
		elsif 'nTiers' > 7
			tgridTop = 0.125
		elsif 'nTiers' > 6
			tgridTop = 0.1
		elsif 'nTiers' > 4
			tgridTop = 0.05
		elsif 'nTiers' > 3
			tgridTop = 0.025
		else
			tgridTop = 0.0
		endif
#		Select the viewport for drawing
		Viewport... 0 'width_of_entire_drawing' 'tgridTop' 'tgridBot'

#		Draw TextGrid
		Draw... 'startTime' 'endTime' no no no
		tierFrac = 'nTiers'/(4+'nTiers')
		#	Calculate the size of the image, based on number of tiers and size of spectrogram / pitch track
			if 'nTiers'=2
				tgridBot = ('pitchAndSpecBot'-0.43-(('nTiers'-3)*('tierFrac'/('nTiers'+0.8))))/(1-'tierFrac')
			elsif 'nTiers'=1
				tgridBot = ('pitchAndSpecBot'-0.46-(('nTiers'-3)*('tierFrac'/('nTiers'+0.46))))/(1-'tierFrac')
			else
				tgridBot = ('pitchAndSpecBot'-0.4-(('nTiers'-3)*('tierFrac'/('nTiers'+2.5))))/(1-'tierFrac')
			endif
		tiersTotalHeight = pitchAndSpecBot - tgridBot
		tierHeight = tiersTotalHeight / nTiers
		tierLabelLeft = 'width_of_entire_drawing' - 0.7
		
		for iTier from 1 to nTiers
			Font size... 10
			select TextGrid 'copyName$'
			tierLabel$ = Get tier name... 'iTier'
			currTierTop = 'pitchAndSpecBot' - (0.15*1.5/height_of_the_pitch_track_and_spectrogram) - ('iTier'-1)*tierHeight
			currTierBot = 'currTierTop' + 'tierHeight'
			Viewport... 'tierLabelLeft' 'width_of_entire_drawing' 'currTierTop' 'currTierBot'
			Viewport text... Left Half 0 'tierLabel$'
			Font size... 12
		endfor

	tTextName$ =  replace$("'tgName$'", "_", "\_ ", 0)
	@decorateImage: tTextName$
	select TextGrid 'copyName$'
	Remove
	select theSound
	plusObject: theTg

#	Write to a file (depending on which boxes were ticked)
	saveAsName$ = "'tgName$'--'nTiers'"
	@saveIfTrue
endproc



# --------------------
# 
#	Procedure decorateImage
#	(Used to do the final decorations to the image)
# 
# --------------------
procedure decorateImage: .title$
#	Define size and position of the entire Picture
	Viewport... 0 'width_of_entire_drawing' 0 'figBot'
	Text top... no '.title$'

#	Draw inner box
	Black
	Draw inner box

#	Label x axis
	Line width... 1
		One mark bottom... 'startTime' no yes yes 'startTime'
		One mark bottom... 'endTime' no yes yes 'endTime'
		Text bottom... no Time (s)


	select Spectrogram 'soundName$'
	Remove
	select Pitch 'soundName$'
	Remove
endproc



# --------------------
# 
#	Procedure saveIfTrue
#	(Save the image files, if the options to do so are enabled)
# 
# --------------------
procedure saveIfTrue
	if ('save_as_pdf' = 1) or ('save_as_eps' = 1) or ('save_as_png' = 1)
		outDir$ = chooseDirectory$: "Choose the folder to save the drawing"
		if right$(outDir$,1) <> "/" and right$(outDir$,1) <> "\"
			outDir$ = outDir$ + "/"
		endif
	endif

	if 'save_as_pdf' = 1
		saveme$ = outDir$ + saveAsName$ + ".pdf"
		Save as PDF file... 'saveme$'
	endif
	if 'save_as_eps' = 1
		saveme$ = outDir$ + saveAsName$ + ".eps"
		Write to EPS file... 'saveme$'
	endif
	if 'save_as_png' = 1
		saveme$ = outDir$ + saveAsName$ + ".png"
		Save as 300-dpi PNG file... 'saveme$'
	endif
endproc



# --------------------
# 
#	Procedure figureThingsOut
#	(Does various calculations to figure out time, frequency range, etc.)
# 
# --------------------
procedure figureThingsOut
#	Determine the appropriate f0 min/max, and save them as rangeMin and rangeMax
	@findLocalMinMax: startTime, endTime

#	Determine the appropriate number of f0 marks on the y-axis of the drawing
	@calculateIntervalMarks

	specFMin = 0

#	these numbers depend on the margins, which are determined by the font size
	pitchAndSpecTop = 0
	pitchAndSpecBot = 'pitchAndSpecTop' + 'height_of_the_pitch_track_and_spectrogram' + 0.92
	figBot = 'pitchAndSpecBot'

#	Figure Spectrogram out
		select Sound 'soundName$'
		sampFreq = Get sampling frequency
		halfSampFreq = sampFreq / 2
		if 'spectrogram_settings_FreqMax' > 'halfSampFreq'
			spectrogram_settings_FreqMax = round('halfSampFreq'/100)*100
		endif

#	Figure time out
	if 'endTime' = 0
		select Sound 'soundName$'
		durTime = Get total duration
		startTime = 0
		endTime = durTime
	else
		durTime = 'endTime' - 'startTime'
	endif
	timeStepNum = 'durTime' / 1000
	freqStepNum = 'spectrogram_settings_FreqMax' div 250
	durTime = round ('durTime' * 1000) / 1000
	endTime = round ('endTime' * 1000) / 1000
endproc



# --------------------
# 
#	Procedure drawPitchSpec
#	(Draw the pitch and spectrogram parts of the image)
# 
# --------------------
procedure drawPitchSpec
	time_step = 0.0025
	number_of_candidates = 15
	very_accurate = 1
	silence_threshold = 0.03
	voicing_threshold = 0.5
	octave_cost = 0.05
	octave_jump_cost = 0.5
	voice_unvoiced_cost = 0.2

	if manual_advanced_pitch_settings = 1
	beginPause: "Advanced Settings"
		real: "time_step (0 = auto)", 0.0025
		integer: "number_of_candidates", 15
		boolean: "very_accurate", 1
		positive: "silence_threshold", 0.03
		positive: "voicing_threshold", 0.5
		positive: "octave_cost", 0.05
		positive: "octave_jump_cost", 0.5
		positive: "voice_unvoiced_cost", 0.2
	clicked = endPause: "Submit", 1
	endif

#	Make Pitch object
	select Sound 'soundName$'
	To Pitch (ac)... 'time_step' 'rangeMin' 'number_of_candidates' 'very_accurate' 'silence_threshold' 'voicing_threshold' 'octave_cost' 'octave_jump_cost' 'voice_unvoiced_cost' 'rangeMax'

#	Make Spectrogram object
	select Sound 'soundName$'
	To Spectrogram... 0.005 'spectrogram_settings_FreqMax' 'timeStepNum' 'freqStepNum' Gaussian


#	Specify font type size, color
	Times
	Font size... 12
	Black


#	Define size and position of pitch track / spectrogram
	Viewport... 0 'width_of_entire_drawing' 'pitchAndSpecTop' 'pitchAndSpecBot'
	Erase all

#	Draw Spectrogram 
	select Spectrogram 'soundName$'
	Paint... 'startTime' 'endTime' 0 0 100 yes 'spectrogram_dynamic_range' 6 0 no

#	Label y axis
	Line width... 1
	One mark right... 'spectrogram_settings_FreqMax' yes yes yes
	One mark right... 'specFMin' yes yes no
	Text right... yes Frequency (Hz)


#	Draw Pitch 
	select Pitch 'soundName$'
	
	if (use_Ranges_tier_as_draw_range = 1) and (tierRanges > 0)
		actf0min = rangeMin
	else
		actf0min = Get minimum... 'startTime' 'endTime' Hertz Parabolic
	endif
	actf0min = 'actf0min' - ('actf0min' mod 'y_axis_interval')

	if (use_Ranges_tier_as_draw_range = 1) and (tierRanges > 0)
		actf0max = rangeMax
	else
		actf0max = Get maximum... 'startTime' 'endTime' Hertz Parabolic
	endif
	actf0max = 'actf0max' + ('y_axis_interval' - ('actf0max' mod 'y_axis_interval'))


#	Draw big white dots to make blue pitch dots more visible with spectrogram background
	Speckle size... 2.5 
	White
	if use_this_f0_range_as_draw_range = 0
		Speckle... 'startTime' 'endTime' 'actf0min' 'actf0max' no
	else
		Speckle... 'startTime' 'endTime' 'rangeMin' 'rangeMax' no
	endif

#	Draw blue dots for pitch values
	Speckle size... 1.0
	Blue
	if use_this_f0_range_as_draw_range = 0
		Speckle... 'startTime' 'endTime' 'actf0min' 'actf0max' no
	else
		Speckle... 'startTime' 'endTime' 'rangeMin' 'rangeMax' no
	endif

#	Label y axis
	Black
	Line width... 1
	if 'mark_f0_intervals_on_the_axis' = 1
		Marks left every... 1 'y_axis_interval' yes yes no
		if use_this_f0_range_as_draw_range = 0
			One mark left... 'actf0max' no no yes
		else
			One mark left... 'rangeMax' no no yes
		endif
	else
		if use_this_f0_range_as_draw_range = 0
			One mark left... 'actf0max' yes yes yes
		else
			One mark left... 'rangeMax' yes yes yes
		endif
		if use_this_f0_range_as_draw_range = 0
			One mark left... 'actf0min' yes yes no
		else
			One mark left... 'rangeMin' yes yes no
		endif
	endif
	Text left... yes f0 (Hz)
endproc


# --------------------
# 
#	Procedure findLocalMinMax
#	(Used to extract F0 min/max information encoded in the Ranges tier, if it exists)
# 
# --------------------
procedure findLocalMinMax: .start, .end
	rangeMin = f0Min
	rangeMax = f0Max
	if (use_Ranges_tier_as_draw_range = 1) and (tierRanges > 0)
		rangeMin = 10000
		rangeMax = 0
		# Query TG tier 'tierRanges' for number of intervals
		numRanges = Get number of intervals... 'tierRanges'

		if .start > 0
			.firstInt = Get interval at time... 'tierRanges' .start
		else
			.firstInt = 1
		endif
		if .end > 0
			.lastInt = Get interval at time... 'tierRanges' .end
		else
			.lastInt = numRanges
		endif

		.numLabeledRanges = 0

		.forCount = .lastInt - .firstInt + 1

		for x to .forCount
			.thisInt = x + .firstInt - 1
			select TextGrid 'tgName$'

			.intervalLabel$ = Get label of interval: tierRanges, x

			@parseRanges: .intervalLabel$

			if parseRanges.localMin = undefined or parseRanges.localMax = undefined
				.numLabeledRanges = .numLabeledRanges
			else
				.numLabeledRanges += 1
			endif
			if parseRanges.localMin < rangeMin
				rangeMin = parseRanges.localMin
			endif
			if parseRanges.localMax > rangeMax
				rangeMax = parseRanges.localMax
			endif
		endfor
	endif
endproc




# --------------------
# 
#	Procedure calculateIntervalMarks
#	(To get an appropriate number of F0 interval marks on the y-axis; between 4-7, generally)
# 
# --------------------
procedure calculateIntervalMarks
	.f0MinMaxRange = rangeMax - rangeMin
	if .f0MinMaxRange <= 45
		y_axis_interval = 10
	elsif .f0MinMaxRange <= 75
		y_axis_interval = 15
	elsif .f0MinMaxRange <= 175
		y_axis_interval = 25
	elsif .f0MinMaxRange <= 350
		y_axis_interval = 50
	elsif .f0MinMaxRange <= 700
		y_axis_interval = 100
	else
		y_axis_interval = 150
	endif
endproc




include PoLaR-praat-procedures.praat


################################################################
###  
### end of PoLaR-Draw-and-Save-CORE
### 
################################################################