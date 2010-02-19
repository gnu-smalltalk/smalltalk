Object subclass: GtkEntryDialog [
    | dialog labelWidget entryWidget hasPressedOk |

    GtkEntryDialog class >> title: aTitle text: aDescription [
	<category: 'instance creation'>

	^ (self new)
	    title: aTitle text: aDescription;
	    yourself
    ]

    title: aTitle text: aDescription [
	<category: 'initialization'>

	hasPressedOk := false.
	dialog := GTK.GtkDialog newWithButtons: aTitle parent: nil flags: 0 varargs: {nil}.
	self buildCentralWidget: aDescription on: dialog.
	dialog showModalOnAnswer: [ :dlg :res |
		res = GTK.Gtk gtkResponseYes ifTrue: [ hasPressedOk := true ].
		dlg destroy ]
    ]

    hasPressedOk [
	<category: 'testing'>

	^ hasPressedOk
    ]

    result [
	<category: 'accessing'>

	^ entryWidget getText
    ]

    buildCentralWidget: aString on: aGtkDialog [
	<category: 'user interface'>

	| hbox |
	aGtkDialog
	    addButton: 'Yes' responseId: GTK.Gtk gtkResponseYes;
	    addButton: 'No' responseId: GTK.Gtk gtkResponseNo.

	hbox := GTK.GtkHBox new: true spacing: 0.
	labelWidget := GTK.GtkLabel new: aString.
	entryWidget := GTK.GtkEntry new.
	hbox
	    add: labelWidget;
	    add: entryWidget;
	    showAll.
	aGtkDialog getVBox add: hbox
    ]
]

