GtkObjectInspectorView subclass: GtkSequenceableCollectionInspectorView [

    values [
	| i |
	i := OrderedCollection new.
	1 to: self object size do: [ :j | i add: j ].
	^ super values, i
    ]

    selectedValue: aString [
	<category: 'events'>

	^ aString asNumber = 0 
	    ifTrue: [ super selectedValue: aString ]
	    ifFalse: [ self object at: aString asNumber ]
    ]
]

