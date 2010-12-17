CategoryCommand subclass: FileoutCategoryCommand [

    item [

	^ 'File out a category'
    ]

    execute [
	<category: 'command'>

        | file |
        (GTK.GtkFileChooserDialog save: 'Save Smalltalk category as...' parent: nil)
            showModalOnAnswer: [ :dlg :res |
                res = GTK.Gtk gtkResponseAccept ifTrue: [ self fileoutCategory: dlg getFilename ].
                dlg destroy ]
    ]

    fileoutCategory: aString [
        <category: 'class events'>

        | stream |
        stream := FileStream open: aString mode: FileStream write.
        CategorySource write: target state category of: target classOrMeta on: stream
    ]
]

