"======================================================================
|
|   SUnit testing framework scripting system
|
|   This file is in the public domain.
|
 ======================================================================"



Object subclass: TestSuitesScripter [
    | script stream variables |
    
    <category: 'SUnit'>
    <comment: nil>

    Current := nil.

    TestSuitesScripter class >> run: script quiet: quiet verbose: verbose [
	<category: 'Init / Release'>
	| result |
	result := self withScript: script
		    do: 
			[:scripter | 
			| suite |
			suite := scripter value.

			"Set log policy to write to stdout."
			quiet ifTrue: [suite logPolicy: TestLogPolicy null].
			verbose ifTrue: [suite logPolicy: (TestVerboseLog on: stdout)].
			(quiet or: [verbose]) 
			    ifFalse: [suite logPolicy: (TestCondensedLog on: stdout)].
			suite run].

	"Print result depending on verboseness."
	quiet 
	    ifFalse: 
		[result runCount < result passedCount ifTrue: [stdout nl].
		result printNl.
		result errorCount > 0 
		    ifTrue: 
			[stdout
			    nextPutAll: 'Errors:';
			    nl.
			(result errors 
			    asSortedCollection: [:a :b | a printString <= b printString]) do: 
				    [:each | 
				    stdout
					nextPutAll: '    ';
					print: each;
					nl]].
		result failureCount > 0 
		    ifTrue: 
			[stdout
			    nextPutAll: 'Failures:';
			    nl.
			(result failures 
			    asSortedCollection: [:a :b | a printString <= b printString]) do: 
				    [:each | 
				    stdout
					nextPutAll: '    ';
					print: each;
					nl]]].
	^result
    ]

    TestSuitesScripter class >> current [
	<category: 'Init / Release'>
	^Current
    ]

    TestSuitesScripter class >> variableAt: aString ifAbsent: aBlock [
	<category: 'Init / Release'>
	self current isNil ifTrue: [^aBlock value].
	^self current variableAt: aString ifAbsent: aBlock
    ]

    TestSuitesScripter class >> run: aString [
	<category: 'Init / Release'>
	^self withScript: aString do: [:scripter | scripter value run]
    ]

    TestSuitesScripter class >> withScript: aString do: aBlock [
	<category: 'Init / Release'>
	| previous |
	previous := Current.
	^[aBlock value: (Current := self script: aString)] 
	    sunitEnsure: [Current := previous]
    ]

    TestSuitesScripter class >> script: aString [
	<category: 'Init / Release'>
	^self new setScript: aString
    ]

    printOn: aStream [
	<category: 'Printing'>
	super printOn: aStream.
	script isNil ifTrue: [^self].
	aStream
	    nextPut: $<;
	    nextPutAll: script;
	    nextPut: $>
    ]

    singleSuiteScript: aString [
	<category: 'Private'>
	| useHierarchy realName testCase |
	aString last = $* 
	    ifTrue: 
		[realName := aString copyFrom: 1 to: aString size - 1.
		useHierarchy := true]
	    ifFalse: 
		[realName := aString.
		useHierarchy := false].
	realName isEmpty ifTrue: [^nil].
	testCase := SUnitNameResolver classNamed: realName.
	testCase isNil ifTrue: [^nil].
	^useHierarchy 
	    ifTrue: [self hierarchyOfTestSuitesFrom: testCase]
	    ifFalse: [testCase suite]
    ]

    variableAt: aString put: valueString [
	<category: 'Private'>
	^variables at: aString put: valueString
    ]

    variableAt: aString ifAbsent: aBlock [
	<category: 'Private'>
	^variables at: aString ifAbsent: aBlock
    ]

    parseVariable: name [
	<category: 'Private'>
	| value ch |
	name isEmpty ifTrue: [self error: 'empty variable name'].
	(stream peekFor: $') 
	    ifFalse: 
		[value := stream peek isSeparator 
			    ifTrue: ['']
			    ifFalse: [(self getNextWord: '') ifNil: ['']].
		^self variableAt: name put: value].
	value := WriteStream on: String new.
	
	[stream atEnd ifTrue: [self error: 'unterminated string'].
	(ch := stream next) ~= $' or: [stream peekFor: $']] 
		whileTrue: [value nextPut: ch].
	^self variableAt: name put: value contents
    ]

    getNextToken [
	<category: 'Private'>
	| word |
	
	[self skipWhitespace.
	word := self getNextWord: '='.
	stream peekFor: $=] 
		whileTrue: [self parseVariable: word].
	^word
    ]

    skipWhitespace [
	<category: 'Private'>
	
	[self skipComments.
	stream atEnd ifTrue: [^nil].
	stream peek isSeparator] 
		whileTrue: [stream next]
    ]

    getNextWord: extraDelimiters [
	<category: 'Private'>
	| word ch |
	stream atEnd ifTrue: [^nil].
	word := WriteStream on: String new.
	
	[ch := stream peek.
	ch isSeparator ifTrue: [^word contents].
	(extraDelimiters includes: ch) ifTrue: [^word contents].
	word nextPut: stream next.
	stream atEnd ifTrue: [^word contents]] 
		repeat
    ]

    hierarchyOfTestSuitesFrom: aTestCase [
	<category: 'Private'>
	| subSuite |
	subSuite := TestSuite new.
	aTestCase isAbstract ifFalse: [subSuite addTest: aTestCase suite].
	aTestCase allSubclasses 
	    do: [:each | each isAbstract ifFalse: [subSuite addTest: each suite]].
	^subSuite
    ]

    setScript: aString [
	<category: 'Private'>
	variables := Dictionary new.
	script := aString
    ]

    skipComments [
	<category: 'Private'>
	[stream peekFor: $"] whileTrue: [stream skipTo: $"]
    ]

    value [
	<category: 'Scripting'>
	| suite subSuite token |
	suite := TestSuite new.
	stream := ReadStream on: script.
	[stream atEnd] whileFalse: 
		[token := self getNextToken.
		token notNil 
		    ifTrue: 
			[subSuite := self singleSuiteScript: token.
			subSuite notNil ifTrue: [suite addTest: subSuite]]].
	^suite
    ]
]

