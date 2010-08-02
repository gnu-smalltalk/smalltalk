GtkVisualGSTTool subclass: GtkBrowsingTool [
    <comment: 'I am the base for various browsers of VisualGST.'>

    selectedText [
        <category: 'command protocols'>

        self subclassResponsibility
    ]

    acceptIt [
	<category: 'method events'>

	self subclassResponsibility
    ]

    browserHasFocus [
        <category: 'command protocols'>

        ^true
    ]

    onDelete: aGtkWidget event: aGdkEvent [
        <category: 'window events'>

        self saveCodeOr: [ window hideAll ].
        ^ true
    ]

    saveCodeOr: dropBlock [
        <category: 'saving'>

        | dialog |
        self hasChanged ifFalse: [ dropBlock value. ^self ].
        dialog := GTK.GtkMessageDialog
                                new: window
                                flags: GTK.Gtk gtkDialogDestroyWithParent
                                type: GTK.Gtk gtkMessageWarning
                                buttons: GTK.Gtk gtkButtonsNone
                                message: 'Accept changes before exiting?'
                                tip: 'If you choose "drop", your changes to %1 will be lost...' % {self state}.

        dialog
            addButton: 'Drop' responseId: 0;
            addButton: 'Cancel' responseId: 2;
            addButton: 'Accept' responseId: 1;
            showModalOnAnswer: [ :dlg :res |
                res = 1 ifTrue: [ self acceptIt ].
                res <= 1 ifTrue: dropBlock.
                dlg destroy ].
    ]

    checkCodeWidgetAndUpdate: aBlock [
        <category: 'text editing'>

        self saveCodeOr: [ aBlock value. self clearUndo ].
    ]

    hasChanged [
        <category: 'testing'>

        self subclassResponcibility
    ]

    clearUndo [
	<category: 'undo'>

	
        self subclassResponcibility
    ]
]

