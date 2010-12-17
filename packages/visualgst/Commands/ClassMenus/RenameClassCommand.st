ClassCommand subclass: RenameClassCommand [

    item [

	^ 'Rename a class'
    ]

    execute [
	<category: 'command'>

	| dlg |
        dlg := GtkEntryDialog title: 'Rename a class' text: 'Name of the class'.
        dlg hasPressedOk: [
            (RenameClassUndoCommand rename: target state classOrMeta as: dlg result asSymbol) push ]
    ]
]

