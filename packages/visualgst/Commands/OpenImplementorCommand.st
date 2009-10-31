Command subclass: OpenImplementorCommand [

    execute [
        <category: 'command'>

	target isNil
	    ifTrue: [ GtkImplementor open ]
	    ifFalse: [ GtkImplementor openOn: target selectedMethodSymbol ]
    ]
]

