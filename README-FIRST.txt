==========================
# PoLaR plugin for Praat #
# v.2022.01.28           #
==========================

#########################################
#########################################
##  Steps to install the Praat plugin  ##
#########################################
#########################################

1. Navigate to your “Praat preferences” directory
    * On Windows, if your username is xxyyzz, your “Praat preferences” directory is:
        C:\Users\xxyyzz\Praat\
    * On Linux, your “Praat preferences” directory is in your home directory, namely at:
        ~/.praat-dir/
    * On a Mac, your “Praat preferences” directory is in your user Library folder, more
      specifically at:
        ~/Library/Preferences/Praat Prefs/
            #============================================================================#
            |NOTE: On a Mac, this folder is in a hidden directory, so to get there, use  |
            |      ”Go To Folder” in Finder. (Open up a Finder window, and hit           |
            |      [SHIFT]+[CMD]+G; more details on the Apple support site.)             |
            #============================================================================#
    * In all cases, if you do not see your directory there, you may need to create it.
    * (If you have trouble, see navigate to this webpage, where this is described in a
      different way: https://www.fon.hum.uva.nl/praat/manual/preferences_folder.html )

2. Within your Praat preferences directory, create a new directory‚ called “plugin_PoLaR”
    * The plugin directory ~must~ begin with “plugin_”
    * “plugin_PoLaR” ~must~ be found immediately inside the “Praat preferences” directory
        - on Windows, C:\Users\xxyyzz\Praat\plugin_PoLaR\
        - on Linux, ~/.praat-dir/plugin_PoLaR/
        - on a Mac, ~/Library/Preferences/Praat Prefs/plugin_PoLaR/

3. Move all the .praat files to this new folder
    * Importantly: all .praat files must be in this “plugin_Praat” directory, *WITHOUT*
      any extra directories in between
    * So for example the setup.praat file needs to be here:
        - on Windows, C:\Users\xxyyzz\Praat\plugin_PoLaR\setup.praat
        - on Linux, ~/.praat-dir/plugin_PoLaR/setup.praat
        - on a Mac, ~/Library/Preferences/Praat Prefs/plugin_PoLaR/setup.praat

4. If Praat is open, (save all your files and) quit the application and restart it
    * After restarting, the plug-in is installed, and the new menu commands or buttons 
      will be ready to use!


#############################################
#############################################
##  What Can You Do with the PoLaR plugin  ##
#############################################
#############################################

###################################
#  From the Praat Objects Window  #
###################################

==========================================================
Buttons on the right-hand side of the Praat Objects window
==========================================================
* If you select one or more TextGrid objects…
    - A menu called "PoLaR TextGrids ▾" will appear, which contains some buttons:
          * The first is labelled "Blank PoLaR tiers".
              - This will add blank PoLaR tiers to an existing TextGrid.
              - If the TextGrid already contained any PoLaR tiers, they will be deleted
                and replaced with blank ones.
          * The second is labelled "Only Blank PoLaR tiers (DANGER)"
              - This does the same as "Blank PoLaR tiers" but it ~~ALSO~~ deletes all
                other tiers (except Words and Phones tiers), leaving only blank PoLaR
                tiers.
          * The third is labelled "Pseudo Labels (Adv. labels req'd!)"
              - This adds labels to a "Pseudo" tier – a tier that encodes "pseudo-
                categorical" labels, that resemble A-M style phonological labels.
              - Running this script requires that ~~ALL~~ PoLaR tiers are annotated, and
                that the Points tier contains ~~ADVANCED~~ PoLaR labels.
              - Some details about the algorithm are laid out in §5.1.3 of the monograph
                called "Embarking on PoLaR Explorations", which can be found on the PoLaR
                OSF repository.
 
* If you select a TextGrid-Sound pair…
    - A menu called "PoLaR TextGrids ▾" will appear, which contains the same buttons as  
      above, plus some others:
        * The "Blank PoLaR tiers", "Only Blank PoLaR tiers (DANGER)", and "Pseudo Labels
          (Adv. labels req'd!)" buttons doe the same as described above.

        * There is now also a button called "Extract info from PoLaR tiers".
            - This will collect and organize PoLaR labels as well as some measures
              associated with them, which is output to the Praat Info window.
            - That information is organized with a header and with elements separated by
              tabs, so it can be pasted easily into a spreadsheet for further analysis.
            - The same functionality can be achieved through the View & Edit window menu
              item, discussed below.

        * There are now two other buttons named "Levels Labels (Quick)" and "Levels
	      Labels (Advanced)"
	        - These have the same core functionality:
                * The TextGrid object will be edited, with Levels tier labels generated on
                  the basis of existing Points and Ranges labels.
                * Any existing Levels tier labels will be replaced.
                * If no Levels tier exists, one will be created.
            - The buttons have slightly different behaviors
                * PoLaR Levels Labeller (Quick)
                    - Using default settings, new Levels tier labels are added to the
                      existing TextGrid object.
                    - The same functionality can be achieved through the View & Edit
                      window menu item, discussed below.
                * PoLaR Levels Labeller (Advanced)
                    - This opens a window with many more options and parameters that can
                      be set.

    - A menu called "PoLaR Straight Line Approx. ▾" will appear, which contains some 
      buttons:
        * All of these buttons have the same core functionality:
            - The Sound object will be resynthesized, to create a straight-line
              approximation of the pitch contour, on the basis of Points tier labels and
              f0 measurements.
            - Two new Praat objects are created (but aren't saved): a Manipulation object
              and a Sound object, with resynthesized pitch.
            - The newly resynthesized Sound and original TextGrid are opened together, in
              a new View & Edit window.
        * The buttons have slightly different behaviors
            - PoLaR SLA (Quick+Quiet)
                * Using default settings, a SLA is created and the resynthesized Sound is
                  opened with the TextGrid.
            - PoLaR SLA (Quick)
                * Just like Quick+Quiet, but it also plays the original and resynthesized
                  Sounds back-to-back, for easy comparison.
            - PoLaR SLA (Advanced)
                * This opens a window with many more options and parameters that can be 
                  set.
        * The same functionality can be achieved through the View & Edit window menu items
          that are discussed below.

    - A menu called "Draw Sound and TextGrid ▾" will appear, which contains two buttons:
        * Both of these buttons have the same core functionality:
            - Create a drawing with the f0 track overlaid on top of a spectrogram for the 
              Sound object, plus the TextGrid labels underneath.
            - (This simulates the display for a View & Edit window.)
        * The two buttons have slightly different behaviors
            - Create picture with default settings
                * Draws using default settings for Pitch tracking, the Spectrogram, etc.
            - Manually configure settings (advanced)
                * This opens a window with many more options and parameters that can be 
                  set, for doing the drawing.
        * The same functionality can be achieved through the View & Edit window menu items
          that are discussed below.

* If you select just a Sound…
    - A menu called "Draw Sound ▾" will appear, which contains two buttons:
        * Both of these buttons have the same core functionality:
            - Create a drawing with the f0 track overlaid on top of a spectrogram for the 
              Sound object.
            - (This simulates the display for a View & Edit window.)
        * The two buttons have slightly different behaviors
            - Create picture with default settings
                * Draws using default settings for Pitch tracking, the Spectrogram, etc.
            - Manually configure settings (advanced)
                * This opens a window with many more options and parameters that can be 
                  set, for doing the drawing.

===========================================================
Menu items under the Praat Objects window "New" menu button
===========================================================
* Menu item in the Praat Objects window
    - In the "New" menu of the Objects window, there are 3 PoLaR commands, that operate on
      all files in a directory.
        * The first is a command called "Extract PoLaR info from files in a directory".
            - This will collect and organize PoLaR labels as well as some measures 
              associated with them, and output this information into one or more .tsv 
              files, for all .wav and .Textgrid files in a single directory.
            - Such .tsv files can be easily imported into a spreadsheets or statistical
              software, for further analysis.
            - After providing Praat with the directory, the program cycles through each
              .wav file and looks for a .Textgrid file of the same name.
            - Moreover, in order to extract the relevant information, PoLaR labels must
              already exist in the .Textgrid files.
        * The second is labelled "Label the Levels tier for files in a directory".
            - After providing Praat with the directory, the program cycles through each
              .wav file and looks for a .Textgrid file of the same name.
            - This will add PoLaR labels to the Levels tier, using the same algorithm that
              is run from other places in Praat.
        * The third is labelled "Label the Pseudo tier for files in a directory".
            - After providing Praat with the directory, the program cycles through each
              .wav file and looks for a .Textgrid file of the same name.
            - This will add PoLaR labels to the Pseudo tier, using the same algorithm that
              is run from other places in Praat.

#############################
#  From a View&Edit Window  #
#############################

* When you open a Sound or TextGrid object (or both together), a View & Edit window opens,
  with its own menu buttons
* Within these menu buttons, the "Tier" menu contains several PoLaR script commands.
    - PoLaR: Automatic Editor View Settings
        * This adjusts the pitch and spectrogram settings
        * This can either be according to…
            - …the values used throughout the PoLaR annotation guidelines
                   ---OR---
            - …slightly more sensitive (more error-prone) values
        * When there are Ranges tier labels already, these are used to set the Pitch
              min/max settings.
    - PoLaR: Resynthesize Straight Line Approximation
        * This does the same thing as PoLaR SLA (Quick+Quiet), described above
    - PoLaR: Levels Labels
        * This does the same thing as PoLaR Levels Labeller (Quick), described above
    - PoLaR: Extract info from PoLaR tiers
        * This does the same thing as Extract info from PoLaR tiers, described above
    - PoLaR: Pseudo Labels (Advanced labels req'd!)
        * This does the same thing as Pseudo Labels, described above
    - PoLaR: Create picture (default settings)
        * This does the same thing as "Create picture with default settings" in the
          "Draw Sound and TextGrid ▾" menu, as described above
    - PoLaR: Create picture (advanced)
        * This does the same thing as "Manually configure settings (advanced)" in the
          "Draw Sound and TextGrid ▾" menu, as described above