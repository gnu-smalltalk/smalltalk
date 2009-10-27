UndoCommand subclass: AddMethodUndoCommand [

    | selector method category classOrMeta oldCompiledMethod browserWidget compiledMethod methodWidget selectedMethod |

    AddMethodUndoCommand class >> add: aString classified: aCategory in: aClass [
	<category: 'instance creation'>

	^ (self new)
	    add: aString classified: aCategory in: aClass;
	    precondition;
	    yourself
    ]

    AddMethodUndoCommand class >> add: aString classified: aCategory in: aClass widget: aGtkWidget browser: aGtkBrowserWidget [
        <category: 'instance creation'>

        ^ (self new)
            add: aString classified: aCategory in: aClass widget: aGtkWidget browser: aGtkBrowserWidget;
            precondition;
            yourself
    ]

    compileError: aString [
	<category: 'error printing'>

	VisualGST compileError: aString
    ]

    add: aString classified: aCategory in: aClass widget: aGtkWidget browser: aGtkBrowserWidget [
        <category: 'initialize'>

	self add: aString classified: aCategory in: aClass.
	methodWidget := aGtkWidget.
	browserWidget := aGtkBrowserWidget.
	methodWidget hasSelectedMethod ifTrue: [ selectedMethod := methodWidget selectedMethodSymbol ]
    ]

    add: aString classified: aCategory in: aClass [
	<category: 'initialize'>

	method := aString.
        category := (#('still unclassified' '*') includes: (aCategory))
					    ifTrue: [ nil ]
					    ifFalse: [ aCategory ].
	classOrMeta := aClass.
    ]

    description [
	<category: 'accessing'>

	^ 'Add a method'
    ]

    precondition [
        <category: 'checking'>

	| parser |
        parser := STInST.RBBracketedMethodParser new
                    errorBlock: [ :string :pos | ^ self compileError: string ];
                    initializeParserWith: method type: #'on:errorBlock:';
                    yourself.
	selector := parser parseMethod selector.
	oldCompiledMethod := classOrMeta methodDictionary ifNotNil: [ classOrMeta methodDictionary at: selector ifAbsent: [ nil ] ].
	compiledMethod := classOrMeta
				compile: method
				classified: category
				ifError: [ :fname :lineNo :errorString |
				    ^ self compileError: 'Compile error ', errorString ].
    ]

    undo [
	<category: 'events'>

	classOrMeta methodDictionary removeMethod: compiledMethod.
	oldCompiledMethod 
	    ifNotNil: [ classOrMeta methodDictionary insertMethod: oldCompiledMethod ].
	methodWidget ifNotNil: [ methodWidget selectAMethod: selectedMethod ]
    ]

    redo [
	<category: 'events'>

	oldCompiledMethod ifNil: [ classOrMeta methodDictionary insertMethod: compiledMethod ].
	methodWidget ifNotNil: [ 
	    browserWidget codeSaved.
	    methodWidget selectAMethod: selector asString ]
    ]
]

