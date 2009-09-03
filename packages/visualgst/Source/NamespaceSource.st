Object subclass: NamespaceSource [
    | namespace stream |

    NamespaceSource class >> on: aNamespace [
	<category: 'instance creation'>

	^ (self write: aNamespace on: (WriteStream on: String new))
	    header
    ]

    NamespaceSource class >> write: aNamespace on: aStream [
	<category: 'instance creation'>

	^ (self new)
	    namespace: aNamespace;
	    stream: aStream;
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

    header [
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
        ^ stream contents
    ]

    source [
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

	namespace do: [ :each |
	    (each isNil not and: [ each isClass and: [ each environment = namespace ] ])
		ifTrue: [ (ClassSource write: each on: stream)
			    source ] ].

	^ stream contents
    ]
]
