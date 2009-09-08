Smalltalk.TestCase subclass: ExtractLiteralsTest [

    testObject [
	<category: 'testing'>

	| obj int dic |
	obj := Object new.
	int := 123.
	dic := Dictionary new.
	self assert: obj hasLiterals = false.
	self assert: int hasLiterals = false.
	self assert: dic hasLiterals = false.
    ]

    testSymbol [
	<category: 'testing'>

	self assert: #'at:put:' hasLiterals.
	self assert: #'at:put:' symbolFromliterals asArray = {#'at:put:'}
    ]

    testArray [
	<category: 'testing'>

	self assert: #(1 2 3) hasLiterals = false.
	self assert: #(1 'foo' #'at:put:') hasLiterals = true.
	self assert: #(1 'foo' #'at:put:') symbolFromliterals asArray = {#'at:put:'}
    ]
]
