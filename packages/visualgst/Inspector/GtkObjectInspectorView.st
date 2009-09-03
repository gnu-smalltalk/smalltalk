GtkConcreteWidget subclass: GtkObjectInspectorView [
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
	self refreshModel
    ]

    model [
	<category: 'accessing'>

	^ model ifNil: [
	    model := GTK.GtkListStore new: 1 varargs: {GTK.GValue gTypeString} ]
    ]

    clearModel [
        <category: 'accessing'>

        self model clear
    ]

    refreshModel [
	<category: 'events'>
   
	self clearModel.
	self appendVariable: 'self'.
	self object class allInstVarNames do: [ :each |
		self appendVariable: each displayString ]
    ]

    appendVariable: aString [
        <category: 'model builder'>

	self model appendItem: {aString}
    ]

    selectedValue: aString [
	<category: 'item selection'>

	| iter string instVar |
        ^ aString = 'self'
            ifTrue: [ self object ]
            ifFalse: [ self object
			instVarNamed: (aString copyFrom: 2 to: aString size) ]
    ]

    canDive [
	<category: 'testing'>

	^ true
    ]
]

