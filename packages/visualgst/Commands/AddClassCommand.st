UndoableCommand subclass: AddClassCommand [

    execute [
	<category: 'command'>

	| dlg superclass |
	target hasSelectedClass
            ifTrue: [ superclass := target selectedClass ]
            ifFalse: [ superclass := Object ].
        dlg := GtkEntryDialog title: 'Add a class' text: 'Name of the new class'.
        dlg hasPressedOk ifTrue: [
            self push: (AddClassUndoCommand add: dlg result asSymbol to: target selectedNamespace withSuperclass: superclass) ]
    ]
]

