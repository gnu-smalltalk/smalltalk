GtkObjectInspectorView subclass: GtkSetInspectorView [

    do: aBlock [
	<category: 'accessing'>

	super do: aBlock.
        self object do: aBlock
    ]

    selectedValue: anObject [
        <category: 'events'>

        ^ (self object includes: anObject)
            ifFalse: [ super selectedValue: anObject ]
            ifTrue: [ anObject ]
    ]
]

