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

    source [
	<category: 'accessing'>

        stream
            nextPutAll: printMethod methodClass displayString;
            nextPutAll: ' extend [';
            nl;
            nextPutAll: printMethod methodSourceString;
	    nl;
            nextPutAll: ']';
            nl.

        ^ stream contents
    ]

    sourceWithoutClassHeader [
        <category: 'accessing'>

        stream
            nextPutAll: printMethod methodSourceString;
            nl.

        ^ stream contents
    ]
]

