SourceFormatter subclass: MethodSource [
    | printMethod |

    MethodSource class >> write: aCompiledMethod on: aStream [
	<category: 'instance creation'>

	^(self for: aStream)
	    printMethod: {aCompiledMethod};
	    output;
            yourself
    ]

    MethodSource class >> writeMethods: aCollection on: aStream [
        <category: 'instance creation'>

	(self for: aStream)
            printMethod: aCollection;
	    output;
            yourself
    ]

    printMethod: aCollection [
	<category: 'accessing'>

	printMethod := aCollection
    ]

    stream: aStream [
	<category: 'accessing'>

	stream := aStream
    ]

    header [
        <category: 'accessing'>

	^ printMethod methodSourceString 
    ]

    methodSourceFor: aCompiledMethod [
        <category: 'accessing'>

        ^ (aCompiledMethod methodSourceString
                    ifNil: [ printMethod selector asString, ' [', Character nl asString, '    ]', Character nl asString ])
            copyReplacingAllRegex: '\t' with: '    '
    ]

    outputMethod: aString [
        <category: 'printing'>

        | lines |
        lines := aString lines.
        1 to: lines size - 1 do: [ :i |
            stream
                space: 4;
                nextPutAll: (lines at: i);
                nl ].
        stream 
            nextPutAll: lines last;
            nl  
    ]

    output [
	<category: 'accessing'>

        stream
            nextPutAll: printMethod first methodClass displayString;
            nextPutAll: ' extend [';
            nl.

	printMethod do: [ :each |
	    self outputMethod: (self methodSourceFor: each) ].

	stream
            nextPutAll: ']';
            nl.
    ]

    outputWithoutClassHeader [
        <category: 'accessing'>

	printMethod do: [ :each |
	    self outputMethod: (self methodSourceFor: each) ].

        stream nl. 
    ]

    parser [
        ^ STInST.RBBracketedMethodParser
    ]
]

