wrongSel$ = "Select EITHER a single file OR two files that can viewed together"

numSel = numberOfSelected ()

if numSel = 1
	View & Edit
elsif numSel = 2
	numS = numberOfSelected ("Sound")
	numT = numberOfSelected ("TextGrid")
	if (numS = 1) and (numT = 1)
		View & Edit
	else
		exitScript: wrongSel$
	endif
else
	exitScript: wrongSel$
endif