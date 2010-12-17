MenuBuilder subclass: EditMenus [

    EditMenus class >> menus [

	^ {CancelEditCommand.
        UndoEditCommand.
	RedoEditCommand.
	MenuSeparator.
        CutEditCommand.
	CopyEditCommand.
	PasteEditCommand.
	MenuSeparator.
        SelectAllEditCommand.
	MenuSeparator.
        FindEditCommand.
	ReplaceEditCommand}
    ]
]
