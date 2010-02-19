Command subclass: FileoutNamespaceCommand [

    execute [
	<category: 'command'>

	self chooseDirectory
    ]

    chooseDirectory [
	| file |
        (GTK.GtkFileChooserDialog selectFolder: 'Save namespace as...' parent: nil)
            showModalOnAnswer: [ :dlg :res |
                res = GTK.Gtk gtkResponseAccept ifTrue: [ self fileoutNamespace: dlg getCurrentFolder ].
                dlg destroy ].
    ]

    fileoutNamespace: aDirectory [

        self fileoutNamespace: target on: (File name: aDirectory) / target name
    ]

    fileoutNamespace: aNamespace on: aDirectory [
        <category: 'namespace events'>

        | stream |
        aDirectory exists ifFalse: [ aDirectory createDirectory ].
        stream := FileStream open: (aDirectory / 'self.st') asString mode: FileStream write.
        (NamespaceSource write: aNamespace on: stream)
                header.
        aNamespace do: [ :each |
            (each isNil not and: [ each isClass and: [ each environment = aNamespace ] ])
                    ifTrue: [ stream := FileStream open: (aDirectory / ((each name asString) , '.st')) asString mode: FileStream write.
                            (ClassSource write: each on: stream)
                                source ] ]
    ]
]

