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



Object subclass: RBToken [
    | sourcePointer |
    
    <category: 'Refactory-Parser'>
    <comment: nil>

    RBToken class >> start: anInterval [
	<category: 'instance creation'>
	^self new start: anInterval
    ]

    compiler: aCompiler [
	"do nothing by default"

	<category: 'accessing'>
	
    ]

    length [
	<category: 'accessing'>
	^self subclassResponsibility
    ]

    removePositions [
	<category: 'accessing'>
	sourcePointer := nil
    ]

    start [
	<category: 'accessing'>
	^sourcePointer
    ]

    stop [
	<category: 'accessing'>
	^self start + self length - 1
    ]

    start: anInteger [
	<category: 'initialize-release'>
	sourcePointer := anInteger
    ]

    printOn: aStream [
	<category: 'printing'>
	aStream
	    nextPut: $ ;
	    nextPutAll: self class name
    ]

    isAssignment [
	<category: 'testing'>
	^false
    ]

    isBinary [
	<category: 'testing'>
	^false
    ]

    isCompileTimeBound [
	<category: 'testing'>
	^false
    ]

    isIdentifier [
	<category: 'testing'>
	^false
    ]

    isKeyword [
	<category: 'testing'>
	^false
    ]

    isLiteral [
	<category: 'testing'>
	^false
    ]

    isOptimized [
	<category: 'testing'>
	^false
    ]

    isPatternVariable [
	<category: 'testing'>
	^false
    ]

    isPatternBlock [
	<category: 'testing'>
	^false
    ]

    isSpecial [
	<category: 'testing'>
	^false
    ]

    isValue [
	<category: 'accessing'>
	^false
    ]
]



RBToken subclass: RBValueToken [
    | value |
    
    <category: 'Refactory-Parser'>
    <comment: nil>

    RBValueToken class >> value: aString start: anInteger [
	<category: 'instance creation'>
	^self new value: aString start: anInteger
    ]

    isValue [
	<category: 'accessing'>
	^true
    ]

    value [
	<category: 'accessing'>
	^value
    ]

    value: anObject [
	<category: 'accessing'>
	value := anObject
    ]

    value: aString start: anInteger [
	<category: 'initialize-release'>
	value := aString.
	sourcePointer := anInteger
    ]

    printOn: aStream [
	<category: 'printing'>
	super printOn: aStream.
	aStream nextPut: $(.
	value printOn: aStream.
	aStream nextPutAll: ')'
    ]

    length [
	<category: 'private'>
	^value size
    ]
]



RBToken subclass: RBAssignmentToken [
    
    <category: 'Refactory-Parser'>
    <comment: nil>

    length [
	<category: 'private'>
	^2
    ]

    isAssignment [
	<category: 'testing'>
	^true
    ]
]



RBValueToken subclass: RBLiteralToken [
    | stopPosition |
    
    <category: 'Refactory-Parser'>
    <comment: nil>

    RBLiteralToken class >> value: anObject [
	<category: 'instance creation'>
	| literal |
	literal := anObject class == Array 
		    ifTrue: [anObject collect: [:each | self value: each]]
		    ifFalse: [anObject].
	^self 
	    value: literal
	    start: nil
	    stop: nil
    ]

    RBLiteralToken class >> value: aString start: anInteger stop: stopInteger [
	<category: 'instance creation'>
	^self new 
	    value: aString
	    start: anInteger
	    stop: stopInteger
    ]

    compiler: aCompiler [
	<category: 'accessing'>
	value class == Array 
	    ifTrue: [value do: [:each | each compiler: aCompiler]]
    ]

    realValue [
	<category: 'accessing'>
	^value class == Array 
	    ifTrue: [value collect: [:each | each realValue]]
	    ifFalse: [value]
    ]

    stop: anObject [
	<category: 'accessing'>
	stopPosition := anObject
    ]

    value: aString start: anInteger stop: stopInteger [
	<category: 'initialize-release'>
	value := aString.
	sourcePointer := anInteger.
	stopPosition := stopInteger
    ]

    length [
	<category: 'private'>
	^stopPosition - self start + 1
    ]

    isLiteral [
	<category: 'testing'>
	^true
    ]
]



RBLiteralToken subclass: RBBindingToken [
    | compiler association |
    
    <category: 'Refactory-Parser'>
    <comment: nil>

    compiler: aCompiler [
	<category: 'accessing'>
	compiler := aCompiler
    ]

    isCompileTimeBound [
	<category: 'accessing'>
	^true
    ]

    realValue [
	<category: 'accessing'>
	association notNil ifTrue: [^association].
	compiler isNil ifTrue: [^self value].
	^association := compiler bindingOf: (self value substrings: $.)
    ]
]



RBValueToken subclass: RBBinarySelectorToken [
    
    <category: 'Refactory-Parser'>
    <comment: nil>

    isBinary [
	<category: 'testing'>
	^true
    ]
]



RBValueToken subclass: RBSpecialCharacterToken [
    
    <category: 'Refactory-Parser'>
    <comment: nil>

    length [
	<category: 'private'>
	^1
    ]

    isSpecial [
	<category: 'testing'>
	^true
    ]
]



RBValueToken subclass: RBIdentifierToken [
    
    <category: 'Refactory-Parser'>
    <comment: nil>

    isIdentifier [
	<category: 'testing'>
	^true
    ]

    isPatternVariable [
	<category: 'testing'>
	^value first == RBScanner patternVariableCharacter
    ]
]



RBValueToken subclass: RBKeywordToken [
    
    <category: 'Refactory-Parser'>
    <comment: nil>

    isKeyword [
	<category: 'testing'>
	^true
    ]

    isPatternVariable [
	<category: 'testing'>
	^value first == RBScanner patternVariableCharacter
    ]
]



RBToken subclass: RBOptimizedToken [
    
    <category: 'Refactory-Scanner'>
    <comment: nil>

    isOptimized [
	<category: 'testing'>
	^true
    ]

    length [
	<category: 'testing'>
	^3
    ]
]



RBValueToken subclass: RBPatternBlockToken [
    
    <category: 'Refactory-Scanner'>
    <comment: nil>

    isPatternBlock [
	<category: 'testing'>
	^true
    ]
]

