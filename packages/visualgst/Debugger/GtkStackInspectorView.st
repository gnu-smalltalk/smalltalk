GtkConcreteWidget subclass: GtkStackInspectorView [
    | object model variables |

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
  
	| i | 
	self clearModel.
	variables := Dictionary new.
	i := 1.
	self appendVariable: 'thisContext'.
	self object variablesDo: [ :each |
		variables at: each displayString put: i.
		self appendVariable: each displayString.
		i := i + 1 ]
    ]

    appendVariable: aString [
        <category: 'model builder'>

	self model appendItem: {aString}
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

