MenuBuilder subclass: MethodMenus [

    MethodMenus class >> menus [

	^ {OpenSenderCommand.
        OpenImplementorCommand.
	MenuSeparator.
        FileoutMethodCommand.
	MenuSeparator.
        InspectMethodCommand}
    ]
]
