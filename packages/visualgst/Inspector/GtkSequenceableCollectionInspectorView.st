GtkObjectInspectorView subclass: GtkSequenceableCollectionInspectorView [

    refreshModel [
	<category: 'events'>
 
	| i | 
	super refreshModel. 
	i := 1.
	self object do: [ :each |
	    self appendVariable: i displayString.
	    i := i + 1 ]
    ]

    selectedValue: aString [
	<category: 'events'>

	^ aString asNumber = 0 
	    ifTrue: [ super selectedValue: aString ]
	    ifFalse: [ self object at: aString asNumber ]
    ]
]

