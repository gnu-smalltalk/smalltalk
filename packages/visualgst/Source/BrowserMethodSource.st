SourceFormatter subclass: BrowserMethodSource [
    | method |

    BrowserMethodSource class >> write: aCompiledMethod on: aStream [
	<category: 'instance creation'>

	^(self for: aStream)
	    method: aCompiledMethod;
	    output;
            yourself
    ]

    method: aCompiledMethod [
	<category: 'accessing'>

	method := aCompiledMethod
    ]

    stream: aStream [
	<category: 'accessing'>

	stream := aStream
    ]

    output [
	<category: 'accessing'>

	stream nextPutAll: method methodRecompilationSourceString
    ]

    parser [
        ^ STInST.RBBracketedMethodParser
    ]
]
