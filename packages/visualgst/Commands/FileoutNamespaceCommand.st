NamespaceCommand subclass: FileoutNamespaceCommand [

    | namespace |

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

        namespace := target state namespace.
        self 
	    fileoutNamespaceOn: (File name: aDirectory) / namespace name;
	    fileoutNamespaceExtendsOn: (File name: aDirectory) / namespace name
    ]

    fileoutNamespaceOn: aDirectory [
        <category: 'namespace events'>

        | stream |
        aDirectory exists ifFalse: [ aDirectory createDirectory ].
        stream := FileStream open: (aDirectory / 'self.st') asString mode: FileStream write.
        (NamespaceSource write: namespace on: stream)
                header.
        namespace do: [ :each |
            (each isNil not and: [ each isClass and: [ each environment = namespace ] ])
                    ifTrue: [ self fileoutClass: each from: aDirectory ] ]
    ]

    fileoutNamespaceExtendsOn: aDirectory [
        <category: 'namespace events'>

        | stream |
        aDirectory exists ifFalse: [ aDirectory createDirectory ].
        namespace namespaceExtends keysAndValuesDo: [ :key :value |
		self fileoutExtendsMethods: value category: key from: aDirectory ]
    ]

    fileoutClass: aClass from: aDirectory [

	| directory stream |
	directory := self createCategories: aClass category from: aDirectory.
	stream := FileStream open: (directory / ((aClass name asString) , '.st')) asString mode: FileStream write.
	(ClassSource write: aClass on: stream)
                source
    ]

    fileoutExtendsMethods: aSetOfMethods category: aString from: aDirectory [

	| directory stream class |
	directory := self createCategories: aString from: aDirectory.
	class := IdentityDictionary new.
	aSetOfMethods do: [ :each |
	    (class at: each methodClass ifAbsentPut: [ OrderedCollection new ]) add: each ].
	class keysAndValuesDo: [ :key :value |
	    stream := FileStream open: (directory / (key name asString), '-Ext.st') asString mode: FileStream write.
	    (MethodSource writeMethods: value on: stream)
                source ]
	
    ]

    createCategories: aString from: aDirectory [

        | categories directory |
	(aString isNil or: [ aString isEmpty ]) ifTrue: [ ^ aDirectory ].
        categories := (aString tokenize: '-') asOrderedCollection.
        categories first = namespace name asString ifTrue: [ categories removeFirst ].
        directory := aDirectory.
        categories do: [ :each |
            directory := directory / each.
            directory exists ifFalse: [ directory createDirectory ] ].
	^ directory
    ]
]

