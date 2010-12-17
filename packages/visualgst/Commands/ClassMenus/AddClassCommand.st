NamespaceCommand subclass: AddClassCommand [

    item [

	^ 'Add a class'
    ]

    execute [
	<category: 'command'>

	| dlg superclass |
	superclass := target state hasSelectedClass
            ifTrue: [ target state classOrMeta ]
            ifFalse: [ Object ].
        dlg := GtkEntryDialog title: 'Add a class' text: 'Name of the new class'.
        dlg hasPressedOk: [
            (AddClassUndoCommand
                add: dlg result asSymbol
                to: target state namespace
                classCategory: target state classCategory
                withSuperclass: superclass) push ]
    ]
]

