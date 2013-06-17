"======================================================================
|
| Extensions
|
======================================================================"

"======================================================================
|
| Copyright (c) 2013
| Gwenael Casaccio <gwenael.casaccio@gmail.com>,
|
|
| This file is part of VisualGST.
|
| Permission is hereby granted, free of charge, to any person obtaining
| a copy of this software and associated documentation files (the
| 'Software'), to deal in the Software without restriction, including
| without limitation the rights to use, copy, modify, merge, publish,
| distribute, sublicense, and/or sell copies of the Software, and to
| permit persons to whom the Software is furnished to do so, subject to
| the following conditions:
|
| The above copyright notice and this permission notice shall be
| included in all copies or substantial portions of the Software.
|
| THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
| EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
| MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
| IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
| CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
| TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
| SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
|
======================================================================"

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

