"=====================================================================
|
|   ROE extensions to the base classes
|
|
 ======================================================================"

"======================================================================
|
| This file is in the public domain.
|
 ======================================================================"

Collection extend [
    intersection: aCollection [
	| s |
	(self species == aCollection species
	     and: [ self size > aCollection size ])
		ifTrue: [ ^aCollection intersection: self ].

	s := aCollection asSet.
	^self select: [ :each | s includes: each ]
    ]
]
