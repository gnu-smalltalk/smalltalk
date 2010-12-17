MenuBuilder subclass: TextMenus [

    TextMenus class >> menus [

	^{OpenSenderCommand.
		OpenImplementorCommand.
                MenuSeparator.
                AcceptItCommand.
                CancelCommand.
                MenuSeparator.
                UndoEditCommand.
                RedoEditCommand.
                MenuSeparator.
                DoItCommand.
                PrintItCommand.
                DebugItCommand.
                InspectItCommand}.
    ]
]
