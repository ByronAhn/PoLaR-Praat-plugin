####################################################
# PoLaR plugin for Praat                           #
# v.2023.09.14                                     #
#                                                  #
# Refer to the documentation in README.md          #
#                                                  #
####################################################

# Set the write settings to UTF-8 and read settings too
Text writing preferences: "UTF-8"
Text reading preferences: "try UTF-8, then ISO Latin-1"



##########################################################
##########################################################
################  EDITOR  MENU  COMMANDS  ################
##########################################################
##########################################################

#################################################
# Add the menu commands within the Sound editor #
#################################################
Add menu command: "SoundEditor", "Edit", "- PoLaR-assisted View Settings:", "", 0, ""
Add menu command: "SoundEditor", "Edit", "Standard view settings", "", 0, "praatScripts/PoLaR-Adjust-Editor-View-Standard.praat"
Add menu command: "SoundEditor", "Edit", "Sensitive view settings", "", 0, "praatScripts/PoLaR-Adjust-Editor-View-Sensitive.praat"

Add menu command: "SoundEditor", "Edit", "- Create PoLaR-styled Drawing:", "", 0, ""
Add menu command: "SoundEditor", "Edit", "Create picture", "", 0, "praatScripts/PoLaR-Draw-Sound-and-TextGrid-from-TGE.praat"
Add menu command: "SoundEditor", "Edit", "Create picture (More Settings)", "", 0, "praatScripts/PoLaR-Draw-Sound-and-TextGrid-from-TGE-Adv.praat"

Add menu command: "SoundEditor", "File", "- New PoLaR TextGrids:", "", 0, ""
Add menu command: "SoundEditor", "File", "Create Blank PoLaR TextGrid", "", 0, "praatScripts/PoLaR-TextGrid-for-Sound-from-TGE.praat"
Add menu command: "SoundEditor", "File", "Create PoLaR TextGrid with Momel-based labels", "", 0, "praatScripts/PoLaR-momel-labels-from-TGE-Sound.praat"


####################################################
# Add the menu commands within the TextGrid editor #
####################################################
Add menu command: "TextGridEditor", "Edit", "- PoLaR-assisted View Settings:", "", 0, ""
Add menu command: "TextGridEditor", "Edit", "Standard view settings", "", 0, "praatScripts/PoLaR-Adjust-Editor-View-Standard.praat"
Add menu command: "TextGridEditor", "Edit", "Sensitive view settings", "", 0, "praatScripts/PoLaR-Adjust-Editor-View-Sensitive.praat"

Add menu command: "TextGridEditor", "Edit", "- Create PoLaR-styled Drawing:", "", 0, ""
Add menu command: "TextGridEditor", "Edit", "Create picture", "", 0, "praatScripts/PoLaR-Draw-Sound-and-TextGrid-from-TGE.praat"
Add menu command: "TextGridEditor", "Edit", "Create picture (More Settings)", "", 0, "praatScripts/PoLaR-Draw-Sound-and-TextGrid-from-TGE-Adv.praat"

Add menu command: "TextGridEditor", "Tier", "- Modify/Inspect PoLaR TextGrids:", "", 0, ""
Add menu command: "TextGridEditor", "Tier", "Add missing PoLaR tiers", "", 0, "praatScripts/PoLaR-TextGrid-Add-Missing-from-TGE.praat"
Add menu command: "TextGridEditor", "Tier", "Extract info from PoLaR tiers", "", 0, "praatScripts/PoLaR-Extract-Info-to-TSV-from-TGE.praat"

Add menu command: "TextGridEditor", "Tier", "- Assess PoLaR Turning Points:", "", 0, ""
Add menu command: "TextGridEditor", "Tier", "Adjust Points audio/visually", "", 0, "praatScripts/PoLaR-Adjust-Points-in-Manipulation-from-TGE.praat"
Add menu command: "TextGridEditor", "Tier", "Resynthesize Straight Line Approximation", "", 0, "praatScripts/PoLaR-resynthesize-SLA-from-TGE.praat"

Add menu command: "TextGridEditor", "Tier", "- Generate PoLaR Labels:", "", 0, ""
Add menu command: "TextGridEditor", "Tier", "New Momel-based Points/Levels/Ranges", "", 0, "praatScripts/PoLaR-momel-labels-from-TGE.praat"
Add menu command: "TextGridEditor", "Tier", "New Levels Labels", "", 0, "praatScripts/PoLaR-Levels-labeller-from-TGE.praat"
Add menu command: "TextGridEditor", "Tier", "New Pseudo Labels (Advanced labels req'd!)", "", 0, "praatScripts/PoLaR-to-pseudocategorical-from-TGE.praat"




###########################################################
###########################################################
################  OBJECT  WINDOW  BUTTONS  ################
###########################################################
###########################################################

##############################################################################################
# Add the buttons on the Object window, when TextGrid + Sound + PitchTier files are selected #
##############################################################################################
Add action command: "Sound", 0, "TextGrid", 0, "PitchTier", 0, "PoLaR plugin", "", 0, ""

### for Drawings
Add action command: "Sound", 1, "TextGrid", 0, "PitchTier", 0, "Create Drawing for Sound+TextGrid ▾", "PoLaR plugin", 0, ""
Add action command: "Sound", 1, "TextGrid", 0, "PitchTier", 0, "Create picture (More Settings)", "Create Drawing for Sound+TextGrid ▾", 1, "praatScripts/PoLaR-Draw-Sound-and-TextGrid-Advanced.praat"
Add action command: "Sound", 1, "TextGrid", 0, "PitchTier", 0, "Create picture", "Create Drawing for Sound+TextGrid ▾", 1, "praatScripts/PoLaR-Draw-Sound-and-TextGrid-Quick.praat"

### for turning points
Add action command: "Sound", 0, "TextGrid", 0, "PitchTier", 0, "Assess PoLaR Turning Points ▾", "PoLaR plugin", 0, ""
Add action command: "Sound", 1, "TextGrid", 1, "PitchTier", 1, "Adjust Points audio/visually", "Assess PoLaR Turning Points ▾", 1, "praatScripts/PoLaR-Adjust-Points-in-Manipulation.praat"

### for script-generating labels
Add action command: "Sound", 0, "TextGrid", 0, "PitchTier", 0, "Generate PoLaR Labels ▾", "PoLaR plugin", 0, ""
Add action command: "Sound", 0, "TextGrid", 0, "PitchTier", 0, "New Pseudo Labels (Adv. labels req'd!)", "Generate PoLaR Labels ▾", 1, "praatScripts/PoLaR-to-pseudocategorical-Quick.praat"
Add action command: "Sound", 1, "TextGrid", 1, "PitchTier", 0, "New Levels Labels (More Settings)", "Generate PoLaR Labels ▾", 1, "praatScripts/PoLaR-Levels-labeller-Advanced.praat"
Add action command: "Sound", 1, "TextGrid", 1, "PitchTier", 0, "New Levels Labels", "Generate PoLaR Labels ▾", 1, "praatScripts/PoLaR-Levels-labeller-Quick.praat"
Add action command: "Sound", 1, "TextGrid", 1, "PitchTier", 1, "New Momel-based Points/Levels/Ranges (More Settings)", "Generate PoLaR Labels ▾", 1, "praatScripts/PoLaR-momel-labels.praat"
Add action command: "Sound", 1, "TextGrid", 1, "PitchTier", 1, "New Momel-based Points/Levels/Ranges", "Generate PoLaR Labels ▾", 1, "praatScripts/PoLaR-momel-labels-Quick.praat"

### for PoLaR TextGrids
Add action command: "Sound", 0, "TextGrid", 0, "PitchTier", 0, "Modify/Inspect PoLaR TextGrids ▾", "PoLaR plugin", 0, ""
Add action command: "Sound", 1, "TextGrid", 1, "PitchTier", 0, "Extract info from PoLaR tiers", "Modify/Inspect PoLaR TextGrids ▾", 1, "praatScripts/PoLaR-Extract-Info-to-TSV-Quick.praat"
Add action command: "Sound", 0, "TextGrid", 0, "PitchTier", 0, "Clear PoLaR tiers + Delete other tiers (CAUTION)", "Modify/Inspect PoLaR TextGrids ▾", 1, "praatScripts/PoLaR-TextGrid-Blanker.praat"
Add action command: "Sound", 0, "TextGrid", 0, "PitchTier", 0, "Clear PoLaR tiers", "Modify/Inspect PoLaR TextGrids ▾", 1, "praatScripts/PoLaR-TextGrid-Blank.praat"
Add action command: "Sound", 0, "TextGrid", 0, "PitchTier", 0, "Add Missing PoLaR Tiers", "Modify/Inspect PoLaR TextGrids ▾", 1, "praatScripts/PoLaR-TextGrid-Add-Missing.praat"


##################################################################################
# Add the buttons on the Object window, when TextGrid + Sound files are selected #
##################################################################################
Add action command: "Sound", 0, "TextGrid", 0, "", 0, "PoLaR plugin", "", 0, ""

### for Drawings
Add action command: "Sound", 0, "TextGrid", 0, "", 0, "Create Drawing for Sound+TextGrid ▾", "PoLaR plugin", 0, ""
Add action command: "Sound", 1, "TextGrid", 0, "", 0, "Create picture (More Settings)", "Create Drawing for Sound+TextGrid ▾", 1, "praatScripts/PoLaR-Draw-Sound-and-TextGrid-Advanced.praat"
Add action command: "Sound", 1, "TextGrid", 0, "", 0, "Create picture", "Create Drawing for Sound+TextGrid ▾", 1, "praatScripts/PoLaR-Draw-Sound-and-TextGrid-Quick.praat"

### for turning points
Add action command: "Sound", 1, "TextGrid", 1, "", 0, "Assess PoLaR Turning Points ▾", "PoLaR plugin", 0, ""
Add action command: "Sound", 1, "TextGrid", 1, "", 0, "Resynthesize Straight Line Approx. (More Settings)", "Assess PoLaR Turning Points ▾", 1, "praatScripts/PoLaR-resynthesize-SLA-Advanced.praat"
Add action command: "Sound", 1, "TextGrid", 1, "", 0, "Resynthesize Straight Line Approx.", "Assess PoLaR Turning Points ▾", 1, "praatScripts/PoLaR-resynthesize-SLA-Quick-Quiet.praat"
Add action command: "Sound", 1, "TextGrid", 1, "", 0, "Adjust Points audio/visually", "Assess PoLaR Turning Points ▾", 1, "praatScripts/PoLaR-Adjust-Points-in-Manipulation.praat"

### for script-generating labels
Add action command: "Sound", 0, "TextGrid", 0, "", 0, "Generate PoLaR Labels ▾", "PoLaR plugin", 0, ""
Add action command: "Sound", 0, "TextGrid", 0, "", 0, "New Pseudo Labels (Adv. labels req'd!)", "Generate PoLaR Labels ▾", 1, "praatScripts/PoLaR-to-pseudocategorical-Quick.praat"
Add action command: "Sound", 1, "TextGrid", 1, "", 0, "New Levels Labels (More Settings)", "Generate PoLaR Labels ▾", 1, "praatScripts/PoLaR-Levels-labeller-Advanced.praat"
Add action command: "Sound", 1, "TextGrid", 1, "", 0, "New Levels Labels", "Generate PoLaR Labels ▾", 1, "praatScripts/PoLaR-Levels-labeller-Quick.praat"
Add action command: "Sound", 1, "TextGrid", 1, "", 0, "New Momel-based Points/Levels/Ranges (More Settings)", "Generate PoLaR Labels ▾", 1, "praatScripts/PoLaR-momel-labels.praat"
Add action command: "Sound", 1, "TextGrid", 1, "", 0, "New Momel-based Points/Levels/Ranges", "Generate PoLaR Labels ▾", 1, "praatScripts/PoLaR-momel-labels-Quick.praat"

### for PoLaR TextGrids
Add action command: "Sound", 0, "TextGrid", 0, "", 0, "Modify/Inspect PoLaR TextGrids ▾", "PoLaR plugin", 0, ""
Add action command: "Sound", 1, "TextGrid", 1, "", 0, "Extract info from PoLaR tiers", "Modify/Inspect PoLaR TextGrids ▾", 1, "praatScripts/PoLaR-Extract-Info-to-TSV-Quick.praat"
Add action command: "Sound", 1, "TextGrid", 2, "", 0, "Consensus Helper (beta)", "Modify/Inspect PoLaR TextGrids ▾", 1, "praatScripts/PoLaR-Conensus-Helper.praat"
Add action command: "Sound", 0, "TextGrid", 0, "", 0, "Clear PoLaR tiers + Delete other tiers (CAUTION)", "Modify/Inspect PoLaR TextGrids ▾", 1, "praatScripts/PoLaR-TextGrid-Blanker.praat"
Add action command: "Sound", 0, "TextGrid", 0, "", 0, "Clear PoLaR tiers", "Modify/Inspect PoLaR TextGrids ▾", 1, "praatScripts/PoLaR-TextGrid-Blank.praat"
Add action command: "Sound", 0, "TextGrid", 0, "", 0, "Add Missing PoLaR Tiers", "Modify/Inspect PoLaR TextGrids ▾", 1, "praatScripts/PoLaR-TextGrid-Add-Missing.praat"


###############################################################################
# Add the buttons on the Object window, when just TextGrid files are selected #
###############################################################################
Add action command: "TextGrid", 0, "", 0, "", 0, "PoLaR plugin", "", 0, ""

### for adjusting labels in TextGrids
Add action command: "TextGrid", 0, "", 0, "", 0, "Modify/Inspect PoLaR TextGrids ▾", "PoLaR plugin", 0, ""
Add action command: "TextGrid", 0, "", 0, "", 0, "Clear PoLaR tiers + Delete other tiers (CAUTION)", "Modify/Inspect PoLaR TextGrids ▾", 1, "praatScripts/PoLaR-TextGrid-Blanker.praat"
Add action command: "TextGrid", 0, "", 0, "", 0, "Clear PoLaR tiers", "Modify/Inspect PoLaR TextGrids ▾", 1, "praatScripts/PoLaR-TextGrid-Blank.praat"
Add action command: "TextGrid", 0, "", 0, "", 0, "Add Missing PoLaR Tiers", "Modify/Inspect PoLaR TextGrids ▾", 1, "praatScripts/PoLaR-TextGrid-Add-Missing.praat"

### for script-generating labels
Add action command: "TextGrid", 0, "", 0, "", 0, "Generate PoLaR Labels ▾", "PoLaR plugin", 0, ""
Add action command: "TextGrid", 0, "", 0, "", 0, "Pseudo Labels (Adv. labels req'd!)", "Generate PoLaR Labels ▾", 1, "praatScripts/PoLaR-to-pseudocategorical-Quick.praat"


############################################################################
# Add the buttons on the Object window, when just Sound files are selected #
############################################################################
Add action command: "Sound", 0, "", 0, "", 0, "PoLaR plugin", "", 0, ""

### for Drawings
Add action command: "Sound", 1, "", 0, "", 0, "Create Drawing for Sound ▾", "PoLaR plugin", 0, ""
Add action command: "Sound", 1, "", 0, "", 0, "Create picture (More Settings)", "Create Drawing for Sound ▾", 1, "praatScripts/PoLaR-Draw-Sound-and-TextGrid-Advanced.praat"
Add action command: "Sound", 1, "", 0, "", 0, "Create picture", "Create Drawing for Sound ▾", 1, "praatScripts/PoLaR-Draw-Sound-and-TextGrid-Quick.praat"

### for TextGrids
Add action command: "Sound", 0, "", 0, "", 0, "New PoLaR TextGrid for Sound(s) ▾", "PoLaR plugin", 0, ""
Add action command: "Sound", 0, "", 0, "", 0, "New TextGrid with Momel-based labels", "New PoLaR TextGrid for Sound(s) ▾", 1, "praatScripts/PoLaR-momel-labels-Sound.praat"
Add action command: "Sound", 0, "", 0, "", 0, "New Blank PoLaR TextGrid(s)", "New PoLaR TextGrid for Sound(s) ▾", 1, "praatScripts/PoLaR-TextGrid-for-Sound.praat"



##############################################################
##############################################################
################  FILE/PRAAT  MENU  COMMANDS  ################
##############################################################
##############################################################

###############################################
# Add the menu commands to the Objects window #
###############################################
Add menu command: "Objects", "New", "--PoLaR plugin--", "", 0, ""
Add menu command: "Objects", "New", "PoLaR plugin", "PoLaR plugin", 0, ""
Add menu command: "Objects", "New", "Extract PoLaR info from files in a directory", "PoLaR plugin", 1, "praatScripts/PoLaR-Extract-Info-to-TSV-Dir.praat"
Add menu command: "Objects", "New", "Add Missing PoLaR Tiers to files in a directory", "PoLaR plugin", 1, "praatScripts/PoLaR-TextGrid-Add-Missing-Dir.praat"
Add menu command: "Objects", "New", "Label the Levels tier for files in a directory", "PoLaR plugin", 1, "praatScripts/PoLaR-Levels-labeller-Dir.praat"
Add menu command: "Objects", "New", "Label the Pseudo tier for files in a directory", "PoLaR plugin", 1, "praatScripts/PoLaR-to-pseudocategorical-Dir.praat"
Add menu command: "Objects", "New", "New Momel-based labels for files in a directory", "PoLaR plugin", 1, "praatScripts/PoLaR-momel-labels-Dir.praat"
Add menu command: "Objects", "New", "Adjust Points audio/visually for files in a directory", "PoLaR plugin", 1, "praatScripts/PoLaR-Adjust-Points-in-Manipulation-Dir.praat"
Add menu command: "Objects", "New", "Create pictures for files in a directory", "PoLaR plugin", 1, "praatScripts/PoLaR-Draw-Sound-and-TextGrid-Dir.praat"


Add action command: "Sound", 0, "", 0, "", 0, "Save as .wav (multiple selected objects)", "", 0, "praatScripts/Save-multiple-Sounds-Textgrids.praat"
Add action command: "TextGrid", 0, "", 0, "", 0, "Save as .Textgrid (multiple selected objects)", "", 0, "praatScripts/Save-multiple-Sounds-Textgrids.praat"
Add action command: "Sound", 0, "TextGrid", 0, "", 0, "Save as .wav/.Textgrid (multiple selected objects)", "", 0, "praatScripts/Save-multiple-Sounds-Textgrids.praat"


###############################################################
# Add the menu commands to the "Praat" menu                   #
# (in the menubar on Mac; in the Objects window on other OSs) #
###############################################################
Add menu command: "Objects", "Praat", "-- PoLaR plugin --", "", 0, ""
Add menu command: "Objects", "Praat", "PoLaR plugin",  "", 0, ""
Add menu command: "Objects", "Praat", "Extract PoLaR info from files in a directory", "PoLaR plugin", 1, "praatScripts/PoLaR-Extract-Info-to-TSV-Dir.praat"
Add menu command: "Objects", "Praat", "Add Missing PoLaR Tiers to files in a directory", "PoLaR plugin", 1, "praatScripts/PoLaR-TextGrid-Add-Missing-Dir.praat"
Add menu command: "Objects", "Praat", "Label the Levels tier for files in a directory", "PoLaR plugin", 1, "praatScripts/PoLaR-Levels-labeller-Dir.praat"
Add menu command: "Objects", "Praat", "Label the Pseudo tier for files in a directory", "PoLaR plugin", 1, "praatScripts/PoLaR-to-pseudocategorical-Dir.praat"
Add menu command: "Objects", "Praat", "New Momel-based labels for files in a directory", "PoLaR plugin", 1, "praatScripts/PoLaR-momel-labels-Dir.praat"
Add menu command: "Objects", "Praat", "Adjust Points audio/visually for files in a directory", "PoLaR plugin", 1, "praatScripts/PoLaR-Adjust-Points-in-Manipulation-Dir.praat"
Add menu command: "Objects", "Praat", "Create pictures for files in a directory", "PoLaR plugin", 1, "praatScripts/PoLaR-Draw-Sound-and-TextGrid-Dir.praat"

Add menu command: "Objects", "Praat", "-- --", "PoLaR plugin", 0, ""
Add menu command: "Objects", "Praat", "View & Edit", "", 0, "praatScripts/ViewAndEdit.praat"