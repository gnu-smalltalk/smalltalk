UndoCommand subclass: DeleteMethodUndoCommand [

    | selector classOrMeta compiledMethod |

    DeleteMethodUndoCommand class >> delete: aSymbol in: aClass [
	<category: 'instance creation'>

	^ (self new)
	    delete: aSymbol in: aClass;
	    "precondition;"
	    yourself
    ]

    delete: aSymbol in: aClass [
	<category: 'initialize'>

	selector := aSymbol.
	classOrMeta := aClass.
    ]

    description [
	<category: 'accessing'>

	^ 'Delete a method'
    ]

    precondition [
        <category: 'checking'>

	^ true
    ]

    undo [
	<category: 'events'>

	classOrMeta methodDictionary insertMethod: compiledMethod.
    ]

    redo [
	<category: 'events'>

	compiledMethod := classOrMeta >> selector.
	classOrMeta methodDictionary removeMethod: compiledMethod.
    ]
]

