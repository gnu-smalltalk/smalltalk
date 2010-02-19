Object subclass: UndoCommand [
    | description preconditionError |

    description [
	<category: 'accessing'>

	^ self subclassResponsibility 
    ]

    precondition [
	<category: 'checking'>

	^ true
    ]

    preconditionFailed: aString [
	<category: 'checking'>

	preconditionError := aString.
	^ false
    ]

    error [
	<category: 'checking'>

	^ preconditionError
    ]

    undo [
	<category: 'events'>

	self subclassResponsibility
    ]

    redo [
	<category: 'events'>

	self subclassResponsibility 
    ]

    displayError [
        <Category: 'error'>

        | dialog |
        dialog := GTK.GtkMessageDialog
                                new: nil
                                flags: GTK.Gtk gtkDialogDestroyWithParent
                                type: GTK.Gtk gtkMessageWarning
                                buttons: GTK.Gtk gtkButtonsNone
                                message: self description
                                tip: self error.

        dialog
            addButton: 'Ok' responseId: 1;
            showModalOnAnswer: [ :dlg :res | dlg destroy ].
    ]
]

