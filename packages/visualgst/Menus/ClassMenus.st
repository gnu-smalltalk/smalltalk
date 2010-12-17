MenuBuilder subclass: ClassMenus [

    ClassMenus class >> menus [

	^ {AddClassCommand.
        RenameClassCommand.
        DeleteClassCommand.
	MenuSeparator.
        FileoutClassCommand.
	MenuSeparator.
        InspectClassCommand}
    ]
]

