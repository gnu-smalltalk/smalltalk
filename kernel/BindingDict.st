"======================================================================
|
|   BindingDictionary Method Definitions
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1999, 2000, 2001, 2002, 2003 Free Software Foundation, Inc.
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


Dictionary variableSubclass: #BindingDictionary
	   instanceVariableNames: 'environment'
	   classVariableNames: ''
	   poolDictionaries: ''
	   category: 'Language-Implementation'
!

BindingDictionary comment: 
'I am a special form of dictionary that provides special ways to access my
keys, which typically begin with an uppercase letter; also, my associations
are actually VariableBinding instances.

My keys are (expected to be) symbols, so I use == to match searched keys
to those in the dictionary -- this is done expecting that it brings a bit
more speed.' !


!BindingDictionary methodsFor: 'copying'!

copy
    ^self
!

copyEmpty: newSize
    "Answer an empty copy of the receiver whose size is newSize"
    | realSize |
    realSize := 8 max: newSize.
    (realSize bitAnd: (realSize - 1)) = 0 ifFalse: [
        realSize := 1 bitShift: realSize highBit
    ].

    ^(self class basicNew: realSize)
	initialize: realSize;
	environment: self environment;
	yourself
!

copyEmptyForCollect
    "Answer an empty copy of the receiver which is filled in to
     compute the result of #collect:"
    ^self species new: self primSize
!

shallowCopy
    ^self
!

deepCopy
    ^self
! !


!BindingDictionary methodsFor: 'accessing'!

environment
    "Answer the environment to which the receiver is connected.  This
     can be the class for a dictionary that holds class variables,
     or the super-namespace.  In general it is used to compute the
     receiver's name."
    ^environment!

environment: anObject
    "Set the environment to which the receiver is connected.  This
     can be the class for a dictionary that holds class variables,
     or the super-namespace.  In general it is used to compute the
     receiver's name."
    environment := anObject!

name
    "Answer the receiver's name, which by default is the same as the
     name of the receiver's environment."
    ^self environment name!

nameIn: aNamespace
    "Answer the receiver's name when referred to from aNamespace; by
     default the computation is deferred to the receiver's environment."
    ^self environment nameIn: aNamespace!

define: aSymbol
    "Define aSymbol as equal to nil inside the receiver.  Fail if such
     a variable already exists (use #at:put: if you don't want to fail)"

    super at: aSymbol ifAbsent: [
	self at: aSymbol put: nil.
	^self
    ].
    SystemExceptions.AlreadyDefined signalOn: aSymbol
!

import: aSymbol from: aNamespace 
    "Add to the receiver the symbol aSymbol, associated to the
     same value as in aNamespace. Fail if aNamespace does not
     contain the given key."

    self add: (aNamespace associationAt: aSymbol) copy
!

doesNotUnderstand: aMessage
    "Try to map unary selectors to read accesses to the Namespace,
    and one-argument keyword selectors to write accesses.
    Note that: a) this works only if the selector has an
    uppercase first letter; and b) `aNamespace Variable: value' is
    the same as `aNamespace set: #Variable to: value', not the same as
    `aNamespace at: #Variable put: value' --- the latter always
    refers to the current namespace, while the former won't
    define a new variable, instead searching in superspaces (and
    raising an error if the variable cannot be found)."

    | key |
    (aMessage selector at: 1) isUppercase
	ifFalse: [ ^super doesNotUnderstand: aMessage ].

    aMessage arguments size = 0 ifTrue: [
	^self
	    at: aMessage selector
	    ifAbsent: [ super doesNotUnderstand: aMessage ]
    ].

    aMessage arguments size > 1
	ifTrue: [ ^super doesNotUnderstand: aMessage ].

    key := (aMessage selector copyWithout: $:) asSymbol.
    ^self
	set: key
	to: aMessage argument
	ifAbsent: [ super doesNotUnderstand: aMessage ]
! !


!BindingDictionary methodsFor: 'printing'!

printOn: aStream in: aNamespace
    "Print the receiver's name when referred to from aNamespace; by
     default the computation is deferred to the receiver's environment."
    self environment printOn: aStream in: aNamespace! !


!BindingDictionary methodsFor: 'forward declarations'!

add: aVariableBinding
    "Store value as associated to the given key. If any, recycle Associations
     temporarily stored by the compiler inside the `Undeclared' dictionary."
    | assoc |
    assoc := aVariableBinding.

    assoc environment == Undeclared ifTrue: [
        assoc environment: self.
	Undeclared remove: assoc.
    ].

    "Need static typing to avoid crashes..."
    ((assoc isKindOf: VariableBinding) and: [
	assoc environment == self]) ifFalse: [
	assoc := VariableBinding
	    key: assoc key
	    value: assoc value
	    environment: self.
    ].

    ^super add: assoc
!

at: key put: value
    "Store value as associated to the given key. If any, recycle Associations
     temporarily stored by the compiler inside the `Undeclared' dictionary."
    | assoc |

    assoc := (Undeclared includesKey: key)
	ifTrue: [
	    (Undeclared associationAt: key)
	        value: value;
	        yourself
        ]
	ifFalse: [
	    VariableBinding
	        key: key
	        value: value
	        environment: self
	].

   self add: assoc.
   ^value
! !


!BindingDictionary methodsFor: 'private'!

hashFor: anObject
    "Return an hash value for the item, anObject"
    ^anObject key identityHash
!

findIndex: anObject
    "Tries to see if anObject exists as an indexed variable. As soon as nil
    or anObject is found, the index of that slot is answered"

    | index size element |
    self beConsistent.

    "Sorry for the lack of readability, but I want speed... :-)"
    index := (anObject identityHash scramble
                bitAnd: (size := self primSize) - 1) + 1.

    [
        ((element := self primAt: index) isNil
            or: [ element key == anObject ])
                ifTrue: [ ^index ].

        index == size
            ifTrue: [ index := 1 ]
            ifFalse: [ index := index + 1 ]
    ] repeat
!

keysClass
    ^IdentitySet
! !


!BindingDictionary methodsFor: 'testing'!

species
    ^IdentityDictionary
! !
