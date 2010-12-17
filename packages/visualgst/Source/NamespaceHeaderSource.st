SourceFormatter subclass: NamespaceHeaderSource [
    | namespace |

    NamespaceHeaderSource class >> write: aNamespace on: aStream [
	<category: 'instance creation'>

	^(self for: aStream)
	    namespace: aNamespace;
	    output;
            yourself
    ]

    namespace: aNamespace [
	<category: 'accessing'>

	namespace := aNamespace
    ]

    stream: aStream [
	<category: 'accessing'>

	stream := aStream
    ]

    output [
	<category: 'accessing'>

	namespace superspace isNil
            ifFalse: [
		stream
                    nextPutAll: (namespace superspace nameIn: Smalltalk);
                    nextPutAll: ' addSubspace: #';
                    nextPutAll: namespace name;
                    nextPutAll: '!';
                    nl;
                    nextPutAll: 'Namespace current: ';
                    nextPutAll: (namespace nameIn: Smalltalk);
                    nextPutAll: '!';
                    nl;
                    nl ]
            ifTrue: [
		stream
                    nextPutAll: 'Namespace current: (RootNamespace new: #';
                    nextPutAll: (namespace nameIn: Smalltalk);
                    nextPutAll: ')!';
                    nl;
		    nl ].
    ]

    parser [
        ^ STInST.GSTParser
    ]
]
