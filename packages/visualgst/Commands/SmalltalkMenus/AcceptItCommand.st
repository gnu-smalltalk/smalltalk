Command subclass: AcceptItCommand [

    item [
        <category: 'menu item'>

        ^ 'Accept It'
    ]

    accel [
        <category: 'menu item'>

	^ '<Control>S'
    ]

    stockIcon [

        ^ 'gtk-apply'
    ]

    acceptClassDefinitionOn: aNamespace [
        <category: 'class event'>

        Namespace current: aNamespace.
        "TODO: show errors as in AddMethodUndoCommand."
        target 
	    codeSaved;
	    clearUndo.
        STInST.STEvaluationDriver new
		    parseSmalltalkStream: (ReadStream on: target sourceCode) with: STInST.GSTFileInParser
    ]

    acceptClassDefinition [
        <category: 'class event'>

        ^ self acceptClassDefinitionOn: target state namespace
    ]

    execute [
	<category: 'command'>

        target state hasSelectedCategory ifFalse: [ ^ self acceptClassDefinition ].
        (AddMethodUndoCommand
	    add: target sourceCode
	    classified: target state category 
	    in: target state classOrMeta
	    browser: target) push
    ]
]

