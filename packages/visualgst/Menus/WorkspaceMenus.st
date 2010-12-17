MenuBuilder subclass: WorkspaceMenus [

    WorkspaceMenus class >> menus [

	^{UndoEditCommand.
                RedoEditCommand.
                MenuSeparator.
                DoItCommand.
                PrintItCommand.
                DebugItCommand.
                InspectItCommand.
                MenuSeparator.
                AcceptItCommand}.
    ]
]
