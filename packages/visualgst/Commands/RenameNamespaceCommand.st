NamespaceCommand subclass: RenameNamespaceCommand [

    execute [
	<category: 'command'>

	| dlg |
        dlg := GtkEntryDialog title: 'Rename a namespace' text: 'Name of the new namespace'.
        dlg hasPressedOk ifTrue: [ 
            (RenameNamespaceUndoCommand rename: target selectedNamespace as: dlg result asSymbol) push ]
    ]
]

