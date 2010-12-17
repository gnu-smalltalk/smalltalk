AbstractNamespace class extend [
    WorkspacePath := nil.

    workspacePath: aFile [
        <category: '*VisualGST'>

	aFile isDirectory ifFalse: [ self error: aFile, ' is not a directory' ].
	WorkspacePath := aFile
    ]

    workspacePath [
        <category: '*VisualGST'>

        ^ WorkspacePath
    ]
]

AbstractNamespace extend [

    save [
	<category: 'namespace-saving'>

	self fileoutNamespace: self workspacePath
    ]

    load [
	<category: 'namespace-loading'>

    ]

    createWorkspacePath: aNamespace in: aDirectory [

	| directory |
	directory := aDirectory / aNamespace name.
        directory exists ifFalse: [ directory createDirectory ].
	aNamespace subSpaces do: [ :each |
	    self createWorkspacePath: aNamespace in: directory ]
    ]

    createWorkspacePath [

	self createWorkspacePath: Smalltalk in: self workspacePath
    ]

    workspacePath [
	<category: 'accessing'>

	| string space |

	space := self.
	[ space isNil ] whileFalse: [
	    string := string, '/', self name ].

	^ self class savePath / string
    ]

    fileoutNamespace: aDirectory [

        self
	    createWorkspacePath;
            fileoutNamespaceOn: aDirectory / self name;
            fileoutNamespaceExtendsOn: aDirectory / self name;
	    fileoutSubspaces
    ]

    fileoutSubspaces [
	<category: 'namespace events'>

	self allSubspaces do: [ :each |
	    each save ]
    ]

    fileoutNamespaceOn: aDirectory [
        <category: 'namespace events'>

        | stream |
        aDirectory exists ifFalse: [ aDirectory createDirectory ].
        stream := FileStream open: (aDirectory / 'self.st') asString mode: FileStream write.
        (NamespaceSource write: self on: stream)
                header.
        self do: [ :each |
            (each isNil not and: [ each isClass and: [ each environment = self ] ])
                    ifTrue: [ self fileoutClass: each from: aDirectory ] ].
    ]

    fileoutNamespaceExtendsOn: aDirectory [
        <category: 'namespace events'>

        | stream |
        aDirectory exists ifFalse: [ aDirectory createDirectory ].
        self namespaceExtends keysAndValuesDo: [ :key :value |
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
        categories first = self name asString ifTrue: [ categories removeFirst ].
        directory := aDirectory.
        categories do: [ :each |
            directory := directory / each.
            directory exists ifFalse: [ directory createDirectory ] ].
        ^ directory
    ]
]

