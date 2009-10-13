Object subclass: CategorySource [
    | printCategory class stream |

    CategorySource class >> display: aSymbol of: aClass [
	<category: 'instance creation'>

	^ (self write: aSymbol of: aClass on: (WriteStream on: String new))
	    source 
    ]

    CategorySource class >> write: aSymbol of: aClass on: aStream [
	<category: 'instance creation'>

	^ self new
	    printCategory: aSymbol of: aClass;
	    stream: aStream;
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

    source [
	<category: 'accessing'>

        stream
            nextPutAll: class displayString;
            nextPutAll: ' extend [';
            nl.

	class methodDictionary do: [ :each |
	    each methodCategory = printCategory ifTrue: [
		(MethodSource write: each on: stream)
		    sourceWithoutClassHeader ] ].

	stream
            nextPutAll: ']';
            nl.

        ^ stream contents
    ]

]

