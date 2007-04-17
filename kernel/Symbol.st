"======================================================================
|
|   Symbol Method Definitions
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2002,2006
| Free Software Foundation, Inc.
| Written by Steve Byrne.
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


String variable: #character subclass: #Symbol
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: 'Language-Implementation'
!

Symbol comment: 
'My instances are unique throughout the Smalltalk system.  My instances 
behave for the most part like strings, except that they print differently,
and I guarantee that any two instances that have the same printed 
representation are in fact the same instance.' !


!Symbol class methodsFor: 'symbol table'!

rebuildTable
    "Rebuild the SymbolTable, thereby garbage-collecting unreferenced
     Symbols.  While this process is done, preemption is disabled
     because it is not acceptable to leave the SymbolTable in a
     partially updated state.  Note that this works because String>>#hash
     calculates the same hash value used by the VM when interning strings
     into the SymbolTable.  Changing one of the hashing methods without
     changing the other will break this method."

    [   | oldSymbols hashTableMask |
	oldSymbols := Symbol allInstances.
	hashTableMask := SymbolTable size - 1.

	"We have to use #become: so that any reference from the
	 VM to the SymbolTable (via the _gst_symbol_table variable)
	 is still valid."
	SymbolTable become: SymbolTable copyEmpty.
	ObjectMemory compact.

	oldSymbols aliveObjectsDo: [ :each |
	    | bucket |
	    bucket := (each asString hash scramble bitAnd: hashTableMask) + 1.

	    SymbolTable at: bucket put: (SymLink
		symbol: each
		nextLink: (SymbolTable at: bucket))
	]
    ] valueWithoutPreemption!

hasInterned: aString ifTrue: aBlock
    "If aString has not been interned yet, answer false.  Else, pass the
     interned version to aBlock and answer true.  Note that this works because
     String>>#hash calculates the same hash value used by the VM when interning
     strings into the SymbolTable.  Changing one of the hashing methods without
     changing the other will break this method."
    | link hash |
    hash := aString asString hash scramble bitAnd: SymbolTable size - 1.
    link := SymbolTable at: hash + 1.

    link do: [ :each |
	| ok |
	each size = aString size ifTrue: [
	    ok := true.
	    each with: aString do: [ :a :b | a = b ifFalse: [ ok := false ] ].
	    ok ifTrue: [ aBlock value: each. ^true ].
	].
    ].
    ^false
!

isSymbolString: aString
    "Answer whether aString has already been interned. Note that this works
     because String>>#hash calculates the same hash value used by the VM
     when interning strings into the SymbolTable.  Changing one of the
     hashing methods without changing the other will break this method."
    | link hash |
    hash := aString asString hash scramble bitAnd: SymbolTable size - 1.
    link := SymbolTable at: hash + 1.

    link do: [ :each |
	| ok |
	each size = aString size ifTrue: [
	    ok := true.
	    each with: aString do: [ :a :b | a = b ifFalse: [ ok := false ] ].
	    ok ifTrue: [ ^true ].
	].
    ].
    ^false
! !

!Symbol class methodsFor: 'instance creation'!

internCharacter: aCharacter
    "Answer the one-character symbol associated to the given character."
    | s |
    s := String new: 1.
    s at: 1 put: aCharacter.
    ^self intern: s
!

new
    self shouldNotImplement
!

new: size
    self shouldNotImplement
!

with: element1
    "Answer a collection whose only element is element1"
    | s |
    s := String new: 1.
    s at: 1 put: element1.
    ^self intern: s
!

with: element1 with: element2
    "Answer a collection whose only elements are the parameters in the order
     they were passed"
    | s |
    s := String new: 2.
    s at: 1 put: element1.
    s at: 2 put: element2.
    ^self intern: s
!

with: element1 with: element2 with: element3
    "Answer a collection whose only elements are the parameters in the order
     they were passed"
    | s |
    s := String new: 3.
    s at: 1 put: element1.
    s at: 2 put: element2.
    s at: 3 put: element3.
    ^self intern: s
!

with: element1 with: element2 with: element3 with: element4
    "Answer a collection whose only elements are the parameters in the order
     they were passed"
    | s |
    s := String new: 4.
    s at: 1 put: element1.
    s at: 2 put: element2.
    s at: 3 put: element3.
    s at: 4 put: element4.
    ^self intern: s
!

with: element1 with: element2 with: element3 with: element4 with: element5
    "Answer a collection whose only elements are the parameters in the order
     they were passed"
    | s |
    s := String new: 5.
    s at: 1 put: element1.
    s at: 2 put: element2.
    s at: 3 put: element3.
    s at: 4 put: element4.
    s at: 5 put: element5.
    ^self intern: s
! !



!Symbol methodsFor: 'converting'!

asString
    "Answer a String with the same characters as the receiver"
    ^self copyFrom: 1 to: self size
!

asSymbol
    "But we are already a Symbol, and furthermore, Symbols are identity objects!
    So answer the receiver."
    ^self
! !



!Symbol methodsFor: 'basic'!

numArgs
    "Answer the number of arguments supported by the receiver, which is supposed
     to be a valid message name (#+, #not, #printOn:, #ifTrue:ifFalse:, etc.)"
    (self at: 1) isLetter ifFalse: [ ^1 ].
    ^(self at: self size) = $:
	ifTrue: [ self occurrencesOf: $: ]
	ifFalse: [ 0 ]
!

keywords
    "Answer an array of keywords that compose the receiver, which is supposed
     to be a valid message name (#+, #not, #printOn:, #ifTrue:ifFalse:, etc.)"
    (self at: 1) isLetter ifFalse: [ ^{ self } ].
    ^(self at: self size) = $:
	ifTrue: [ (self substrings: $:) collect: [ :each | (each, ':') asSymbol ] ]
	ifFalse: [ { self } ]
!

shallowCopy
    "Returns a deep copy of the receiver. As Symbols are identity objects, we
     actually return the receiver itself."
    ^self
!

deepCopy
    "Returns a deep copy of the receiver. As Symbols are identity objects, we
     actually return the receiver itself."
    ^self
! !


!Symbol methodsFor: 'misc'!

species
    ^String
! !



!Symbol methodsFor: 'storing'!

displayString
    "Answer a String representing the receiver. For most objects
     this is simply its #printString, but for strings and characters,
     superfluous dollars or extra pair of quotes are stripped."
    | stream |
    stream := WriteStream on: String new.
    self displayOn: stream.
    ^stream contents
!

displayOn: aStream
    "Print a represention of the receiver on aStream. For most objects
     this is simply its #printOn: representation, but for strings and
     characters, superfluous dollars or extra pairs of quotes are stripped."
    self printOn: aStream
!

storeOn: aStream
    "Print Smalltalk code on aStream that compiles
     to the same symbol as the receiver."
    self printOn: aStream
!

printOn: aStream
    "Print a represention of the receiver on aStream."
    aStream nextPut: $#.
    self isSimpleSymbol
	ifTrue: [ aStream nextPutAll: self ]
	ifFalse: [ super printOn: aStream ]
! !

!Symbol methodsFor: 'testing'!

isSimpleSymbol
    "Answer whether the receiver must be represented in quoted-string
     (e.g. #'abc-def') form."
    | first |
    first := self at: 1.
    first isLetter ifFalse: [
	"Binary symbol"
	self size > 2 ifTrue: [ ^false ].
	^self allSatisfy: [ :each | '+-*/\<>=~,%@?&|' includes: each ]
    ].
    
    "Selector or kind-of-selector"
    ^self allSatisfy: [ :each |
	each isAlphaNumeric or: [ each = $: ]
    ]
! !


!Symbol methodsFor: 'testing functionality'!

isString
    ^false
!

isSymbol
    ^true
! !


!Symbol class methodsFor: 'built ins'!

intern: aString
    "Private - Same as 'aString asSymbol'"
    <primitive: VMpr_Symbol_intern>
    SystemExceptions.WrongClass signalOn: aString mustBe: String
! !



!Symbol methodsFor: 'built ins'!

= aSymbol
    "Answer whether the receiver and aSymbol are the same object"
    <primitive: VMpr_Object_identity>
    ^false
!

hash
    "Answer an hash value for the receiver. Symbols are optimized
     for speed"
    <primitive: VMpr_Object_hash>

! !



