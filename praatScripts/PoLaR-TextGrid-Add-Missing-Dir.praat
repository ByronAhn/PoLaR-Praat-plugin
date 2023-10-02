################################################################
###
### PoLaR-Add-Missing
### v.2023.09.10
###
###
### This script adds any PoLaR tiers that are missing from TextGrids
### 
### Instructions:
###  - Choose the 
###  - Click the button on the righthand side of the objects window, titled "PoLaR TextGrids ▾"
###  - Choose "Add Missing PoLaR Tiers"
###  - You're done! For any PoLaR tiers that were missing before, you will now have blank tiers 
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





# fileNames$# is a function that wasn't defined until 6.1.38
@versionChecker: 6, 1, 38

numLogs = 0
numWarnings = 0
numChangedFiles = 0

@saveSelection


# get directory / directory listing
beginPause: "Where are your .Textgrid files?"
	comment: "Hit the ""Choose Folder"" button to select the with your .Textgrid"
	comment: "files, to add any missing PoLaR tiers to."
endPause: "Choose Folder", 1
inDir$ = chooseDirectory$: "Choose the folder with .Textgrid files"
if right$(inDir$,1) <> "/" and right$(inDir$,1) <> "\"
	inDir$ = inDir$ + "/"
endif

listOfFiles$# = fileNames$#: (inDir$ + "*.*")

# Cycle through each TextGrid file that is in the folder
for xF from 1 to size(listOfFiles$#)
	aFilename$ = listOfFiles$#[xF]

	# target .textgrid files (regardless of capitalization)
	extensionDotLoc = rindex(aFilename$, ".")
	baseFilename$ = left$(aFilename$, extensionDotLoc-1)
	extension$ = right$(aFilename$, length(aFilename$)-extensionDotLoc)
	lowercaseExtension$ = replace_regex$ (extension$, "[A-Z]", "\L&", 0)

	if lowercaseExtension$ = "textgrid"
		tgFile$ = inDir$ + baseFilename$ + ".Textgrid"
		tgObj = Read from file: tgFile$
		@addMissingPoLaRTiersMain: tgObj
		if (addMissingPoLaRTiersMain.anyChanges>0)
			numChangedFiles = numChangedFiles + 1
			Save as text file: tgFile$
		endif
		Remove
	endif
endfor

@returnSelection

if (numChangedFiles = 1)
	byeMsg$ = ">> There was 1 file that was edited."
else
	byeMsg$ = ">> There were " + string$(numChangedFiles) + " files that were edited."
endif

@logging: "Finished!"
@logging: byeMsg$ + newline$ +  ">> Any changes were was saved in this folder: " + newline$ + "   " + inDir$


include PoLaR-TextGrid-Add-Missing-CORE.praat