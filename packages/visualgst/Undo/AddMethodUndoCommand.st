UndoCommand subclass: AddMethodUndoCommand [

    | selector method category classOrMeta oldCompiledMethod compiledMethod |

    AddMethodUndoCommand class >> add: aString classified: aCategory in: aClass [
	<category: 'instance creation'>

	^ (self new)
	    add: aString classified: aCategory in: aClass;
	    precondition;
	    yourself
    ]

    compileError: aString [
	<category: 'error printing'>

	VisualGST compileError: aString
    ]

    add: aString classified: aCategory in: aClass [
	<category: 'initialize'>

	method := aString.
	category := aCategory.
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
	    ifNotNil: [ classOrMeta methodDictionary insertMethod: oldCompiledMethod ]
    ]

    redo [
	<category: 'events'>

	oldCompiledMethod ifNil: [ classOrMeta methodDictionary insertMethod: compiledMethod ]
    ]
]

