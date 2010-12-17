SourceFormatter subclass: ClassHeaderSource [
    | printClass |
    
    ClassHeaderSource class >> write: aClass on: aStream [
	<category: 'instance creation'>

	^ (self for: aStream)
	    printClass: aClass;
	    output;
            yourself
    ]

    printClass: aClass [
	<category: 'accessing'>

	printClass := aClass
    ]

    stream: aStream [
	<category: 'accessing'>

	stream := aStream
    ]

    outputClassHeader [
	<category: 'printing'>

	| superclassName |
        superclassName := printClass superclass isNil
            ifTrue: [ 'nil' ]
            ifFalse: [ printClass superclass nameIn: printClass environment ].

         stream
	    nextPutAll: superclassName;
	    space;
            nextPutAll: 'subclass: ';
            nextPutAll: printClass name;
            space;
            nextPut: $[;
            nl;
	    space: 4
    ]

    outputInstVarNamesArray [
	<category: 'printing'>

	printClass instVarNames do: [ :each |
	    stream
		nextPutAll: each asString;
		space
	]
    ]

    outputInstVarNames [
	<category: 'printing'>

	printClass instVarNames isEmpty ifTrue: [ ^ self ].
	stream
	    nextPutAll: '| '.
	self outputInstVarNamesArray.
	stream
	    nextPutAll: ' |';
	    nl;
	    space: 4
    ]

    outputShape [
	<category: 'printing'>

	| inheritedShape |
	inheritedShape := printClass superclass isNil ifTrue: [ nil ] ifFalse: [ printClass superclass shape ].
	printClass shape ~~ (printClass inheritShape ifTrue: [ inheritedShape ] ifFalse: [ nil ])
		ifTrue: [ 
		stream
		    nl;
		    space: 4;
		    nextPutAll: '<shape: #';
		    nextPutAll: printClass shape;
		    nextPut: $>;
		    nl;
		    space: 4 ]
    ]

    outputSharedPool [
	<category: 'printing'>

        printClass sharedPools do: [ :element |
	    stream
		nl;
		space: 4;
		nextPutAll: '<import: ';
		nextPutAll: element;
		nextPut: $> ].

        stream nl
    ]

    outputPragmas [
	<category: 'printing'>

        printClass classPragmas do: [ :selector |
	    stream
		space: 4;
		nextPut: $<;
		nextPutAll: selector;
		nextPutAll: ': '.
	    (printClass perform: selector) storeLiteralOn: stream.
	    stream
		nextPut: $>;
		nl ]
    ]

    outputClassInstanceVariablesArray [
	<category: 'printing'>

	printClass asMetaclass instVarNames do: [ :each |
	    stream
		nextPutAll: each asString;
		space ]
    ]

    outputClassInstanceVariables [
	<category: 'printing'>

        printClass asMetaclass instVarNames isEmpty ifTrue: [ ^ self ].
	stream
	    nl;
	    space: 4;
	    nextPutAll: printClass name;
	    nextPutAll: ' class [';
	    nl;
	    space: 8;
	    nextPutAll: '| '.
	self outputClassInstanceVariablesArray.
	stream
	    nextPutAll: ' |';
	    nl;
	    space: 4;
	    nextPut: $];
	    nl
    ]

    outputClassVariables [
	<category: 'printing'>

	stream nl.
	printClass classVarNames isEmpty ifTrue: [ ^ self ].
	printClass classVarNames do: [ :var |
	    stream
		space: 4;
		nextPutAll: var;
		nextPutAll: ' := nil.';
		nl ].
	stream nl
    ]

    outputMethods [
	<category: 'printing'>

    ]

    outputFinalBracket [
	<category: 'printing'>

        stream
            nextPut: $];
            nl;
            nl
    ]

    output [
	<category: 'printing'>

        self
            outputClassHeader;
            outputInstVarNames;
            outputShape;
            outputSharedPool;
            outputPragmas;
            outputClassInstanceVariables;
            outputClassVariables;
	    outputMethods;
	    outputFinalBracket.
    ]

    parser [
        ^ STInST.GSTParser
    ]
]

