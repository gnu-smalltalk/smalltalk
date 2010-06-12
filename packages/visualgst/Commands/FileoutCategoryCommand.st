CategoryCommand subclass: FileoutCategoryCommand [

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
        (CategorySource write: target selectedCategory of: target classOrMeta on: stream)
            source
    ]
]

