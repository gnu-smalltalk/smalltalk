Exception subclass: TestFailure [
    
    <category: 'SUnitPreload'>
    <comment: nil>
]



Delay subclass: SUnitDelay [
    
    <category: 'SUnitPreload'>
    <comment: nil>
]



TestFailure subclass: ResumableTestFailure [
    
    <category: 'SUnitPreload'>
    <comment: nil>

    sunitExitWith: aValue [
	<category: 'Camp Smalltalk'>
	^self resume: aValue
    ]
]



Object subclass: SUnitNameResolver [
    
    <category: 'SUnitPreload'>
    <comment: nil>

    SUnitNameResolver class >> classNamed: aSymbol [
	<category: 'Camp Smalltalk'>
	^(aSymbol substrings: $.) inject: Smalltalk
	    into: [:space :key | space at: key asSymbol ifAbsent: [^nil]]
    ]

    SUnitNameResolver class >> defaultLogDevice [
	<category: 'Camp Smalltalk'>
	^Transcript
    ]

    SUnitNameResolver class >> errorObject [
	<category: 'Camp Smalltalk'>
	^Error
    ]

    SUnitNameResolver class >> mnuExceptionObject [
	<category: 'Camp Smalltalk'>
	^MessageNotUnderstood
    ]

    SUnitNameResolver class >> notificationObject [
	<category: 'Camp Smalltalk'>
	^Notification
    ]
]



Object extend [

    sunitAddDependent: anObject [
	<category: 'Camp Smalltalk'>
	self addDependent: anObject
    ]

    sunitChanged: aspect [
	<category: 'Camp Smalltalk'>
	self changed: aspect
    ]

    sunitRemoveDependent: anObject [
	<category: 'Camp Smalltalk'>
	self removeDependent: anObject
    ]

]



BlockClosure extend [

    sunitEnsure: aBlock [
	<category: 'Camp Smalltalk'>
	^self ensure: aBlock
    ]

    sunitOn: aSignal do: anExceptionBlock [
	<category: 'Camp Smalltalk'>
	^self on: aSignal do: anExceptionBlock
    ]

]



Behavior extend [

    sunitAllSelectors [
	<category: 'Camp Smalltalk'>
	^self allSelectors asSortedCollection asOrderedCollection
    ]

    sunitSelectors [
	<category: 'Camp Smalltalk'>
	^self selectors asSortedCollection asOrderedCollection
    ]

]



String extend [

    sunitAsSymbol [
	<category: 'Camp Smalltalk'>
	^self asSymbol
    ]

    sunitMatch: aString [
	<category: 'Camp Smalltalk'>
	^self match: aString
    ]

    sunitSubStrings [
	<category: 'Camp Smalltalk'>
	^self substrings
    ]

]



Exception class extend [

    sunitSignalWith: aString [
	<category: 'Camp Smalltalk'>
	^self signal: aString
    ]

]



Exception extend [

    sunitExitWith: aValue [
	<category: 'Camp Smalltalk'>
	^self return: aValue
    ]

]



String extend [

    sunitAsClass [
	<category: 'Camp Smalltalk'>
	^SUnitNameResolver classNamed: self
    ]

]



Class extend [

    sunitName [
	<category: 'Camp Smalltalk'>
	^self name
    ]

]

