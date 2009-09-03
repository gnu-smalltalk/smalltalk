UndoableCommand subclass: AddNamespaceCommand [

    execute [
	<category: 'command'>

	| dlg |
	target hasSelectedNamespace ifFalse: [ ^ self ].
        dlg := GtkEntryDialog title: 'Add a namespace' text: 'Name of the new namespace'.
        dlg hasPressedOk ifTrue: [ 
            self push: (AddNamespaceUndoCommand add: dlg result asSymbol to: target selectedNamespace) ]
    ]
]

