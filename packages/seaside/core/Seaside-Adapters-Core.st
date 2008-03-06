Object subclass: WACodec [
    
    <category: 'Seaside-Adapters-Core'>
    <comment: nil>

    WACodec class >> forEncoding: aStringOrNil [
	"valid values for aStringOrNil are:
	 nil
	 switches off all encoding, like WAKom
	 aString
	 any other encoding supported by the dialect"

	<category: 'instance creation'>
	aStringOrNil isNil ifTrue: [^WANullCodec new].
	^WAGenericCodec newForEncoding: aStringOrNil
    ]

    decode: aString [
	<category: 'decoding'>
	self subclassResponsibility
    ]

    decodeUrl: aString [
	<category: 'decoding'>
	self subclassResponsibility
    ]

    encode: aString [
	<category: 'encoding'>
	self subclassResponsibility
    ]
]



WACodec subclass: WAGenericCodec [
    
    <category: 'Seaside-Adapters-Core'>
    <comment: nil>

    Implementation := nil.

    WAGenericCodec class >> newForEncoding: aString [
	<category: 'instance creation'>
	^Implementation newForEncoding: aString
    ]
]



WACodec subclass: WANullCodec [
    
    <category: 'Seaside-Adapters-Core'>
    <comment: nil>

    decode: aString [
	<category: 'decoding'>
	^aString
    ]

    decodeUrl: aString [
	<category: 'decoding'>
	^aString
    ]

    encode: aString [
	<category: 'encoding'>
	^aString
    ]
]

