# Important Note
This script won’t tell you all the things you need to discuss.

Users must bring a critical eye to the TextGrid output of this script!

# Words/Phones

* Nothing is changed automatically, but alert the labellers of the differences
* include two Words/Phones tiers where there are differences
* flag it on the DISCUSS tier if…
	- the words/phones tiers are different in their content
	- the word/phone boundaries are different

# PrStr

* combine all PrStr labels from both labellers
	- if a PrStr label is only in one labeller’s file, mark this on the DISCUSS tier
* when there is a label at the exact same time in both files
	- if they have the same label…
		* obviously just add one of them
	- else if labels differ in uncertainty (e.g., ?* vs *)
		* add the certain one
	- else if one label is more highly specified than another (e.g., ** vs *, and ]#ip vs ])
		* add the more highly specified one
	- else if they differ in any other way
		* add both labels (X and Y) to the same point as “X –vs– Y”
		* flag it on the DISCUSS tier
* if two consecutive PrStr labels are identical and they occur  within the same Phone interval
	- delete one
	- mark it on the DISCUSS tier

# Points

* when there is a Points label in both files within 20 ms of one another
	- if they have the same label…
		* add just one of them (randomly)
		* mark on the deleted one on the DISCUSS tier
	- if they have different labels…
		* create a new label by first determining the (i) core label, (ii) comma label, (iii) timing
		* the core label comes from the most specified core label 
			- if one is advanced and the other isn’t, use the advanced one (e.g., for *< vs 0, use *<)
			- if neither is advanced, it’s “0”
			- if they’re both advanced, use the one that has the most detail  (e.g., for *<#CF vs *<, use *<#CF)
				* if this isn’t automatically resolvable, flag it for the user
		* specify a comma override if at least one of two labels has one
			- straightforward if only one of the two has a comma label: using that existing comma override is better than not (logic: more highly specified labels are better than less specified ones)
			- if they both have a comma override…
				* if their difference in value ≤ 10Hz
					- average them and use that
				* else if their difference in value > 10Hz:
					- give labeller guidance to go to sensitive view and measure f0; go with the comma override that’s closer to that value (if it looks reliable)
		* the timing by default comes from the the most specified core label
			- but if there is a comma override, the timing comes from the label with the comma override
				* if they both have comma overrides put it at the midpoint between them
* some guidance to be added somewhere??
	- “you need to have a discussion. can’t be automated. listening required.”
	- guidance: lean in direction of using more detailed label
	- guidance: if the Points is a 0, maybe the difference is not so important anyway! 
	- guidance: if one uses ghost points, consider going with the non-ghost-point?
	- guidance: if the labels are slightly different, but one set gets you closer to the extremes of a f0 movement, go with that one
	- guidance: when comparing appropriate timing and value for comma overrides, compare sensitive and non-sensitive view


|                 | A comma; B no-comma           | A no-comma; B comma           | both comma                  | neither comma      |
| --------------: | :---------------------------: | :---------------------------: | :-------------------------: | :----------------: |
| **A adv; B 0**  | only A                        | A’s adv; B’s timing/comma     | compare commas; A’s adv     | only A             |
| **A 0; B adv**  | A’s timing/comma; B’s adv     | only B                        | compare commas; B’s adv     | only B             |
| **both adv**    | A’s timing/comma; compare adv | B’s timing/comma; compare adv | compare commas; compare adv | compare adv        |
| **neither adv** | only A                        | only B                        | compare commas              | (subcase of A = B) |


# Ranges

* if two of the three conditions are met:
	- different range min
	- different range max
	- different number of ranges
* …then output should have 2 ranges tiers + 2 levels tiers
	- levels1, ranges1, levels2, ranges2
	- labeller is flagged about ranges
* OTHERWISE:
* if ranges are co-timed but have different labels
	- if one uses () and the other doesn’t: encourage discussion
		* guidance: are there other cues to a phrase boundary? if so, consider using the non-() version, because this might be phrase-induced pitch reset
	- if Levels labels are identical: go with the narrower Range (i.e. the one that has a smaller max-min value)
	- if Levels labels are different: XXXXX
* more ranges = better… if it makes a difference on Levels associated with *s
	- if no effect on Levels: fewer is better
* analytic maxim: L=> 1, H=> 5, adjust ranges as appropriate
	- at the end of the process: check that all Range intervals have a 1 and 5, and if not, warn the user

# Discussions

* declination doesn’t necessarily mean new range, but downstep does!
	- declination often leads to uncertainty of whether there should be a new Range or not. when in doubt: add the extra Range, to ensure that all the phonologically high targets map onto Levels values of 4 or 5.
* what does IPO say for comparing points?