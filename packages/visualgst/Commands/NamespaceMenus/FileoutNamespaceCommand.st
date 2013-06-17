"======================================================================
|
| FileoutNamespaceCommand class definition
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

NamespaceCommand subclass: FileoutNamespaceCommand [

    | namespace |

    item [

	^ 'File out a namespace'
    ]

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
        NamespaceHeaderSource write: namespace on: stream.
        namespace allClassesDo: [ :each | self fileoutClass: each from: aDirectory ]
    ]

    fileoutNamespaceExtendsOn: aDirectory [
        <category: 'namespace events'>

        | stream |
        aDirectory exists ifFalse: [ aDirectory createDirectory ].
	self fileoutExtensionsTo: aDirectory
    ]

    fileoutClass: aClass from: aDirectory [

	| directory stream |
	directory := self createCategories: aClass category from: aDirectory.
	stream := FileStream open: (directory / ((aClass name asString) , '.st')) asString mode: FileStream write.
	(ClassSource write: aClass on: stream) close
    ]

    checkFileoutExtensions [

        | extName dic |
        dic := Dictionary new.
        extName := '*', namespace name.
        CompiledMethod allInstancesDo: [ :each |
            (each methodCategory startsWith: extName) ifTrue: [
                ((dic at: each methodCategory ifAbsentPut: [ Dictionary new ]) at: each methodClass ifAbsentPut: [ OrderedCollection new ]) add: each ] ].
        ^ dic
    ]

    fileoutExtensionsTo: aDirectory [

        | dic written |
        written := Set new.
        dic := self checkFileoutExtensions.
        dic keysAndValuesDo: [ :aMethodCategory :aDictionary |
	    | stream |
	    stream := ((self createCategories: (aMethodCategory copyFrom: 2 to: aMethodCategory size) from: aDirectory) / 'Extensions.st') writeStream.
	    aDictionary keysDo: [ :aBehavior |
		(written includes: aBehavior asClass) ifFalse: [
		    written add: aBehavior asClass.
		    aDictionary at: aBehavior asClass ifPresent: [ :anOrderedCollection | MethodSource writeMethods: anOrderedCollection on: stream ].
		    aDictionary at: aBehavior asMetaclass ifPresent: [ :anOrderedCollection | MethodSource writeMethods: anOrderedCollection on: stream ] ] ].
		stream close ]
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

