"======================================================================
|
|   SUnit testing framework scripting system
|
|   This file is in the public domain.
|
 ======================================================================"

Object subclass: #TestSuitesScripter
    instanceVariableNames: 'script stream variables'
    classVariableNames: 'Current'
    poolDictionaries: ''
    category: 'SUnit'
!

!TestSuitesScripter class methodsFor: 'Init / Release'!

run: script quiet: quiet verbose: verbose
    | result |
    result := self withScript: script do: [ :scripter |
        | suite |
        suite := scripter value.

        "Set log policy to write to stdout."
        quiet
            ifTrue: [ suite logPolicy: TestLogPolicy null ].
        verbose
            ifTrue: [ suite logPolicy: (TestVerboseLog on: stdout) ].
        (quiet or: [ verbose ])
            ifFalse: [ suite logPolicy: (TestCondensedLog on: stdout) ].

        suite run ].

    "Print result depending on verboseness."
    quiet ifFalse: [
        result runCount < result passedCount
            ifTrue: [ stdout nl ].

        result printNl.
        result errorCount > 0 ifTrue: [
            stdout nextPutAll: 'Errors:'; nl.
            (result errors asSortedCollection: [ :a :b | a printString <= b printString ])
                do: [ :each | stdout nextPutAll: '    '; print: each; nl ] ].

        result failureCount > 0 ifTrue: [
            stdout nextPutAll: 'Failures:'; nl.
            (result failures asSortedCollection: [ :a :b | a printString <= b printString ])
                do: [ :each | stdout nextPutAll: '    '; print: each; nl ] ] ].

    ^result
!

current
    ^Current
!

variableAt: aString ifAbsent: aBlock
    self current isNil ifTrue: [ ^aBlock value ].
    ^self current variableAt: aString ifAbsent: aBlock
!

run: aString
    ^self withScript: aString do: [ :scripter |
        scripter value run ]!

withScript: aString do: aBlock
    | previous |
    previous := Current.
    ^[ aBlock value: (Current := self script: aString) ]
	sunitEnsure: [ Current := previous ]!

script: aString
    ^self new setScript: aString! !

!TestSuitesScripter methodsFor: 'Printing'!

printOn: aStream
    super printOn: aStream.
    script isNil ifTrue: [ ^self ].
    aStream nextPut: $<; nextPutAll: script; nextPut: $>
! !

!TestSuitesScripter methodsFor: 'Private'!

singleSuiteScript: aString 
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
!

variableAt: aString put: valueString
    ^variables at: aString put: valueString
!

variableAt: aString ifAbsent: aBlock
    ^variables at: aString ifAbsent: aBlock
!

parseVariable: name
    | value ch |
    name isEmpty ifTrue: [ self error: 'empty variable name' ].
    (stream peekFor: $') ifFalse: [
        value := stream peek isSeparator 
	    ifTrue: [ '' ]
	    ifFalse: [ (self getNextWord: '') ifNil: [ '' ] ].
	^self variableAt: name put: value ].

    value := WriteStream on: String new.
    [
        stream atEnd ifTrue: [ self error: 'unterminated string' ].
	(ch := stream next) ~= $' or: [ stream peekFor: $' ]
    ] whileTrue: [ value nextPut: ch ].

    ^self variableAt: name put: value contents!

getNextToken
    | word |
    [
	self skipWhitespace.
        word := self getNextWord: '='.
        stream peekFor: $=
    ] whileTrue: [ self parseVariable: word ].
    ^word!

skipWhitespace
    [
	self skipComments.
        stream atEnd ifTrue: [ ^nil ].
	stream peek isSeparator ] whileTrue: [ stream next ]!

getNextWord: extraDelimiters
    | word ch |
    stream atEnd ifTrue: [ ^nil ].
    word := WriteStream on: String new.
    [
	ch := stream peek.
	ch isSeparator ifTrue: [ ^word contents ].
	(extraDelimiters includes: ch) ifTrue: [ ^word contents ].
	word nextPut: stream next.
	stream atEnd ifTrue: [ ^word contents ].
    ] repeat.
!

hierarchyOfTestSuitesFrom: aTestCase 
    | subSuite |
    subSuite := TestSuite new.
    aTestCase isAbstract ifFalse: [ subSuite addTest: aTestCase suite ].
	aTestCase allSubclasses do: [:each |
	each isAbstract ifFalse: [ subSuite addTest: each suite ]
    ].
    ^subSuite
!

setScript: aString
    variables := Dictionary new.
    script := aString!

skipComments
    [ stream peekFor: $" ] whileTrue: [ stream skipTo: $" ].
! !

!TestSuitesScripter methodsFor: 'Scripting'!

value
    | suite subSuite token |
    suite := TestSuite new.
    stream := ReadStream on: script. 
    [stream atEnd] whileFalse: 
	[token := self getNextToken.
	token notNil ifTrue: [
	    subSuite := self singleSuiteScript: token.
	    subSuite notNil ifTrue: [suite addTest: subSuite]]].
    ^suite! !

