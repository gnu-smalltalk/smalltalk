NamespaceCommand subclass: AddClassCommand [

    execute [
	<category: 'command'>

	| dlg superclass |
	superclass := target hasSelectedClass
            ifTrue: [ target selectedClass ]
            ifFalse: [ Object ].
        dlg := GtkEntryDialog title: 'Add a class' text: 'Name of the new class'.
        dlg hasPressedOk: [
            (AddClassUndoCommand add: dlg result asSymbol to: target selectedNamespace withSuperclass: superclass) push ]
    ]
]

