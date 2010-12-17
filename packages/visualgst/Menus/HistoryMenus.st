MenuBuilder subclass: HistoryMenus [

    HistoryMenus class >> menus [

	^ {HistoryBackCommand.
        HistoryForwardCommand.
	MenuSeparator.
        HistoryDisplayCommand}
    ]
]
