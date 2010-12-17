MenuBuilder subclass: CategoryMenus [

    CategoryMenus class >> menus [

	^ {AddCategoryCommand.
        RenameCategoryCommand.
	MenuSeparator.
        FileoutCategoryCommand}
    ]
]

