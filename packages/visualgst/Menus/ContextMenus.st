MenuBuilder subclass: ContextMenus [

    ContextMenus class >> menus [

	^ {InspectMethodCommand.
	MenuSeparator.
        FileoutMethodCommand}
    ]
]
