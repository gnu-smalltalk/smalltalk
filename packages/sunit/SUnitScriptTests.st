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

