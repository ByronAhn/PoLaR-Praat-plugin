################################################################
###  
### Remove-unspecified-tiers
### v.2022.09.19
###
### This script asks the user for a list of tiers to keep, and removes all others from selected TextGrids
### 
### 
### Instructions:
### 
###  In the Praat objects window, select all the TextGrid objects that you want to edit
###       - On the right, click the "Modify -" button to open a menu
###       - Select the "Removed unspecified tiers" menu item
###  You will be prompted for a list of tier names to keep
###       - Any tier whose name does not exist in this list ~~will be removed~~
### 
### 
###	Byron Ahn
###	Attribution-ShareAlike 2.5 license
###
################################################################


# start by getting the information from the user
	beginPause: "List of tiers to keep"
		comment: "Separated each tier name by spaces"
		text: "List of tiers to keep:", "Words Phones PrStr Points Levels Ranges misc"
	endPause: "OK", 1

# convert the tiers into all lowercase:
	list_of_tiers_to_keep$ = replace_regex$ (list_of_tiers_to_keep$, "[A-Z]", "\L&", 0)

# parse string into chunks, separated by whitespace, and put into a vector:
	tiersToKeep$# = splitByWhitespace$# (list_of_tiers_to_keep$)

# store the number of tiers that are being kept
	numTiersToKeep = size (tiersToKeep$#)

# call the function to go through and remove the tiers that are not in tiersToKeep$#
	@removeTiersOutsideOfList



# --------------------
# 
#	Procedure removeTiersOutsideOfList
#	(Used to remove the Tiers that are *NOT* in the list)
# 
# --------------------
procedure removeTiersOutsideOfList
	# save the current selection of TextGrids
	@saveSelection

	# Cycle through each TextGrid object that is selected
	for z to numberOfSelected ("TextGrid")
		origTg = selected ("TextGrid", z)
		selectObject: origTg

		numTiers = Get number of tiers
		numRemoved = 0

		for i from 1 to numTiers
			# we're looking at the Xth tier, where x is based on i, but adjusted for how many tiers have been removed so far
			x = i - numRemoved

			# get the name of this tier
			xTier$ = Get tier name: x

			# convert this tier name to all lowercase
			xTier$ = replace_regex$ (xTier$, "[A-Z]", "\L&", 0)

			# check to see if the name of the tier is in the array
			# if so, set inArray to the tier number
			inArray = 0
			y = 0
			while y < numTiersToKeep and inArray = 0
				y = y + 1
				if xTier$ = tiersToKeep$# [y]
					inArray = y
				endif
			endwhile

			# if inArray is 0, then Tier x doesn't match the names of those in the list of tiers to keep
			# in this case, remove Tier x and increase the number of numRemoved
			if inArray = 0
				Remove tier: x
				numRemoved = numRemoved + 1
			endif
		endfor

		# move back to the original selection of TextGrids, so that selecting the Zth tier works correctly
		@returnSelection
	endfor
endproc



# --------------------
# 
#	Procedure saveSelection
#	(Used to bookmark which objects are currently selected)
# 
# --------------------
procedure saveSelection
	.numSavedSel = numberOfSelected()
	if .numSavedSel > 0
		.theSavedSel# = zero# (.numSavedSel)
		for x from 1 to .numSavedSel
			.theSavedSel# [x] = selected(x)
		endfor
	else
		.theSavedSel# = {0}
	endif
endproc



# --------------------
# 
#	Procedure returnSelection
#	(Used to re-open the previously bookmarked selection)
# 
# --------------------
procedure returnSelection
	if saveSelection.numSavedSel > 0
		selectObject: saveSelection.theSavedSel#
	endif
endproc