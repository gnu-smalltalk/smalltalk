GtkObjectInspectorView subclass: GtkIntegerInspectorView [

    refreshModel [
	<category: 'events'>
 
	super refreshModel. 
	self 
	    appendVariable: 'hexadecimal';
	    appendVariable: 'octal';
	    appendVariable: 'binary'
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

