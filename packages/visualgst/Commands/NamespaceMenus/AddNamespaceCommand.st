NamespaceCommand subclass: AddNamespaceCommand [

    item [

	^ 'Add a namespace'
    ]

    execute [
	<category: 'command'>

	| dlg |
        dlg := GtkEntryDialog title: 'Add a namespace' text: 'Name of the new namespace'.
        dlg hasPressedOk: [ 
            (AddNamespaceUndoCommand add: dlg result asSymbol to: target state namespace) push ]
    ]
]

