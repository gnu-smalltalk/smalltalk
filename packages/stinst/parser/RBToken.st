"======================================================================
|
|   Refactoring Browser - Token classes
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1998-2000 The Refactory, Inc.
|
| This file is distributed together with GNU Smalltalk.
|
 ======================================================================"


Object subclass: #RBToken
    instanceVariableNames: 'sourcePointer '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Refactory-Parser'!



!RBToken methodsFor: 'accessing'!

compiler: aCompiler
    "do nothing by default"!

length
    ^self subclassResponsibility!

removePositions
    sourcePointer := nil!

start
    ^sourcePointer!

stop
    ^self start + self length - 1! !

!RBToken methodsFor: 'initialize-release'!

start: anInteger 
    sourcePointer := anInteger! !

!RBToken methodsFor: 'printing'!

printOn: aStream 
    aStream
	nextPut: $ ;
	nextPutAll: self class name! !

!RBToken methodsFor: 'testing'!

isAssignment
    ^false!

isBinary
    ^false!

isCompileTimeBound
    ^false!

isIdentifier
    ^false!

isKeyword
    ^false!

isLiteral
    ^false!

isOptimized
    ^false!

isPatternVariable
    ^false!

isPatternBlock
    ^false!

isSpecial
    ^false! !

RBToken class
    instanceVariableNames: ''!



!RBToken class methodsFor: 'instance creation'!

start: anInterval 
    ^self new start: anInterval! !


RBToken subclass: #RBValueToken
    instanceVariableNames: 'value '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Refactory-Parser'!



!RBValueToken methodsFor: 'accessing'!

value
    ^value!

value: anObject
    value := anObject! !

!RBValueToken methodsFor: 'initialize-release'!

value: aString start: anInteger 
    value := aString.
    sourcePointer := anInteger! !

!RBValueToken methodsFor: 'printing'!

printOn: aStream
    super printOn: aStream.
    aStream nextPut: $(.
    value printOn: aStream.
    aStream nextPutAll: ')'! !

!RBValueToken methodsFor: 'private'!

length
    ^value size! !

RBValueToken class
    instanceVariableNames: ''!



!RBValueToken class methodsFor: 'instance creation'!

value: aString start: anInteger 
    ^self new value: aString start: anInteger! !


RBToken subclass: #RBAssignmentToken
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Refactory-Parser'!



!RBAssignmentToken methodsFor: 'private'!

length
    ^2! !

!RBAssignmentToken methodsFor: 'testing'!

isAssignment
    ^true! !

RBAssignmentToken class
    instanceVariableNames: ''!



RBValueToken subclass: #RBLiteralToken
    instanceVariableNames: 'stopPosition '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Refactory-Parser'!



!RBLiteralToken methodsFor: 'accessing'!

compiler: aCompiler
    value class == Array
	ifTrue: [ value do: [ :each | each compiler: aCompiler ] ]!

realValue
    ^value class == Array
	ifTrue: [value collect: [:each | each realValue]]
	ifFalse: [value]!

stop: anObject 
    stopPosition := anObject! !

!RBLiteralToken methodsFor: 'initialize-release'!

value: aString start: anInteger stop: stopInteger 
    value := aString.
    sourcePointer := anInteger.
    stopPosition := stopInteger! !

!RBLiteralToken methodsFor: 'private'!

length
    ^stopPosition - self start + 1! !

!RBLiteralToken methodsFor: 'testing'!

isLiteral
    ^true! !

RBLiteralToken class
    instanceVariableNames: ''!



!RBLiteralToken class methodsFor: 'instance creation'!

value: anObject 
    | literal |
    literal := anObject class == Array 
		ifTrue: [anObject collect: [:each | self value: each]]
		ifFalse: [anObject].
    ^self 
	value: literal
	start: nil
	stop: nil!

value: aString start: anInteger stop: stopInteger 
    ^self new
	value: aString
	start: anInteger
	stop: stopInteger! !


RBLiteralToken subclass: #RBBindingToken
    instanceVariableNames: 'compiler association'
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Refactory-Parser'!



!RBBindingToken methodsFor: 'accessing'!

compiler: aCompiler
    compiler := aCompiler!

isCompileTimeBound
    ^true!

realValue
    association notNil ifTrue: [ ^association ].
    compiler isNil ifTrue: [ ^self value ].
    ^association := compiler bindingOf: (self value substrings: $.)! !

RBValueToken subclass: #RBBinarySelectorToken
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Refactory-Parser'!



!RBBinarySelectorToken methodsFor: 'testing'!

isBinary
    ^true! !

RBBinarySelectorToken class
    instanceVariableNames: ''!



RBValueToken subclass: #RBSpecialCharacterToken
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Refactory-Parser'!



!RBSpecialCharacterToken methodsFor: 'private'!

length
    ^1! !

!RBSpecialCharacterToken methodsFor: 'testing'!

isSpecial
    ^true! !

RBSpecialCharacterToken class
    instanceVariableNames: ''!



RBValueToken subclass: #RBIdentifierToken
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Refactory-Parser'!



!RBIdentifierToken methodsFor: 'testing'!

isIdentifier
    ^true!

isPatternVariable
    ^value first == RBScanner patternVariableCharacter! !

RBIdentifierToken class
    instanceVariableNames: ''!



RBValueToken subclass: #RBKeywordToken
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Refactory-Parser'!



!RBKeywordToken methodsFor: 'testing'!

isKeyword
    ^true!

isPatternVariable
    ^value first == RBScanner patternVariableCharacter! !

RBKeywordToken class
    instanceVariableNames: ''!


RBToken subclass: #RBOptimizedToken
        instanceVariableNames: ''
        classVariableNames: ''
        poolDictionaries: ''
        category: 'Refactory-Scanner'!

RBOptimizedToken class
        instanceVariableNames: ''!

!RBOptimizedToken methodsFor: 'testing'!

isOptimized
        ^true!

length
	^3! !

RBValueToken subclass: #RBPatternBlockToken
        instanceVariableNames: ''
        classVariableNames: ''
        poolDictionaries: ''
        category: 'Refactory-Scanner'!

RBPatternBlockToken class
        instanceVariableNames: ''!

!RBPatternBlockToken methodsFor: 'testing'!

isPatternBlock
        ^true! !


