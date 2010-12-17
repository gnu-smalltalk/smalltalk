MethodCommand subclass: FileoutMethodCommand [

    item [

	^ 'File out a method'
    ]

    execute [
	<category: 'command'>

	self chooseFile
    ]

    chooseFile [

        | file |
        (GTK.GtkFileChooserDialog save: 'Save Smalltalk method as...' parent: nil)
            showModalOnAnswer: [ :dlg :res |
                res = GTK.Gtk gtkResponseAccept ifTrue: [ self fileoutMethod: dlg getFilename ].
                dlg destroy ]
    ]

    fileoutMethod: aString [
        <category: 'class events'>

        | stream |
        stream := FileStream open: aString mode: FileStream write.
        MethodSource write: target state method on: stream
    ]
]

