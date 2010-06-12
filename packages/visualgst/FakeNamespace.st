Object subclass: FakeNamespace [

    FakeNamespace class >> subspaces [
	<category: 'accessing'>

	^ {Smalltalk}
    ]

    FakeNamespace class >> categories [
	<category: 'accessing'>

	^ ClassCategory new
    ]
]
