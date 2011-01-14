MenuBuilder subclass: LauncherToolbar [
    LauncherToolbar class >> menus [

        ^ {CutEditCommand.
        CopyEditCommand.
        PasteEditCommand.
        ToolbarSeparator.
        UndoEditCommand.
        RedoEditCommand.
        ToolbarSeparator.
        DoItCommand.
        PrintItCommand.
        InspectItCommand.
        DebugItCommand.
        ToolbarSeparator.
        AcceptItCommand}
    ]
]
