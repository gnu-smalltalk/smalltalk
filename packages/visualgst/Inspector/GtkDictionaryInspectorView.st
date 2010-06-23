GtkObjectInspectorView subclass: GtkDictionaryInspectorView [

    do: aBlock [
	<category: 'accessing'>

	super do: aBlock.
        self object keys do: aBlock
    ]

    selectedValue: anObject [
        <category: 'events'>

        ^ (self object includesKey: anObject)
            ifFalse: [ super selectedValue: anObject ]
            ifTrue: [ self object at: anObject ]
    ]
]

