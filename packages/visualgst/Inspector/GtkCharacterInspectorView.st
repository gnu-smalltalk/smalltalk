GtkObjectInspectorView subclass: GtkCharacterInspectorView [

    values [
	^ super values, #('hexadecimal' 'octal' 'binary')
    ]

    selectedValue: aString [
	<category: 'events'>

	| base |
	base := 0.
	aString = 'hexadecimal' ifTrue: [ base := 16 ].
	aString = 'octal' ifTrue: [ base := 8 ].
	aString = 'binary' ifTrue: [ base := 2 ].
	^ base = 0 
	    ifTrue: [ super selectedValue: aString ]
	    ifFalse: [ self object asInteger printString: base ]
    ]

    canDive [
        <category: 'testing'>

        ^ false
    ]
]

