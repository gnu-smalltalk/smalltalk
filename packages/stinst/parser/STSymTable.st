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
	map := Dictionary new: aSize.
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
	pools addAll: poolDictionary withAllSuperspaces
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
	| behavior |
	behavior := environment.

	"Find a suitable Class object from the given behavior"
	behavior isMetaclass ifTrue: [behavior := behavior instanceClass].
	[behavior isClass] whileFalse: 
		[behavior := behavior superclass.
		behavior isNil ifTrue: [^self]].
	behavior withAllSuperclassesDo: 
		[:class | 
		self addPool: class environment.
		class classPool isEmpty ifFalse: [pools add: class classPool]].
	behavior withAllSuperclassesDo: 
		[:class | 
		| dicts |
		dicts := class sharedPoolDictionaries.
		dicts isNil ifFalse: [dicts do: [:sp | self addPool: sp]]]
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
		assoc := assoc value associationAt: each asSymbol
			    ifAbsent: 
				[| symbol |
				i < namesArray size ifTrue: [self invalidScopeResolution: stCompiler].

				"Last item, add to Undeclared"
				^self lookupUndeclared: each asSymbol]].
	^assoc
    ]

    lookupPoolsFor: symbol [
	<category: 'accessing'>
	pools do: 
		[:pool | 
		| assoc |
		assoc := pool associationAt: symbol ifAbsent: [nil].
		assoc isNil ifFalse: [^assoc]].
	^nil
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
	pools := OrderedSet identityNew: 7.
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



Eval [
    STSymbolTable initialize
]

