"======================================================================
|
|   SUnit testing framework scripting system
|
|   This file is in the public domain.
|
 ======================================================================"

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

suiteFor: aScript
    ^(TestSuitesScripter script: aScript) value!

compile: aScript
    ^(TestSuitesScripter script: aScript) value; yourself!

testCompoundScript
    | allTestCaseClasses superCase subCase |
    allTestCaseClasses := (self suiteFor: 'TestSuitesHierarchyScriptTest TestSuitesCompoundScriptTest') tests. 
    self assert: allTestCaseClasses size = 2.
    superCase := (allTestCaseClasses at: 1) tests first.
    self assert: superCase class sunitName sunitAsSymbol = #TestSuitesHierarchyScriptTest.
    subCase := (allTestCaseClasses at: 2) tests first.
    self assert: subCase class sunitName sunitAsSymbol = #TestSuitesCompoundScriptTest.
!

testEmbeddedNameCommentScript
    | suite |
    suite := self suiteFor: ' "This comment contains the name of a SUnitTest Case"  TestSuitesScriptTest'.
    self assert: suite tests size = 1
!

testEmptyCommentScript
    | suite |
    suite := self suiteFor: ' " " TestSuitesScriptTest'.
    self assert: suite tests size = 1
!

testEmptyHierarchyScript
    | suite |
    suite := self suiteFor: '*'.
    self assert: suite tests isEmpty
!

testEmptyScript
    | suite |
    suite := self suiteFor: ''.
    self assert: suite tests isEmpty
!

testHierarchyScript
    | allTestCaseClasses superCase subCase suite |
    suite := self suiteFor: 'TestSuitesHierarchyScriptTest*'.
    allTestCaseClasses := suite tests. 
    self assert: allTestCaseClasses size = 1.
    superCase := (allTestCaseClasses first tests at: 1) tests first.
    self assert: superCase class sunitName sunitAsSymbol = #TestSuitesHierarchyScriptTest.
    subCase := (allTestCaseClasses first tests at: 2) tests first.
    self assert: subCase class sunitName sunitAsSymbol = #TestSuitesCompoundScriptTest.
!

testOpenCommentScript
    | suite |
    suite := self suiteFor: ' "SUnitTest'.
    self assert: suite tests isEmpty
!

testSimpleScript
    | allTestCaseClasses case suite |
    suite := self suiteFor: 'TestSuitesHierarchyScriptTest'.
    allTestCaseClasses := suite tests.
    self assert: allTestCaseClasses size = 1.
    case := (allTestCaseClasses at: 1) tests at: 1.
    self assert: case class sunitName sunitAsSymbol = #TestSuitesHierarchyScriptTest.
!

testSingleWordCommentScript
    | suite |
    suite := self suiteFor: ' "SUnitTest" TestSuitesScriptTest'.
    self assert: suite tests size = 1
!

testTwoCommentsScript
    | suite |
    suite := self suiteFor: ' " SUnitTest "  " SUnitTest " TestSuitesScriptTest'.
    self assert: suite tests size = 1.
    suite := self suiteFor: ' " SUnitTest "" SUnitTest " TestSuitesScriptTest'.
    self assert: suite tests size = 1
!

testStringVariableScript
    | scripter |
    scripter := self compile: 'var1=''value'' var2=''''''quoted "not SUnitTest and not a comment"
'''''' TestSuitesScriptTest'.
    self assert: (scripter variableAt: 'var1' ifAbsent: [ 42 ]) = 'value'.
    self assert: (scripter variableAt: 'var2' ifAbsent: [ 42 ]) = '''quoted "not SUnitTest and not a comment"
'''.
    self assert: (scripter variableAt: 'var3' ifAbsent: [ 42 ]) = 42.
    self assert: scripter value tests size = 1
!

testVariableScript
    | scripter |
    scripter := self compile: ' var1=value TestSuitesScriptTest'.
    self assert: (scripter variableAt: 'var1' ifAbsent: [ 42 ]) = 'value'.
    self assert: (scripter variableAt: 'var2' ifAbsent: [ 42 ]) = 42.
    self assert: scripter value tests size = 1
!

testEmptyVariableScript
    | scripter |
    scripter := self compile: ' var1= TestSuitesScriptTest'.
    self assert: (scripter variableAt: 'var1' ifAbsent: [ 42 ]) = ''.
    self assert: (scripter variableAt: 'var2' ifAbsent: [ 42 ]) = 42.
    self assert: scripter value tests size = 1
! !

