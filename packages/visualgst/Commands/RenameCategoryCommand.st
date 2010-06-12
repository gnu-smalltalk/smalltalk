CategoryCommand subclass: RenameCategoryCommand [

    execute [
	<category: 'command'>

	| dlg |
        dlg := GtkEntryDialog title: 'Rename a category' text: 'Name of the category'.
        dlg hasPressedOk ifTrue: [
            (RenameCategoryUndoCommand rename: target selectedCategory in: target classOrMetaSelected as: dlg result onModel: target viewedCategoryModel) push ]
    ]
]

