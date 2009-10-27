UndoableCommand subclass: AddCategoryCommand [

    execute [
	<category: 'command'>

	| dlg |
        dlg := GtkEntryDialog title: 'Add a category' text: 'Name of the category'.
        dlg hasPressedOk ifTrue: [ 
            self push: (AddCategoryUndoCommand add: dlg result onWidget: target viewedCategoryWidget) ]

    ]
]

