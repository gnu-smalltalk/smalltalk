UndoableCommand subclass: RenameCategoryCommand [

    execute [
	<category: 'command'>

	| dlg |
	target hasSelectedCategory ifFalse: [ ^ self ].
        dlg := GtkEntryDialog title: 'Rename a category' text: 'Name of the category'.
        dlg hasPressedOk ifTrue: [
            self push: (RenameCategoryUndoCommand rename: target selectedCategory in: target classOrMetaSelected as: dlg result onModel: target viewedCategoryModel) ]
    ]
]

