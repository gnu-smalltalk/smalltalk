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

SUnitTest subclass: #TestSuitesHierarchyScriptTest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'SUnitTests'
!

!TestSuitesHierarchyScriptTest methodsFor: 'Testing'!

testRanOnlyOnce
    self assert: true
! !


TestSuitesHierarchyScriptTest subclass: #TestSuitesCompoundScriptTest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'SUnitTests'
!

!TestSuitesCompoundScriptTest methodsFor: 'Testing'!

testRanOnlyOnce
    self assert: true
! !


TestCase subclass: #TestSuitesScriptTest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'SUnitTests'
!

!TestSuitesScriptTest methodsFor: 'Testing'!

testCompoundScript
    | allTestCaseClasses superCase subCase |
    allTestCaseClasses := (TestSuitesScripter run: 'TestSuitesHierarchyScriptTest TestSuitesCompoundScriptTest') tests. 
    self assert: allTestCaseClasses size = 2.
    superCase := (allTestCaseClasses at: 1) tests first.
    self assert: superCase class sunitName sunitAsSymbol = #TestSuitesHierarchyScriptTest.
    subCase := (allTestCaseClasses at: 2) tests first.
    self assert: subCase class sunitName sunitAsSymbol = #TestSuitesCompoundScriptTest.
!

testEmbeddedNameCommentScript
    | suite |
    suite := TestSuitesScripter run: ' "This comment contains the name of a SUnitTest Case"  TestSuitesScriptTest'.
    self assert: suite tests size = 1
!

testEmptyCommentScript
    | suite |
    suite := TestSuitesScripter run: ' " " TestSuitesScriptTest'.
    self assert: suite tests size = 1
!

testEmptyHierarchyScript
    | suite |
    suite := TestSuitesScripter run: '*'.
    self assert: suite tests isEmpty
!

testEmptyScript
    | suite |
    suite := TestSuitesScripter run: ''.
    self assert: suite tests isEmpty
!

testHierarchyScript
    | allTestCaseClasses superCase subCase suite |
    suite := TestSuitesScripter run: 'TestSuitesHierarchyScriptTest*'.
    allTestCaseClasses := suite tests. 
    self assert: allTestCaseClasses size = 1.
    superCase := (allTestCaseClasses first tests at: 1) tests first.
    self assert: superCase class sunitName sunitAsSymbol = #TestSuitesHierarchyScriptTest.
    subCase := (allTestCaseClasses first tests at: 2) tests first.
    self assert: subCase class sunitName sunitAsSymbol = #TestSuitesCompoundScriptTest.
!

testOpenCommentScript
    | suite |
    suite := TestSuitesScripter run: ' "SUnitTest'.
    self assert: suite tests isEmpty
!

testSimpleScript
    | allTestCaseClasses case suite |
    suite := TestSuitesScripter run: 'TestSuitesHierarchyScriptTest'.
    allTestCaseClasses := suite tests.
    self assert: allTestCaseClasses size = 1.
    case := (allTestCaseClasses at: 1) tests at: 1.
    self assert: case class sunitName sunitAsSymbol = #TestSuitesHierarchyScriptTest.
!

testSingleWordCommentScript
    | suite |
    suite := TestSuitesScripter run: ' "SUnitTest" TestSuitesScriptTest'.
    self assert: suite tests size = 1
!

testTwoCommentsScript
    | suite |
    suite := TestSuitesScripter run: ' " SUnitTest "  " SUnitTest " TestSuitesScriptTest'.
    self assert: suite tests size = 1
! !

