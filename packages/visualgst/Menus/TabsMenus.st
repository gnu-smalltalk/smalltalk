MenuBuilder subclass: TabsMenus [

    TabsMenus class >> menus [

	^ {PreviousTabCommand.
        NextTabCommand.
	CloseTabCommand}
    ]
]
