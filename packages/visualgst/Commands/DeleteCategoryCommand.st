UndoableCommand subclass: DeleteCategoryCommand [

    execute [
	<category: 'command'>

	target hasSelectedCategory ifFalse: [ ^ self ].
        self push: (DeleteCategoryUndoCommand delete: target selectedCategory in: target classOrMetaSelected onModel: target viewedCategoryModel)
    ]
]

