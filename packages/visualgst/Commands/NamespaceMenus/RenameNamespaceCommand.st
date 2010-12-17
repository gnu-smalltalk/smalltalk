NamespaceCommand subclass: RenameNamespaceCommand [

    item [

	^ 'Rename a namespace'
    ]

    execute [
	<category: 'command'>

	| dlg |
        dlg := GtkEntryDialog title: 'Rename a namespace' text: 'Name of the new namespace'.
        dlg hasPressedOk: [ 
            (RenameNamespaceUndoCommand rename: target state namespace as: dlg result asSymbol) push ]
    ]
]

