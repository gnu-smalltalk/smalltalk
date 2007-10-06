ByteArray extend [

    asInteger [
	<category: 'accessing'>
	| shiftAmount anInteger |
	shiftAmount := 0.
	anInteger := 0.
	1 to: self size
	    do: 
		[:index | 
		anInteger := anInteger bitOr: ((self at: index) bitShift: shiftAmount).
		shiftAmount := shiftAmount + 8].
	^anInteger
    ]

    asByteString [
	<category: 'accessing'>
	| stream |
	stream := WriteStream on: String new.
	1 to: self size
	    do: [:x | stream nextPut: (Character value: (self basicAt: x))].
	^stream contents
    ]

]

