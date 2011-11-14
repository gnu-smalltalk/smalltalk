"======================================================================
|
|   Smalltalk in Smalltalk compiler symbol table
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1995,1999,2000,2001,2002,2006,2007,2008 Free Software Foundation, Inc.
| Written by Steve Byrne.
|
| This file is part of GNU Smalltalk.
|
| GNU Smalltalk is free software; you can redistribute it and/or modify it
| under the terms of the GNU General Public License as published by the Free
| Software Foundation; either version 2, or (at your option) any later version.
| 
| GNU Smalltalk is distributed in the hope that it will be useful, but WITHOUT
| ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
| FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
| details.
| 
| You should have received a copy of the GNU General Public License along with
| GNU Smalltalk; see the file COPYING.  If not, write to the Free Software
| Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
|
 ======================================================================"



Collection extend [
    literalHash [
        <category: 'compiler'>
        ^self identityHash
    ]

    literalEquals: anObject [
        <category: 'compiler'>
        ^self == anObject
    ]
]

VariableBinding extend [
    literalHash [
        <category: 'compiler'>
        ^self identityHash
    ]

    literalEquals: anObject [
        <category: 'compiler'>
        ^self == anObject
    ]
]

ArrayedCollection extend [
    literalHash [
        <category: 'compiler'>
        ^self size bitXor: self class hash
    ]

    literalEquals: anObject [
        <category: 'compiler'>
        self == anObject ifTrue: [^true].
        self size = anObject size ifFalse: [^false].
        self class = anObject class ifFalse: [^false].
        1 to: self size do: [ :i |
            ((self at: i) literalEquals: (anObject at: i))
                ifFalse: [^false] ].
        ^true
    ]
]

Float extend [
    literalHash [
        <category: 'compiler'>
        ^self primHash
    ]

    literalEquals: anObject [
        <category: 'compiler'>
        self size = anObject size ifFalse: [^false].
        self class = anObject class ifFalse: [^false].
        1 to: self size do: [ :i |
            ((self at: i) literalEquals: (anObject at: i))
                ifFalse: [^false] ].
        ^true
    ]
]

Object extend [
    literalHash [
        <category: 'compiler'>
        ^self hash
    ]

    literalEquals: anObject [
        <category: 'compiler'>
        ^self = anObject
    ]
]


LookupTable subclass: LiteralDictionary [
    
    <shape: #pointer>
    <category: 'Collections-Keyed'>
    <comment: 'I am similar to LookupTable, except that I use the 
comparison message #literalEquals: to determine equivalence of objects.'>

    keysClass [
	"Answer the class answered by #keys"

	<category: 'private methods'>
	^IdentitySet
    ]

    hashFor: anObject [
	"Return an hash value for the item, anObject"

	<category: 'private methods'>
	^anObject literalHash
    ]

    findIndex: anObject [
	"Tries to see if anObject exists as an indexed variable. As soon as nil
	 or anObject is found, the index of that slot is answered"

	<category: 'private methods'>
	| index size element |
	"Sorry for the lack of readability, but I want speed... :-)"
	index := (anObject literalHash scramble 
		    bitAnd: (size := self primSize) - 1) + 1.
	
	[((element := self primAt: index) isNil or: [element literalEquals: anObject])
	    ifTrue: [^index].
	index == size ifTrue: [index := 1] ifFalse: [index := index + 1]] 
		repeat
    ]
]


Object subclass: STLiteralsTable [
    | map array |
    
    <category: 'System-Compiler'>
    <comment: nil>

    STLiteralsTable class >> new: aSize [
	<category: 'instance creation'>
	^self new initialize: aSize
    ]

    addLiteral: anObject [
	"Answers the index of the given literal.  If the literal is already
	 present in the literals, returns the index of that one."

	<category: 'accessing'>
	^map at: anObject
	    ifAbsentPut: 
		["Grow the array when full"

		| newArray |
		array size = map size 
		    ifTrue: 
			[(newArray := Array new: map size * 2) 
			    replaceFrom: 1
			    to: map size
			    with: array
			    startingAt: 1.
			array become: newArray].
		array at: map size + 1 put: anObject.
		map size]
    ]

    literals [
	<category: 'accessing'>
	^array
    ]

    trim [
	<category: 'accessing'>
	array become: (array copyFrom: 1 to: map size)
    ]

    initialize: aSize [
	<category: 'private'>
	map := LiteralDictionary new: aSize.
	array := Array new: aSize
    ]
]



Object subclass: STVariable [
    | id scope canStore |
    
    <category: 'System-Compiler'>
    <comment: nil>

    STVariable class >> id: id scope: scope canStore: canStore [
	<category: 'instance creation'>
	^self new 
	    id: id
	    scope: scope
	    canStore: canStore
    ]

    canStore [
	<category: 'accessing'>
	^canStore
    ]

    id [
	<category: 'accessing'>
	^id
    ]

    id: anObject scope: scopeIndex canStore: aBoolean [
	<category: 'accessing'>
	id := anObject.
	scope := scopeIndex.
	canStore := aBoolean
    ]

    scope [
	<category: 'accessing'>
	^scope
    ]
]



Object subclass: STSymbolTable [
    | variables tempCount litTable pools instVars environment scopes scopeVariables |
    
    <category: 'System-Compiler'>
    <comment: nil>

    UseUndeclared := nil.

    STSymbolTable class >> initialize [
	<category: 'accessing'>
	UseUndeclared := 0
    ]

    STSymbolTable class >> insideFilein [
	<category: 'accessing'>
	^UseUndeclared > 0
    ]

    STSymbolTable class >> nowInsideFileIn [
	<category: 'accessing'>
	UseUndeclared := UseUndeclared + 1
    ]

    STSymbolTable class >> nowOutsideFileIn [
	<category: 'accessing'>
	UseUndeclared := UseUndeclared - 1
    ]

    STSymbolTable class >> new [
	<category: 'instance creation'>
	^super new init
    ]

    addPool: poolDictionary [
	<category: 'declaring'>
	pools addPoolLast: poolDictionary
    ]

    declareEnvironment: aBehavior [
	<category: 'declaring'>
	| i canAlwaysStore inSandbox |
	environment := aBehavior.
	inSandbox := thisContext isUntrusted.
	i := -1.
	canAlwaysStore := aBehavior isUntrusted.
	aBehavior withAllSuperclasses reverseDo: 
		[:class | 
		canAlwaysStore := canAlwaysStore and: [class isUntrusted].
		class instVarNames do: 
			[:iv | 
			instVars at: iv asSymbol
			    put: (STVariable 
				    id: (i := i + 1)
				    scope: 0
				    canStore: (canAlwaysStore or: [inSandbox not]))]].
	self declareGlobals
    ]

    declareGlobals [
	<category: 'declaring'>
	pools := environment poolResolution of: environment.
    ]

    declareTemporary: tempName canStore: canStore for: stCompiler [
	<category: 'declaring'>
	| symbol |
	symbol := tempName asSymbol.
	(variables includesKey: symbol) 
	    ifTrue: 
		[(variables at: symbol) scope < scopes size 
		    ifTrue: 
			[stCompiler compileWarning: 'variable ''%1'' shadows another' % {tempName}]
		    ifFalse: [^stCompiler compileError: 'duplicate variable name ' , tempName]].
	variables at: symbol
	    put: (STVariable 
		    id: tempCount
		    scope: scopes size
		    canStore: canStore).
	tempCount := tempCount + 1.
	^tempCount - 1
    ]

    scopeEnter [
	<category: 'declaring'>
	scopes add: tempCount.
	tempCount := 0.
	scopeVariables add: variables.
	variables := variables copy
    ]

    scopeLeave [
	"Answer whether we are in a `clean' scope (no return from method, no
	 references to variable in an outer scope)."

	<category: 'declaring'>
	tempCount := scopes removeLast.
	variables := scopeVariables removeLast
    ]

    undeclareTemporary: tempName [
	<category: 'declaring'>
	variables removeKey: tempName asSymbol ifAbsent: []
    ]

    addLiteral: aLiteral [
	"Answers the index of the given literal.  If the literal is already
	 present in the litTable, returns the index of that one."

	<category: 'declaring'>
	^litTable addLiteral: aLiteral
    ]

    canStore: aName [
	<category: 'accessing'>
	| var |
	var := variables at: aName asSymbol ifAbsent: [nil].
	var isNil ifFalse: [^var canStore].
	var := instVars at: aName asSymbol ifAbsent: [nil].
	var isNil ifFalse: [^var canStore].
	^true
    ]

    environment [
	<category: 'accessing'>
	^environment
    ]

    numTemps [
	<category: 'accessing'>
	^tempCount
    ]

    isTemporary: aName [
	<category: 'accessing'>
	^variables includesKey: aName asSymbol
    ]

    isReceiver: aName [
	<category: 'accessing'>
	^instVars includesKey: aName asSymbol
    ]

    outerScopes: aName [
	<category: 'accessing'>
	| value |
	value := variables at: aName asSymbol.
	^scopes size - value scope
    ]

    invalidScopeResolution: stCompiler [
	<category: 'accessing'>
	^stCompiler compileError: 'invalid scope resolution'
    ]

    bindingOf: namesArray for: stCompiler [
	<category: 'accessing'>
	| assoc |
	assoc := self lookupPoolsFor: (namesArray at: 1) asSymbol.
	assoc isNil ifTrue: [^nil].

	"Ok, proceed with the remaining names (if any)."
	namesArray 
	    from: 2
	    to: namesArray size
	    keysAndValuesDo: 
		[:i :each | 
		assoc := assoc value scopeDictionary associationAt: each asSymbol
			    ifAbsent: 
				[| symbol |
				i < namesArray size ifTrue: [self invalidScopeResolution: stCompiler].

				"Last item, add to Undeclared"
				^self lookupUndeclared: each asSymbol]].
	^assoc
    ]

    lookupPoolsFor: symbol [
	<category: 'accessing'>
	^pools lookupBindingOf: symbol
    ]

    lookupBindingOf: symbol [
	<category: 'accessing'>
	| assoc |
	assoc := self lookupPoolsFor: symbol.
	assoc isNil ifTrue: [^self lookupUndeclared: symbol].
	^assoc
    ]

    lookupName: aName for: stCompiler [
	"Answers a value for the name"

	<category: 'accessing'>
	| symbol value assoc index |
	index := aName indexOf: $..
	symbol := index = 0 
		    ifTrue: [aName asSymbol]
		    ifFalse: [(aName copyFrom: 1 to: index - 1) asSymbol].
	index = 0 
	    ifTrue: 
		[value := variables at: symbol ifAbsent: [nil].
		value isNil ifFalse: [^value id].
		value := instVars at: symbol ifAbsent: [nil].
		value isNil ifFalse: [^value id]].
	assoc := index = 0 
		    ifTrue: [self lookupBindingOf: symbol]
		    ifFalse: [self bindingOf: (aName substrings: $.) for: stCompiler].
	assoc isNil ifFalse: [^self addLiteral: assoc].
	^assoc
    ]

    finish [
	<category: 'accessing'>
	litTable trim
    ]

    literals [
	<category: 'accessing'>
	^litTable literals
    ]

    init [
	<category: 'private'>
	variables := Dictionary new: 5.
	litTable := STLiteralsTable new: 13.
	instVars := Dictionary new: 7.
	scopeVariables := OrderedCollection new: 5.
	scopes := OrderedCollection new: 5.
	tempCount := 0
    ]

    lookupUndeclared: symbol [
	"Answer an Association for variable symbol that will be bound
	 later, if undeclared variables are allowed and the symbol is a
	 syntactic candidate; otherwise answer nil."

	<category: 'private'>
	self class insideFilein ifFalse: [^nil].
	(symbol at: 1) isUppercase ifFalse: [^nil].
	^Undeclared associationAt: symbol ifAbsent:
	    [Undeclared add: (VariableBinding key: symbol value: nil
					      environment: Undeclared)]
    ]
]



Object subclass: PoolResolution [
    <comment: 'I resolve names into shared pool bindings on behalf of
an STSymbolTable.  I can be configured separately for each class, for
use compiling methods for that class.'>

    Current := nil.
    
    PoolResolution class >> current [
	"Answer the resolution class used by the default
	 implementation of #poolResolution on classes."
	^Current
    ]
    
    PoolResolution class >> current: aPoolResolutionClass [
	"Set the value answered by #current."
	^Current := aPoolResolutionClass
    ]

    PoolResolution class >> of: aBehavior [
	"Build a resolution for aBehavior using #declareEnvironment:
	 and #canonicalizeBehavior:."
	<category: 'instance creation'>
	| instance |
	instance := self new.
	instance declareEnvironment:
	    (instance canonicalizeBehavior: aBehavior).
	^instance
    ]

    addClassLast: aClass [
	"As with #addPoolLast:, but for a class instead.  Also as with
	 #addPoolLast:, it often makes sense to replace this
	 implementation with your own."
	<category: 'overriding'>
	| addedPool |
	addedPool := self addPoolLast: aClass classPool.
	aClass sharedPoolDictionaries do: [:sp | self addPoolLast: sp].
	aClass allSuperclassesDo: [:class |
	    self addPoolLast: class classPool.
	    class sharedPoolDictionaries do: [:sp | self addPoolLast: sp]].
	^addedPool
    ]

    addPoolLast: poolDictionary [
	"If it is sensible, add poolDictionary to the end of my pool
	 search order, setting aside whatever standards I usually use
	 to determine the search order.	 Answer whether the pool can
	 now be considered to be included in my search order.

	 My implementation does nothing; you must override it if you
	 want it."
	<category: 'overriding'>
	^false
    ]

    declareEnvironment: aBehavior [
	"Import aBehavior as the direct class that will contain the
	 method I am helping to compile.  I expect to be sent before
	 anything else in my API."
	<category: 'initializing'>
	^self subclassResponsibility
    ]

    canonicalizeBehavior: aBehavior [
	"Map aBehavior to something sensible for #declareEnvironment:.
	 By default, unmeta and then search the inheritance for a real
	 class.  If no real class is found, answer nil."
	<category: 'overriding'>
	| behavior |
	behavior := aBehavior.
	behavior isMetaclass ifTrue: [behavior := behavior instanceClass].
	[behavior isClass] whileFalse:
	    [behavior := behavior superclass.
	     behavior isNil ifTrue: [^nil]].
	^behavior
    ]

    lookupBindingOf: symbol [
	"Answer an Association for the symbol, to be #value-d to
	 resolve the variable at evaluation time, or nil if none can
	 be found."
	<category: 'accessing'>
	^self subclassResponsibility
    ]
]



PoolResolution subclass: ClassicPoolResolution [
    | pools |
    <comment: 'I provide shared pool variable resolution as it was
before the PoolResolution hierarchy was added, and TwistedPools became
default.'>

    addPoolLast: poolDictionary [
	"Add poolDictionary and all superspaces to the end of the
	 search order.	Always succeed."
	<category: 'accessing'>
	pools addAll: poolDictionary withAllSuperspaces.
	^true
    ]

    lookupBindingOf: symbol [
	"Search all pools in order (see super comment)."
	<category: 'accessing'>
	pools do: [:pool |
	    (pool scopeDictionary associationAt: symbol ifAbsent: [nil])
		ifNotNil: [:assoc | ^assoc]].
	^nil
    ]

    declareEnvironment: aBehavior [
	<category: 'initializing'>
	| behavior |
	pools := OrderedSet identityNew: 7.
	aBehavior ifNil: [^nil].
	behavior := aBehavior.
	"add all namespaces, class pools, and shared pools"
	behavior withAllSuperclassesDo: [:class |
	    self addPoolLast: class environment.
	    class classPool isEmpty ifFalse: [pools add: class classPool]].
	behavior withAllSuperclassesDo: [:class |
	    class sharedPoolDictionaries do: [:sp | self addPoolLast: sp]].
    ]
]



PoolResolution subclass: DefaultPoolResolution [
    | pools |
    <comment: 'I provide a "namespace is application" oriented method
of shared pool searching, intended to be more intuitive for those who
expect things to be found in their own namespace first.	 This is more
fully explained by my implementation, or at GNU Smalltalk wiki page
PoolResolution.'>

    addPoolLast: poolDictionary [
	"Add poolDictionary and all superspaces to the end of the
	 search order.	Always succeed."
	<category: 'accessing'>
	pools addAll: poolDictionary withAllSuperspaces.
	^true
    ]

    lookupBindingOf: symbol [
	"Search all pools in order (see super comment)."
	<category: 'accessing'>
	pools do: [:pool |
	    (pool hereAssociationAt: symbol ifAbsent: [nil])
		ifNotNil: [:assoc | ^assoc]].
	^nil
    ]

    declareEnvironment: aBehavior [
	<category: 'initializing'>
	pools := OrderedSet identityNew: 7.
	aBehavior ifNil: [^nil].
	aBehavior allSharedPoolDictionariesDo: [ :each |
	    each isEmpty ifFalse: [ pools add: each ] ]
    ]
]



Behavior extend [
    poolResolution [
	"Answer a PoolResolution class to be used for resolving pool
	 variables while compiling methods on this class."
	<category: 'compiling methods'>
	^STInST.PoolResolution current
    ]
]
    
    
Metaclass extend [
    poolResolution [
	"Use my instance's poolResolution."
	<category: 'compiling methods'>
	^self instanceClass poolResolution
    ]
]



Eval [
    STSymbolTable initialize.
    PoolResolution current: DefaultPoolResolution.
]

