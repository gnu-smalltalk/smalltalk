TestCase subclass: TestRegexp [

    testEmptyMatch [
        | data match |

	data := '""'.
	match := (data =~ '"([^"]*)"').

        "Check that it has matched"
        self assert: match class equals: Kernel.MatchingRegexResults.
        self assert: match matched.
        self assert: match size = 1.
        self assert: (match at: 1) equals: ''.

        "Check if an exception is thrown"
        self shouldnt: [match printString] raise: Exception.
    ]

    testMatch [
        | data match |

	data := '"A"'.
	match := (data =~ '"([^"]*)"').

        "Check that it has matched"
        self assert: match class equals: Kernel.MatchingRegexResults.
        self assert: match matched.
        self assert: match size = 1.
        self assert: (match at: 1) equals: 'A'.

        "Check if an exception is thrown"
        self shouldnt: [match printString] raise: Exception.
    ]

    testOptionalMatch [
	| match |
        match := 'Mary Jane Emily' =~ '(\w+)( \w+)?( \w+)?( \w+)?( \w+)?'.

	self assert: match class equals: Kernel.MatchingRegexResults.
	self assert: match matched.
	self assert: match size = 5.
	self assert: (match at: 1) equals: 'Mary'.
	self assert: (match at: 2) equals: ' Jane'.
	self assert: (match at: 3) equals: ' Emily'.
	self assert: (match at: 4) equals: nil.
	self assert: (match at: 5) equals: nil.
    ]
]
