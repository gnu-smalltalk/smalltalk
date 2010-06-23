GtkObjectInspectorView subclass: GtkIntegerInspectorView [

    do: aBlock [
	super do: aBlock.
        #('hexadecimal' 'octal' 'binary') do: aBlock
    ]

    selectedValue: aString [
        <category: 'item selection'>

        | base iter string instVar |
	base := 0.
        aString = 'hexadecimal' ifTrue: [ base := 16 ].
        aString = 'octal' ifTrue: [ base := 8 ].
        aString = 'binary' ifTrue: [ base := 2 ].
        ^ base = 0 
	    ifTrue: [ super selectedValue: aString ]
	    ifFalse: [ self object printString: base ]
    ]

    canDive [
        <category: 'testing'>

        ^ false
    ]
]

