WAGenericCodec extend [
    WAGenericCodec class >> initialize [
        Implementation := WAIconvISO88591Codec
    ]
]

WACodec subclass: WAIconvISO88591Codec [
    <category: 'Seaside-Adapters-GST'>

    | encoding |

    WAIconvISO88591Codec class >> newForEncoding: aString [
	aString asLowercase = 'iso-8859-1' ifTrue: [ ^WANullCodec new ].
	^self new encoding: aString
    ]

    encoding: aString [
	encoding := aString
    ]

    decode: aString [
        <category: 'decoding'>
        ^(I18N.EncodedStream on: aString readStream from: encoding
		to: 'ISO-8859-1') contents asString
    ]

    decodeUrl: aString [
        <category: 'decoding'>
        ^(I18N.EncodedStream on: aString readStream from: encoding
		to: 'ISO-8859-1') contents asString
    ]

    encode: aString [
        <category: 'encoding'>
        ^(I18N.EncodedStream on: aString readStream from: 'ISO-8859-1'
	    to: encoding) contents asString
    ]
]

WAGenericCodec initialize
