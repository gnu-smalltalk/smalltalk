Command subclass: UndoableCommand [
    UndoableCommand class [ | UndoStack | ]

    UndoableCommand class >> undoStack [
	<category: 'accessing'>

	^ UndoStack ifNil: [ UndoStack := GtkClassBrowserWidget undoStack ]
    ]

    undoStack [
	<category: 'accessing'>

	^ self class undoStack 
    ]

    push: anUndoCommand [
	<category: 'accessing'>

	anUndoCommand precondition ifFalse: [ ^ anUndoCommand displayError ].
	self undoStack push: anUndoCommand
    ]
]

