GtkMethodModel subclass: GtkMethodSUnitModel [

    appendMethod: aString [
        <category: 'model builder'>

	(aString matchRegex: 'test' from: 1 to: 4) 
	    ifTrue: [ super appendMethod: aString ]
    ]
]

