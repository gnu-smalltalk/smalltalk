CategoryCommand subclass: RenameCategoryCommand [

    item [

	^ 'Rename a category'
    ]

    execute [
	<category: 'command'>

	| dlg |
        dlg := GtkEntryDialog title: 'Rename a category' text: 'Name of the category'.
        dlg hasPressedOk: [
            (RenameCategoryUndoCommand rename: target state category in: target state classOrMeta as: dlg result onModel: target viewedCategoryModel) push ]
    ]
]

