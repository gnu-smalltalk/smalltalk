NamespaceHeaderSource subclass: NamespaceSource [

    NamespaceSource class >> write: aNamespace on: aStream [
	<category: 'instance creation'>

	^(self for: aStream)
	    namespace: aNamespace;
	    output;
            yourself
    ]

    output [
	<category: 'accessing'>

	super output.
	namespace do: [ :each |
	    (each isNil not and: [ each isClass and: [ each environment = namespace ] ])
		ifTrue: [ (ClassSource write: each on: stream)
			    source ] ].
    ]
]
