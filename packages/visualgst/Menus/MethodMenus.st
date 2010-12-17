MenuBuilder subclass: MethodMenus [

    MethodMenus class >> menus [

	^ {OpenSenderCommand.
        OpenImplementorCommand.
	MenuSeparator.
        DeleteMethodCommand.
	MenuSeparator.
        FileoutMethodCommand.
	MenuSeparator.
        InspectMethodCommand}
    ]
]
