# 2022-05-23
* Added PoLaR-resynthesize-SLA-Dir.praat, to run resynthesis on an entire directory


# 2022-05-21
* Put the "standard/sensitive view" tools back in the "Tier" menu whenever a TextGrid is opened (putting in the the "Pitch" menu caused Praat to sometimes crash)


# 2022-05-19
* Moved the "standard/sensitive view" tools to the "Pitch" menu, so that it can be accessed when there is no TextGrid
* Fixed the "standard/sensitive view" algorithms to better estimate max/min (in the absence of Ranges values)
* Updates to the PoLaR-Conensus-Helper.praat and PoLaR-Conensus-Finisher.praat scripts
* Cleaned up files (removed .praat scripts that weren't being used any more)


# 2022-05-01
* Added the first version of PoLaR-Conensus-Helper.praat (did some minor edits to some adjacent scripts to support it)


# 2022-02-24
* Updated the TextGrid-Blank family of scripts, so as to allow the command to be called from a TextGrid Editor window
* Modified the setup.praat to allow this
* Draw-Sound-and-TextGrid scripts updated to change default "advanced" settings to be slightly more like the non-advanced settings


# 2022-02-09
* The drawing scripts now feature even more options (re: drawing f0, drawing spectrogram)
* If the user deselects the "let the script determine the f0 draw range" option, they can manually input the f0 view range min/max in the drawing
* The CORE script now uses the more modern Praat "colon" style for passing values to functions


# 2022-02-08
* The changelog-plugin_PoLaR.txt file has been renamed to be changelog-plugin_PoLaR.md
* The drawing scripts now feature options to change the spectrogram's dynamic range setting


# 2022-01-28
* The README-FIRST.txt file has been renamed to be README.md
	- Also updated to reflect updates about the Adjust-Editor-View scripts
* The PoLaR-Adjust-Editor-View-* family of .praat files ahve been updated
	- There are now two options:
		* using "standard" values from the PoLaR Guidelines
		* using "sensitive" values that show more information (while being more error prone as a result of being more sensitive)


# 2021-11-15
* The README-FIRST.txt file has been updated to match the increasing functionalities
* The PoLaR-to-pseudocategorical-Dir.praat script has been added
	- This allows users to create Pseudo tier labels for an entire directory of TextGrid files.
* The PoLaR-Adjust-Editor-View script has been added
	- This adjusts the view / analysis settings are adjusted to create a view of the Sound / TextGrid in a way that is consistent with the images in the guidelines documents.
* Various other files have been added / updated to fix some bugs since March 2021
	- Including the "PoLaR-to-pseudocategorical" family of scripts
