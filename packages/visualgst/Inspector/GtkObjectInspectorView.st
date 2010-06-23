Object subclass: GtkObjectInspectorView [
    | object model |

    GtkObjectInspectorView class >> openOn: anObject [
	<category: 'instance creation'>

	^ (super new)
	    object: anObject;
	    yourself
    ]

    object [
	<category: 'accessing'>
	
	^ object
    ]

    object: anObject [
	<category: 'accessing'>

	object := anObject.
    ]

    do: aBlock [ 
	<category: 'iterating'>

	aBlock value: 'self'.
        self object class allInstVarNames do: aBlock
    ]

    values [
	<category: 'accessing'>

	^Array streamContents: [:s | self do: [:value | s nextPut: value]]
    ]

    selectedValue: aString [
	<category: 'item selection'>

	| iter string instVar |
        ^ aString = 'self'
            ifTrue: [ self object ]
            ifFalse: [ self object
			instVarNamed: aString ]
    ]

    canDive [
	<category: 'testing'>

	^ true
    ]
]

