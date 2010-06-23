GtkObjectInspectorView subclass: GtkFloatInspectorView [

    do: aBlock [
	super do: aBlock.
	1 to: self object size do: [ :each | aBlock value: each ]
    ]

    selectedValue: aString [
	<category: 'events'>

        ^ aString asNumber = 0
            ifTrue: [  super onVariableChanged ]
            ifFalse: [ self object at: aString asNumber ]
    ]
]

