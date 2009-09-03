Object subclass: ClassSource [
    | printClass stream |
    
    ClassSource class >> displayHeaderOf: aClass [
	<category: 'instance creation'>

	^ (self write: aClass on: (WriteStream on: String new))
	    header
    ]

    ClassSource class >> write: aClass on: aStream [
	<category: 'instance creation'>

	^ self new
	    printClass: aClass;
	    stream: aStream;
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
	<category: 'printint'>

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

	printClass shape isNil ifTrue: [ ^ self ].
        printClass superclass isNil ifTrue: [ ^ self ].
	stream
	    nl;
	    space: 4;
            nextPutAll: '<shape: #';
	    nextPutAll: printClass shape;
	    nextPut: $>;
	    nl;
	    space: 4 
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


    header [
        <category: 'accessing'>

        self
            outputClassHeader;
            outputInstVarNames;
            outputShape;
            outputSharedPool;
            outputPragmas;
            outputClassInstanceVariables;
            outputClassVariables.

        stream
            nextPut: $];
            nl;
            nl.

        ^ stream contents
    ]

    source [
	<category: 'accessing'>
	
	self
	    outputClassHeader;
	    outputInstVarNames;
	    outputShape;
	    outputSharedPool;
	    outputPragmas;
	    outputClassInstanceVariables;
	    outputClassVariables.
    
	printClass methodDictionary ifNotNil: [ printClass methodDictionary do: [ :each | 
							| text |
							text := each methodSourceString ifNil: [ each selector asString, ' [', Character nl asString, '    ]', Character nl asString ].
							stream 
							    space: 4; 
							    nextPutAll: text; 
							    nl; 
							    nl ] ].
    
	stream
	    nextPut: $];
	    nl;
	    nl.

	^ stream contents
    ]
]

