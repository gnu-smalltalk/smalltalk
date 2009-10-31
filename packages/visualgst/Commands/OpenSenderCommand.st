Command subclass: OpenSenderCommand [

    execute [
        <category: 'command'>

	target isNil
	    ifTrue: [ GtkSender open ]
	    ifFalse: [ GtkSender openOn: target selectedMethodSymbol ]
    ]
]

