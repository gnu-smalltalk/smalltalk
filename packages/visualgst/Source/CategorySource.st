SourceFormatter subclass: CategorySource [
    | printCategory class |

    CategorySource class >> write: aSymbol of: aClass on: aStream [
	<category: 'instance creation'>

	^(self for: aStream)
	    printCategory: aSymbol of: aClass;
	    output;
            yourself
    ]

    printCategory: aSymbol of: aClass [
	<category: 'accessing'>

	printCategory := aSymbol.
	class := aClass
    ]

    stream: aStream [
	<category: 'accessing'>

	stream := aStream
    ]

    output [
	<category: 'accessing'>

        stream
            nextPutAll: class displayString;
            nextPutAll: ' extend [';
            nl.

	class methodDictionary do: [ :each |
	    each methodCategory = printCategory ifTrue: [
		(MethodSource write: each on: stream)
		    outputWithoutClassHeader ] ].

	stream
            nextPutAll: ']';
            nl.
    ]

    parser [
        ^ STInST.GSTParser
    ]
]

