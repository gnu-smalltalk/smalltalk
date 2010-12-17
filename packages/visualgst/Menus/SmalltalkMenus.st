MenuBuilder subclass: SmalltalkMenus [

    SmalltalkMenus class >> menus [

	^ {DoItCommand.
        PrintItCommand.
	InspectItCommand.
	DebugItCommand.
	MenuSeparator.
	AcceptItCommand}
    ]
]
