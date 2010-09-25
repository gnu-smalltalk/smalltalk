Object subclass: MethodSource [
    | printMethod stream |

    MethodSource class >> display: aCompiledMethod [
	<category: 'instance creation'>

	^ (self write: {aCompiledMethod} on: (WriteStream on: String new))
	    method 
    ]

    MethodSource class >> write: aCompiledMethod on: aStream [
	<category: 'instance creation'>

	^ self new
	    stream: aStream;
	    printMethod: {aCompiledMethod};
	    yourself
    ]

    MethodSource class >> writeMethods: aCollection on: aStream [
        <category: 'instance creation'>

        ^ self new
            stream: aStream;
            printMethod: aCollection;
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

    source [
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

        ^ stream contents
    ]

    sourceWithoutClassHeader [
        <category: 'accessing'>

	printMethod do: [ :each |
	    self outputMethod: (self methodSourceFor: each) ].

        stream nl. 
        ^ stream contents
    ]
]

