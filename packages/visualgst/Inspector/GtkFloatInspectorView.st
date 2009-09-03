GtkObjectInspectorView subclass: GtkFloatInspectorView [

    refreshModel [
	<category: 'events'>
 
	super refreshModel.
        1 to: self object size do: [ :i |
            self appendVariable: i displayString ] 
    ]

    selectedValue: aString [
	<category: 'events'>

        ^ aString asNumber = 0
            ifTrue: [  super onVariableChanged ]
            ifFalse: [ self object at: aString asNumber ]
    ]
]

