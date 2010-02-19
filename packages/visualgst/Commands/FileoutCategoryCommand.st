Command subclass: FileoutCategoryCommand [
    | class |

    FileoutCategoryCommand class >> on: aClass categorized: aSymbol [
	<category: 'instance creation'>

	^ (self new)
	    target: aSymbol;
	    classOrMeta: aClass;
	    execute;
	    yourself
    ]

    classOrMeta: aClass [
	<category: 'accessing'>

	class := aClass
    ]

    execute [
	<category: 'command'>

	self chooseFile
    ]

    chooseFile [

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
        (CategorySource write: target of: class on: stream)
            source
    ]
]

