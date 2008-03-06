TestCase subclass: WACodecTest [
    
    <comment: nil>
    <category: 'Seaside-Adapters-Tests'>

    testGeneric [
	<category: 'testing'>
	#('utf-8' 'iso-8859-1') do: [:each | self assert: each notNil]
    ]

    testLatin1Codec [
	<category: 'testing'>
	| codec |
	codec := WACodec forEncoding: 'ISO-8859-1'.
	self assert: codec notNil.
	self assert: (codec encode: 'Übèrstrîñgé') = 'Übèrstrîñgé'.
	self assert: (codec decode: 'Übèrstrîñgé') = 'Übèrstrîñgé'.
	self assert: (codec decodeUrl: 'Übèrstrîñgé') = 'Übèrstrîñgé'
    ]

    testNullCodec [
	<category: 'testing'>
	| codec |
	codec := WACodec forEncoding: nil.
	self assert: codec notNil.
	self assert: codec class = WANullCodec.
	self assert: (codec encode: 'Übèrstrîñgé') = 'Übèrstrîñgé'.
	self assert: (codec decode: 'Übèrstrîñgé') = 'Übèrstrîñgé'.
	self assert: (codec decodeUrl: 'Übèrstrîñgé') = 'Übèrstrîñgé'
    ]

    testUtf8Codec [
	<category: 'testing'>
	| codec |
	codec := WACodec forEncoding: 'UTF-8'.
	self assert: codec notNil.
	self assert: (codec encode: 'Übèrstrîñgé') = 'ÃœbÃ¨rstrÃ®Ã±gÃ©'.
	self assert: (codec decode: 'ÃœbÃ¨rstrÃ®Ã±gÃ©') = 'Übèrstrîñgé'.
	self assert: (codec decodeUrl: 'ÃœbÃ¨rstrÃ®Ã±gÃ©') = 'Übèrstrîñgé'
    ]
]

