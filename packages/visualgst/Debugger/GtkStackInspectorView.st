GtkConcreteWidget subclass: GtkStackInspectorView [
    | object variables |

    GtkStackInspectorView class >> openOn: aContext [
	<category: 'instance creation'>

	^ (super new)
	    object: aContext;
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

	| i |
        variables := Dictionary new.
        i := 1.
	aBlock value: 'thisContext'.
        self object variablesDo: [ :each |
                variables at: each displayString put: i.
		aBlock value: each displayString.
                i := i + 1 ].
    ]

    selectedValue: aString [
	<category: 'item selection'>

        ^ aString = 'thisContext'
            ifTrue: [ self object ]
            ifFalse: [ self object at: (variables at: aString) ]
    ]

    canDive [
	<category: 'testing'>

	^ false
    ]
]

