Exception subclass: #TestFailure
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'SUnitPreload'!

Delay subclass: #SUnitDelay
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'SUnitPreload'!

TestFailure subclass: #ResumableTestFailure
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'SUnitPreload'!

Object subclass: #SUnitNameResolver
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'SUnitPreload'!

!Object methodsFor: 'Camp Smalltalk'!

sunitAddDependent: anObject
    self addDependent: anObject!

sunitChanged: aspect
    self changed: aspect!

sunitRemoveDependent: anObject
    self removeDependent: anObject! !

!BlockClosure methodsFor: 'Camp Smalltalk'!

sunitEnsure: aBlock 
    ^self ensure: aBlock!

sunitOn: aSignal do: anExceptionBlock 
    ^self on: aSignal do: anExceptionBlock! !

!Behavior methodsFor: 'Camp Smalltalk'!

sunitAllSelectors
    ^self allSelectors asSortedCollection asOrderedCollection!

sunitSelectors
    ^self selectors asSortedCollection asOrderedCollection! !

!String methodsFor: 'Camp Smalltalk'!

sunitAsSymbol
    ^self asSymbol!

sunitMatch: aString
    ^self match: aString!

sunitSubStrings
    ^self substrings! !

!SUnitNameResolver class methodsFor: 'Camp Smalltalk'!

classNamed: aSymbol
    ^(aSymbol substrings: $.) inject: Smalltalk
        into: [ :space :key | (space at: key asSymbol ifAbsent: [ ^nil ]) ]!

defaultLogDevice
    ^Transcript!

errorObject
    ^Error!

mnuExceptionObject
    ^MessageNotUnderstood!

notificationObject
    ^Notification! !

!Exception class methodsFor: 'Camp Smalltalk'!

sunitSignalWith: aString
    ^self signal: aString! !

!Exception methodsFor: 'Camp Smalltalk'!

sunitExitWith: aValue
    self resetHandler; return: aValue! !

!ResumableTestFailure methodsFor: 'Camp Smalltalk'!

sunitExitWith: aValue
    ^self resume: aValue! !

!String methodsFor: 'Camp Smalltalk'!

sunitAsClass
    ^SUnitNameResolver classNamed: self! !

!Class methodsFor: 'Camp Smalltalk'!

sunitName
    ^self name! !
