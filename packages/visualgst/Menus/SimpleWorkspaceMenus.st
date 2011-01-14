MenuBuilder subclass: SimpleWorkspaceMenus [

    SimpleWorkspaceMenus class >> menus [

	^{UndoEditCommand.
                RedoEditCommand.
                MenuSeparator.
                DoItCommand.
                PrintItCommand.
                DebugItCommand.
                InspectItCommand}
    ]
]
