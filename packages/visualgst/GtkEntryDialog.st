Object subclass: GtkEntryDialog [
    | dialog labelWidget entryWidget hasPressedOk buttons defaultButton |

    GtkEntryDialog class >> title: aTitle text: aDescription [
	<category: 'instance creation'>

	^ (self new)
	    title: aTitle text: aDescription;
	    yourself
    ]

    beOkCancel [
        buttons := #( ('Ok' #gtkResponseOk) ('Cancel' #gtkResponseCancel))
    ]

    beYesNo [
        buttons := #( ('Yes' #gtkResponseYes) ('No' #gtkResponseNo))
    ]

    title: aTitle text: aDescription [
	<category: 'initialization'>

	hasPressedOk := false.
	dialog := GTK.GtkDialog newWithButtons: aTitle parent: nil flags: 0 varargs: {nil}.
	self buildCentralWidget: aDescription on: dialog.
	"dialog showModalOnAnswer: [ :dlg :res |
		res = GTK.Gtk gtkResponseYes ifTrue: [ hasPressedOk := true ].
		dlg destroy ]"
    ]

    hasPressedOk: aBlock [
	<category: 'testing'>

        dialog showModalOnAnswer: [ :dlg :res |
                res = defaultButton ifTrue: [ aBlock value ].
                dlg destroy ]
    ]

    result [
	<category: 'accessing'>

	^ entryWidget getText
    ]

    buildCentralWidget: aString on: aGtkDialog [
	<category: 'user interface'>

	| hbox |
        buttons isNil ifTrue: [ self beOkCancel ].
        buttons do: [ :each |
	    aGtkDialog addButton: each first responseId: (GTK.Gtk perform: each second) ].

        defaultButton := GTK.Gtk perform: buttons first second.
        aGtkDialog setDefaultResponse: defaultButton.
	hbox := GTK.GtkHBox new: true spacing: 0.
	labelWidget := GTK.GtkLabel new: aString.
	entryWidget := GTK.GtkEntry new.
        entryWidget setActivatesDefault: true.
	hbox
	    add: labelWidget;
	    add: entryWidget;
	    showAll.
	aGtkDialog getVBox add: hbox
    ]
]

