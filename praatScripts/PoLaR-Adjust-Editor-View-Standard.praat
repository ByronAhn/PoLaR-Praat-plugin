################################################################
###
### PoLaR-Adjust-Editor-View-Standard
### v.2023.11.20
###
###
### The values used here are those suggested in the PoLaR
### guidelines
### 
###
###	Byron Ahn (bta@princeton.edu)
###	Attribution-ShareAlike 2.5 license
###
################################################################


################################################################
# Standard PoLaR values below
################################################################
f0MinAnalysis = 65
f0MaxAnalysis = 500
time_step = 0.0025
number_of_candidates = 15
very_accurate = 1
silence_threshold = 0.03
voicing_threshold = 0.5
octave_cost = 0.05
octave_jump_cost = 0.5
voice_unvoiced_cost = 0.2
attenuation_at_ceiling = 0.03

@mainAdjust

include PoLaR-Adjust-Editor-View-CORE.praat

################################################################
###  
### end of PoLaR-Adjust-Editor-View-Standard
### 
################################################################