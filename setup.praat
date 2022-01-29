####################################################
# PoLaR plugin for Praat                           #
# v.2021.11.15
#                                                  #
# Refer to the documentation in README-FIRST.txt   #
#                                                  #
####################################################

# Set the write settings to UTF-8 and read settings too
Text writing preferences: "UTF-8"
Text reading preferences: "try UTF-8, then ISO Latin-1"

####################################################
# Add the menu commands within the TextGrid editor #
####################################################
Add menu command: "TextGridEditor", "Tier", "PoLaR: Standard view settings", "", 1, "praatScripts/PoLaR-Adjust-Editor-View-Standard.praat"
Add menu command: "TextGridEditor", "Tier", "PoLaR: Sensitive view settings", "", 1, "praatScripts/PoLaR-Adjust-Editor-View-Sensitive.praat"
Add menu command: "TextGridEditor", "Tier", "PoLaR: Resynthesize Straight Line Approximation", "", 0, "praatScripts/PoLaR-resynthesize-SLA-from-TGE.praat"
Add menu command: "TextGridEditor", "Tier", "PoLaR: Levels Labels", "", 0, "praatScripts/PoLaR-Levels-labeller-from-TGE.praat"
Add menu command: "TextGridEditor", "Tier", "PoLaR: Extract info from PoLaR tiers", "", 0, "praatScripts/PoLaR-Extract-Info-to-TSV-from-TGE.praat"
Add menu command: "TextGridEditor", "Tier", "PoLaR: Pseudo Labels (Advanced labels req'd!)", "", 0, "praatScripts/PoLaR-to-pseudocategorical-from-TGE.praat"
Add menu command: "TextGridEditor", "Tier", "PoLaR: Create picture (default settings)", "", 0, "praatScripts/PoLaR-Draw-Sound-and-TextGrid-from-TGE.praat"
Add menu command: "TextGridEditor", "Tier", "PoLaR: Create picture (advanced)", "", 0, "praatScripts/PoLaR-Draw-Sound-and-TextGrid-from-TGE-Adv.praat"

##################################################################################
# Add the buttons on the Object window, when TextGrid + Sound files are selected #
##################################################################################
Add action command: "Sound", 1, "TextGrid", 1, "", 0, "PoLaR scripts", "", 0, ""

### for Drawings
Add action command: "Sound", 0, "TextGrid", 0, "", 0, "Draw Sound and TextGrid ▾", "PoLaR scripts", 0, ""
Add action command: "Sound", 0, "TextGrid", 0, "", 0, "Manually configure settings (advanced)", "Draw Sound and TextGrid ▾", 1, "praatScripts/PoLaR-Draw-Sound-and-TextGrid-Advanced.praat"
Add action command: "Sound", 0, "TextGrid", 0, "", 0, "Create picture with default settings", "Draw Sound and TextGrid ▾", 1, "praatScripts/PoLaR-Draw-Sound-and-TextGrid-Quick.praat"

### for SLAs
Add action command: "Sound", 1, "TextGrid", 1, "", 0, "PoLaR Straight Line Approx. ▾", "PoLaR scripts", 0, ""
Add action command: "Sound", 1, "TextGrid", 1, "", 0, "PoLaR SLA (Advanced)", "PoLaR Straight Line Approx. ▾", 1, "praatScripts/PoLaR-resynthesize-SLA-Advanced.praat"
Add action command: "Sound", 1, "TextGrid", 1, "", 0, "PoLaR SLA (Quick)", "PoLaR Straight Line Approx. ▾", 1, "praatScripts/PoLaR-resynthesize-SLA-Quick.praat"
Add action command: "Sound", 1, "TextGrid", 1, "", 0, "PoLaR SLA (Quick+Quiet)", "PoLaR Straight Line Approx. ▾", 1, "praatScripts/PoLaR-resynthesize-SLA-Quick-Quiet.praat"

### for PoLaR labels
Add action command: "Sound", 1, "TextGrid", 1, "", 0, "PoLaR TextGrids ▾", "PoLaR scripts", 0, ""
Add action command: "Sound", 0, "TextGrid", 0, "", 0, "Only Blank PoLaR tiers (DANGER)", "PoLaR TextGrids ▾", 1, "praatScripts/PoLaR-TextGrid-Blanker.praat"
Add action command: "Sound", 0, "TextGrid", 0, "", 0, "Blank PoLaR tiers", "PoLaR TextGrids ▾", 1, "praatScripts/PoLaR-TextGrid-Blank.praat"
Add action command: "Sound", 1, "TextGrid", 1, "", 0, "Pseudo Labels (Adv. labels req'd!)", "PoLaR TextGrids ▾", 1, "praatScripts/PoLaR-to-pseudocategorical-Quick.praat"
Add action command: "Sound", 1, "TextGrid", 1, "", 0, "Levels Labels (Advanced)", "PoLaR TextGrids ▾", 1, "praatScripts/PoLaR-Levels-labeller-Advanced.praat"
Add action command: "Sound", 1, "TextGrid", 1, "", 0, "Levels Labels (Quick)", "PoLaR TextGrids ▾", 1, "praatScripts/PoLaR-Levels-labeller-Quick.praat"
Add action command: "Sound", 1, "TextGrid", 1, "", 0, "Extract info from PoLaR tiers", "PoLaR TextGrids ▾", 1, "praatScripts/PoLaR-Extract-Info-to-TSV-Quick.praat"


###############################################################################
# Add the buttons on the Object window, when just TextGrid files are selected #
###############################################################################
Add action command: "TextGrid", 0, "", 0, "", 0, "PoLaR scripts", "", 0, ""

### for Advanced-to-Basic
Add action command: "TextGrid", 0, "", 0, "", 0, "PoLaR TextGrids ▾", "PoLaR scripts", 0, ""
Add action command: "TextGrid", 0, "", 0, "", 0, "Pseudo Labels (Adv. labels req'd!)", "PoLaR TextGrids ▾", 1, "praatScripts/PoLaR-to-pseudocategorical-Quick.praat"
Add action command: "TextGrid", 0, "", 0, "", 0, "Only Blank PoLaR tiers (DANGER)", "PoLaR TextGrids ▾", 1, "praatScripts/PoLaR-TextGrid-Blanker.praat"
Add action command: "TextGrid", 0, "", 0, "", 0, "Blank PoLaR tiers", "PoLaR TextGrids ▾", 1, "praatScripts/PoLaR-TextGrid-Blank.praat"


############################################################################
# Add the buttons on the Object window, when just Sound files are selected #
############################################################################
Add action command: "Sound", 0, "", 0, "", 0, "PoLaR scripts", "", 0, ""

### for Drawings
Add action command: "Sound", 1, "", 0, "", 0, "Draw Sound ▾", "PoLaR scripts", 0, ""
Add action command: "Sound", 1, "", 0, "", 0, "Create picture with default settings", "Draw Sound and TextGrid ▾", 1, "praatScripts/PoLaR-Draw-Sound-and-TextGrid-Quick.praat"
Add action command: "Sound", 1, "", 0, "", 0, "Manually configure settings (advanced)", "Draw Sound and TextGrid ▾", 1, "praatScripts/PoLaR-Draw-Sound-and-TextGrid-Advanced.praat"


###############################################
# Add the menu commands to the Objects window #
###############################################
Add menu command: "Objects", "New", "-- PoLaR --", "Strings", 0, ""
Add menu command: "Objects", "New", "PoLaR: Extract PoLaR info from files in a directory", "", 1, "praatScripts/PoLaR-Extract-Info-to-TSV-Dir.praat"
Add menu command: "Objects", "New", "PoLaR: Label the Levels tier for files in a directory", "", 1, "praatScripts/PoLaR-Levels-labeller-Dir.praat"
Add menu command: "Objects", "New", "PoLaR: Label the Pseudo tier for files in a directory", "", 1, "praatScripts/PoLaR-to-pseudocategorical-Dir.praat"
Add action command: "Sound", 0, "", 0, "", 0, "Save as .wav (multiple selected objects)", "", 0, "praatScripts/Save-multiple-Sounds-Textgrids.praat"
Add action command: "TextGrid", 0, "", 0, "", 0, "Save as .Textgrid (multiple selected objects)", "", 0, "praatScripts/Save-multiple-Sounds-Textgrids.praat"
Add action command: "Sound", 0, "TextGrid", 0, "", 0, "Save as .wav/.Textgrid (multiple selected objects)", "", 0, "praatScripts/Save-multiple-Sounds-Textgrids.praat"