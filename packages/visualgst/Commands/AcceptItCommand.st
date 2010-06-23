ClassCommand subclass: AcceptItCommand [

    acceptClassDefinitionOn: aNamespace [
        <category: 'class event'>

        Namespace current: aNamespace.
        "TODO: show errors as in AddMethodUndoCommand."
        STInST.STEvaluationDriver new
             parseSmalltalkStream: (ReadStream on: target sourceCode)
             with: STInST.GSTFileInParser.
        target codeSaved; clearUndo
    ]

    acceptClassDefinition [
        <category: 'class event'>

        ^ self acceptClassDefinitionOn: target state namespace
    ]

    execute [
	<category: 'command'>

        target state hasSelectedCategory ifFalse: [^self acceptClassDefinition].
        (AddMethodUndoCommand
	    add: target sourceCode
	    classified: target state category 
	    in: target state classOrMeta
	    browser: target) push
    ]
]

