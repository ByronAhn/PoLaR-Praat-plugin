# 2023-09-18
* Some big overhauls in this version:

	- Overhauled the `README.md` because of the other major overhauls and new functionalities

	- Overhauled the locations of various Praat plugin functionalities in the Objects window
		- For various functionalities that apply to entire directories, the menu items are now in a "PoLaR plugin" menu folder
			* This can be found in two places:
				1. In the "New" menu of the Objects window
				2. In the "Praat" menu (in the menubar of MacOS or in the Objects window on other OSs)
		- There are now 4 buttons on the right:
			1. Modify/Inspect PoLaR TextGrids
				a. Add Missing PoLaR Tiers
				b. Clear PoLaR tiers
				c. Clear PoLaR tiers + Delete other tiers (CAUTION)
				d. Extract info from PoLaR tiers
			2. Generate PoLaR Labels
				a. New Points/Levels/Ranges from Momel
				b. New Points/Levels/Ranges from Momel (More Settings)
				c. Levels Labels
				d. Levels Labels (More Settings)
				e. Pseudo Labels (Adv. labels req'd!)
				f. Consensus Helper (beta)
			3. Assess PoLaR Turning Points
				a. Adjust Points audio/visually
				b. Straight Line Approx.
				c. Straight Line Approx. (More Settings)
			4. Create Drawing for Sound(+TextGrid)
				a. Create picture
				b. Create picture (More Settings)

	* Overhauled the locations of various Praat plugin functionalities in the Editor windows
		- All Praat menu items are now in the "Edit" menu
			* In the Edit menu: the functionalities are organized in a more user-friendly way
		- This is to make it uniform across Sound editor windows and TextGrid editor windows

* Two major functionality additions in this version:
	1. Using Momel algorithms/binaries (released publicly [here](https://www.researchgate.net/publication/342039069_plugin_momel-intsint)) to create (first-draft) Points/Levels/Ranges labels
		* There are now menu items called "New Points/Levels/Ranges from Momel"
		* They can be accessed through all the normal places for PoLaR plugin functionalities:
			- The "Generate PoLaR Labels" button in the Objects window (when a Sound and TextGrid [and optional PitchTier] are selected)
			- Under the "Generate PoLaR Labels" sub-menu in the an Editor window, when a Sound and TextGrid are open
			- The "PoLaR plugin" sub-menu of the Praat/New buttons from an Objects window, for running on an entire directory
	2. Using a Manipulation window in Praat to audio/visually edit your f0 turning points locations
		* There are now menu items called "Adjust Points audio/visually"
		* They can be accessed through all the normal places for PoLaR plugin functionalities:
			- The "Assess PoLaR Turning Points" button in the Objects window (when a Sound and TextGrid are selected)
			- Under the "Assess PoLaR Turning Points" sub-menu in the an Editor window, when a Sound and TextGrid are open
			- The "PoLaR plugin" sub-menu of the Praat/New buttons from an Objects window, for running on an entire directory

* Other minor behind-the-scenes code changes occured, with little to no impact on the user experience

* >>>>>> ATTENTION macOS USERS <<<<<<
	- If you're experiencing an error when you try to run "New Points/Levels/Ranges from Momel", you might need to try and run the Momel app first
	- Directions to run the Momel app:
		* Navigate to the `momelFiles` directory in the `plugin_PoLaR` folder
		* Double click on `momel_osx_intel`, and you might get a message saying:
			"`"momel_osx_intel"` cannot be opened because it is from an unidentified developer."
		* If you do, click `OK` and then right-click (or control-click) on `momel_osx_intel` and select `Open`, and now you'll get a *new* message:
			"`"momel_osx_intel"` is a Unix app downloaded from the Internet. Are you sure you want to open it?"
		* Click `Open`; a Terminal window will open and show a few lines of text
	- After this is done, close the Terminal window and try to run the "New Points/Levels/Ranges from Momel" functionality again from Praat


# 2023-05-30
* Amended all the Editor Scripts so they work if the user has loaded a sound as a LongSound (PoLaR-to-pseudocategorical-from-TGE.praat, PoLaR-Conensus-Finisher.praat, PoLaR-Draw-Sound-and-TextGrid-from-TGE-Adv.praat, PoLaR-Draw-Sound-and-TextGrid-from-TGE.praat, PoLaR-Extract-Info-to-TSV-from-TGE.praat, PoLaR-Levels-labeller-from-TGE.praat, PoLaR-resynthesize-SLA-from-TGE.praat, PoLaR-resynthesize-SLA-listen-from-TGE.praat)

# 2022-10-18
* Added PoLaR-TextGrid-Add-Missing.praat, to add any missing PoLaR tiers to a TextGrid
* Added Remove-unspecified-tiers.praat, to allow a user to remove multiple tiers, except those named
* Added PoLaR-Draw-Sound-and-TextGrid-Dir.praat (and some related PoLaR-Draw-Sound-and-TextGrid Praat scripts), to allow the drawing function to be run on an entire directory


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
