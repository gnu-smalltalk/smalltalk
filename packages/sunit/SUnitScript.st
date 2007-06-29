"======================================================================
|
|   SUnit testing framework scripting system
|
|   This file is in the public domain.
|
 ======================================================================"

Object subclass: #TestSuitesScripter
    instanceVariableNames: 'script stream'
    classVariableNames: ''
    poolDictionaries: ''
    category: 'SUnit'
!

!TestSuitesScripter class methodsFor: 'Init / Release'!

run: script quiet: quiet verbose: verbose
    | suite result |
    suite := TestSuitesScripter run: script.

    "Set log policy to write to stdout."
    quiet
        ifTrue: [ suite logPolicy: TestLogPolicy null ].
    verbose
        ifTrue: [ suite logPolicy: (TestVerboseLog on: stdout) ].
    (quiet or: [ verbose ])
        ifFalse: [ suite logPolicy: (TestCondensedLog on: stdout) ].

    result := suite run.

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

run: aString
    ^(self script: aString) value!

script: aString
    ^self new setScript: aString! !

!TestSuitesScripter methodsFor: 'Printing'!

printOn: aStream
    super printOn: aStream.
    script isNil ifTrue: [ ^self ].
    aStream nextPut: $<; nextPutAll: script; nextPut: $>
! !

!TestSuitesScripter methodsFor: 'Private'!

executeSingleSuiteScript: aString 
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

getNextToken
    [stream atEnd not and: [stream peek first = $"]] whileTrue: [self skipComment].
    ^stream atEnd not
	ifTrue: [stream next]
	ifFalse: [nil]
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
    script := aString!

skipComment
    | token inComment |
    token := stream next.
    token size > 1 & (token last = $") ifTrue: [^nil].
    inComment := true.
    [inComment & stream atEnd not]
	whileTrue: 
	    [token := stream next.
	    token last = $" ifTrue: [inComment := false]]
! !

!TestSuitesScripter methodsFor: 'Scripting'!

value
    | suite subSuite token |
    suite := TestSuite new.
    stream := ReadStream on: script sunitSubStrings. 
    [stream atEnd] whileFalse: 
	[token := self getNextToken.
	token notNil ifTrue: [
	    subSuite := self executeSingleSuiteScript: token.
	    subSuite notNil ifTrue:[suite addTest: subSuite]]].
    ^suite! !

