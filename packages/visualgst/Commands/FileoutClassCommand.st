Command subclass: FileoutClassCommand [

    execute [
	<category: 'command'>

	self chooseFile
    ]

    chooseFile [

        | file |
        (GTK.GtkFileChooserDialog save: 'Save Smalltalk class as...' parent: nil)
            showModalOnAnswer: [ :dlg :res |
                res = GTK.Gtk gtkResponseAccept ifTrue: [ self fileoutClass: dlg getFilename ].
                dlg destroy ]
    ]

    fileoutClass: aString [

        | stream |
        stream := FileStream open: aString mode: FileStream write.
        (ClassSource write: target on: stream)
            source
    ]
]

