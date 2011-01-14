UndoCommand subclass: AddMethodUndoCommand [

    | selector method category classOrMeta oldCompiledMethod browserWidget compiledMethod |

    AddMethodUndoCommand class >> add: aString classified: aCategory in: aClass [
	<category: 'instance creation'>

	^ (self new)
	    add: aString classified: aCategory in: aClass;
	    yourself
    ]

    AddMethodUndoCommand class >> add: aString classified: aCategory in: aClass browser: aGtkBrowserWidget [
        <category: 'instance creation'>

        ^ (self new)
            add: aString classified: aCategory in: aClass browser: aGtkBrowserWidget;
            yourself
    ]

    compileError: aString line: anInteger [
	<category: 'error printing'>

	browserWidget isNil ifFalse: [ GtkLauncher compileError: aString line: anInteger ].
	^ self preconditionFailed: aString
    ]

    compileError: aString pos: pos [
	<category: 'error printing'>

	^ self compileError: aString line: nil
    ]

    add: aString classified: aCategory in: aClass browser: aGtkBrowserWidget [
        <category: 'initialize'>

	self add: aString classified: aCategory in: aClass.
	browserWidget := aGtkBrowserWidget.
    ]

    add: aString classified: aCategory in: aClass [
	<category: 'initialize'>

	method := aString.
        category := (#('still unclassified' '*') includes: (aCategory))
					    ifTrue: [ nil ]
					    ifFalse: [ aCategory ].
	classOrMeta := aClass
    ]

    description [
	<category: 'accessing'>

	^ 'Add a method'
    ]

    precondition [
        <category: 'checking'>

	| parser node |
        parser := STInST.RBBracketedMethodParser new
                    errorBlock: [ :string :pos | self compileError: string pos: pos. ^false ];
                    initializeParserWith: method type: #'on:errorBlock:';
                    yourself.

	selector := parser parseMethod selector.
	oldCompiledMethod := classOrMeta methodDictionary ifNotNil: [ classOrMeta methodDictionary at: selector ifAbsent: [ nil ] ].
	" TODO: use compile:classified:ifError: if there is no category "
	compiledMethod := classOrMeta
				compile: method
				ifError: [ :fname :lineNo :errorString |
				    self compileError: errorString line: lineNo.
                                    ^ false ].
	^ true
    ]

    undo [
	<category: 'events'>

	| selector |
        browserWidget ifNotNil: [ browserWidget codeSaved ].

	classOrMeta methodDictionary removeMethod: compiledMethod.
	oldCompiledMethod 
	    ifNotNil: [
		classOrMeta methodDictionary insertMethod: oldCompiledMethod.
		selector := oldCompiledMethod selector ]
	    ifNil: [ selector := nil ].
    ]

    redo [
	<category: 'events'>

	browserWidget ifNotNil: [ browserWidget codeSaved ].

	oldCompiledMethod ifNotNil: [ classOrMeta methodDictionary removeMethod: oldCompiledMethod ].
	classOrMeta methodDictionary insertMethod: compiledMethod.

	browserWidget ifNotNil: [ classOrMeta isClass 
						    ifTrue: [ browserWidget selectAnInstanceMethod: compiledMethod selector ]
						    ifFalse: [ browserWidget selectAClassMethod: compiledMethod selector ] ]
    ]

    displayError [
        <Category: 'error'>

    ]
]

