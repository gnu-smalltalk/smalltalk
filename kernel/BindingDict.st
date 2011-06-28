"======================================================================
|
|   BindingDictionary Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999, 2000, 2001, 2002, 2003, 2008 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of the GNU Smalltalk class library.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU Lesser General Public License
| as published by the Free Software Foundation; either version 2.1, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
| General Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"



Dictionary subclass: BindingDictionary [
    | environment |
    
    <shape: #pointer>
    <category: 'Language-Implementation'>
    <comment: 'I am a special form of dictionary that provides special ways to access my
keys, which typically begin with an uppercase letter; also, my associations
are actually VariableBinding instances.

My keys are (expected to be) symbols, so I use == to match searched keys
to those in the dictionary -- this is done expecting that it brings a bit
more speed.'>

    = arg [
        "Answer whether the receiver is equal to arg. The equality test is
         by default the same as that for equal objects. = must not fail;
         answer false if the receiver cannot be compared to arg"

        <category: 'basic & copying'>
        <primitive: VMpr_Object_identity>
    ]

    hash [
        "Answer an hash value for the receiver.  This is the same as the
         object's #identityHash."

        <category: 'basic & copying'>
        <primitive: VMpr_Object_hash>

    ]

    copy [
	<category: 'copying'>
	^self
    ]

    copyEmpty: newSize [
	"Answer an empty copy of the receiver whose size is newSize"

	<category: 'copying'>
	| realSize |
	realSize := 8 max: (newSize * 4 + 2) // 3.
	(realSize bitAnd: realSize - 1) = 0 
	    ifFalse: [realSize := 1 bitShift: realSize highBit].
	^(self class primNew: realSize)
	    initialize: realSize;
	    environment: self environment;
	    yourself
    ]

    copyEmptyForCollect [
	"Answer an empty copy of the receiver which is filled in to
	 compute the result of #collect:"

	<category: 'copying'>
	^self species new: self capacity
    ]

    copyEmptyForCollect: size [
	"Answer an empty copy of the receiver which is filled in to
	 compute the result of #collect:"

	<category: 'copying'>
	^self species new: size
    ]

    shallowCopy [
	<category: 'copying'>
	^self
    ]

    deepCopy [
	<category: 'copying'>
	^self
    ]

    environment [
	"Answer the environment to which the receiver is connected.  This
	 can be the class for a dictionary that holds class variables,
	 or the super-namespace.  In general it is used to compute the
	 receiver's name."

	<category: 'accessing'>
	^environment
    ]

    environment: anObject [
	"Set the environment to which the receiver is connected.  This
	 can be the class for a dictionary that holds class variables,
	 or the super-namespace.  In general it is used to compute the
	 receiver's name."

	<category: 'accessing'>
	environment := anObject
    ]

    name [
	"Answer the receiver's name, which by default is the same as the
	 name of the receiver's environment."

	<category: 'accessing'>
	^self environment name
    ]

    nameIn: aNamespace [
	"Answer the receiver's name when referred to from aNamespace; by
	 default the computation is deferred to the receiver's environment."

	<category: 'accessing'>
	^self environment nameIn: aNamespace
    ]

    define: aSymbol [
	"Define aSymbol as equal to nil inside the receiver.  Fail if such
	 a variable already exists (use #at:put: if you don't want to fail)"

	<category: 'accessing'>
	super at: aSymbol
	    ifAbsent: 
		[self at: aSymbol put: nil.
		^self].
	SystemExceptions.AlreadyDefined signalOn: aSymbol
    ]

    import: aSymbol from: aNamespace [
	"Add to the receiver the symbol aSymbol, associated to the
	 same value as in aNamespace. Fail if aNamespace does not
	 contain the given key."

	<category: 'accessing'>
	self add: (aNamespace associationAt: aSymbol) copy
    ]

    doesNotUnderstand: aMessage [
	"Try to map unary selectors to read accesses to the Namespace,
	 and one-argument keyword selectors to write accesses.
	 Note that: a) this works only if the selector has an
	 uppercase first letter; and b) `aNamespace Variable: value' is
	 the same as `aNamespace set: #Variable to: value', not the same as
	 `aNamespace at: #Variable put: value' --- the latter always
	 refers to the current namespace, while the former won't
	 define a new variable, instead searching in superspaces (and
	 raising an error if the variable cannot be found)."

	<category: 'accessing'>
	| key |
	(aMessage selector at: 1) isUppercase 
	    ifFalse: [^super doesNotUnderstand: aMessage].
	aMessage arguments size = 0 
	    ifTrue: 
		[^self at: aMessage selector ifAbsent: [super doesNotUnderstand: aMessage]].
	aMessage arguments size > 1 ifTrue: [^super doesNotUnderstand: aMessage].
	key := (aMessage selector copyWithout: $:) asSymbol.
	^self 
	    set: key
	    to: aMessage argument
	    ifAbsent: [super doesNotUnderstand: aMessage]
    ]

    printOn: aStream in: aNamespace [
	"Print the receiver's name when referred to from aNamespace; by
	 default the computation is deferred to the receiver's environment."

	<category: 'printing'>
	self environment printOn: aStream in: aNamespace
    ]

    at: key put: value [
	"Store value as associated to the given key. If any, recycle Associations
	 temporarily stored by the compiler inside the `Undeclared' dictionary."

	<category: 'forward declarations'>
	| index assoc newAssoc |
	index := self findIndex: key.
	assoc := self primAt: index.
	assoc isNil 
	    ifFalse: 
		[assoc value: value.
		^value].
	newAssoc := VariableBinding 
		    key: key
		    value: value
		    environment: self.
	self incrementTally ifTrue: [index := self findIndex: key].
	assoc := Undeclared associationAt: key ifAbsent: [nil].
	assoc isNil 
	    ifTrue: [assoc := newAssoc]
	    ifFalse: 
		[Undeclared remove: assoc ifAbsent: [].
		assoc become: newAssoc].
	self primAt: index put: assoc.
	^value
    ]

    hashFor: anObject [
	"Return an hash value for the item, anObject"

	<category: 'private'>
	^anObject key identityHash
    ]

    findIndex: anObject [
	"Tries to see if anObject exists as an indexed variable. As soon as nil
	 or anObject is found, the index of that slot is answered"

	<category: 'private'>
	| index size element |
	"Sorry for the lack of readability, but I want speed... :-)"
	index := (anObject identityHash scramble 
		    bitAnd: (size := self primSize) - 1) + 1.
	
	[((element := self primAt: index) isNil or: [element key == anObject]) 
	    ifTrue: [^index].
	index == size ifTrue: [index := 1] ifFalse: [index := index + 1]] 
		repeat
    ]

    primAt: index put: anObject [
	"Store anObject in the dictionary. If any, recycle Associations
	 temporarily stored by the compiler inside the `Undeclared' dictionary."

	<category: 'private'>
	| assoc |
	assoc := anObject.
	assoc isNil 
	    ifFalse: 
		["Need static typing to avoid crashes..."

		((assoc isKindOf: VariableBinding) and: [assoc environment == self]) 
		    ifFalse: 
			[assoc := VariableBinding 
				    key: assoc key
				    value: assoc value
				    environment: self].
		assoc makeUntrusted: environment isUntrusted].
	^super primAt: index put: assoc
    ]

    addWhileGrowing: anAssociation [
	<category: 'private'>
	| save |
	save := anAssociation environment.
	anAssociation environment: self.
	super addWhileGrowing: anAssociation.
	anAssociation environment: save.
	^anAssociation
    ]

    keysClass [
	<category: 'private'>
	^IdentitySet
    ]

    species [
	<category: 'testing'>
	^IdentityDictionary
    ]
]
