MenuBuilder subclass: NamespaceMenus [

    NamespaceMenus class >> menus [

	^ {AddNamespaceCommand.
        DeleteNamespaceCommand.
        RenameNamespaceCommand.
	MenuSeparator.
        FileoutNamespaceCommand.  
	MenuSeparator.
        InspectNamespaceCommand}
    ]
]
