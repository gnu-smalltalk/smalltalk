Object subclass: MethodSource [
    | printMethod stream |

    MethodSource class >> display: aCompiledMethod [
	<category: 'instance creation'>

	^ (self write: aCompiledMethod on: (WriteStream on: String new))
	    method 
    ]

    MethodSource class >> write: aCompiledMethod on: aStream [
	<category: 'instance creation'>

	^ self new
	    printMethod: aCompiledMethod;
	    stream: aStream;
	    yourself
    ]

    printMethod: aCompiledMethod [
	<category: 'accessing'>

	printMethod := aCompiledMethod
    ]

    stream: aStream [
	<category: 'accessing'>

	stream := aStream
    ]

    header [
        <category: 'accessing'>

	^ printMethod methodSourceString 
    ]

    methodSource [
        <category: 'accessing'>

        ^ (printMethod methodSourceString
                    ifNil: [ printMethod selector asString, ' [', Character nl asString, '    ]', Character nl asString ])
            copyReplacingAllRegex: '\t' with: '    '
    ]

    outputMethod: aMethod [
        <category: 'printing'>

        | lines |
        lines := self methodSource lines.
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
            nextPutAll: printMethod methodClass displayString;
            nextPutAll: ' extend [';
            nl.
        self outputMethod: self methodSource.
	stream
            nextPutAll: ']';
            nl.

        ^ stream contents
    ]

    sourceWithoutClassHeader [
        <category: 'accessing'>

        self outputMethod: self methodSource.

        stream nl. 
        ^ stream contents
    ]
]

