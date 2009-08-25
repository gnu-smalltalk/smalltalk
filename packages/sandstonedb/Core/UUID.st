"======================================================================
|
|   SandstoneDb.UUID  class definition
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2008 Free Software Foundation, Inc.
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



ByteArray subclass: UUID [
    
    <shape: #byte>
    <category: 'Sandstone'>
    <comment: 'I am a UUID.  Sending #new generates a UUIDv1.'>

    Node := nil.
    SequenceValue := nil.
    LastTime := nil.
    Generator := nil.
    GeneratorMutex := nil.

    UUID class >> timeValue [
	"Returns the time value for a UUIDv1, in 100 nanoseconds units
	 since 1-1-1601."
	^((Time utcSecondClock + (109572 * 86400)) * 1000
	    + Time millisecondClock) * 10000
    ]

    UUID class >> randomNodeValue [
	"Return the node value for a UUIDv1."
	| n |
	"TODO: use some kind of digest to produce cryptographically strong
	 random numbers."
	n := Generator between: 0 and: 16rFFFF.
	n := (n bitShift: 16) bitOr: (Generator between: 0 and: 16rFFFF).
	n := (n bitShift: 16) bitOr: (Generator between: 0 and: 16rFFFF).
	^n bitOr: 1
    ]

    UUID class >> update: aSymbol [
	"Update the sequence value of a UUIDv1 when an image is restarted."

	aSymbol == #returnFromSnapshot ifTrue: [
	    "You cannot be sure that the node ID is the same."
	    GeneratorMutex critical: [
		Generator := Random new.
		LastTime := self timeValue.
		Node := self randomNodeValue.
		SequenceValue := (SequenceValue + 1) bitAnd: 16383 ]].
    ]

    UUID class >> defaultSize [
	"Return the size of a UUIDv1."

	<category: 'private'>
	^16
    ]

    UUID class >> initialize [
	"Initialize the class."

	<category: 'initialization'>
	ObjectMemory addDependent: self.
	Generator := Random new.
	LastTime := self timeValue.
	Node := self randomNodeValue.
	SequenceValue := Generator between: 0 and: 16383.
	GeneratorMutex := Semaphore forMutualExclusion.
    ]

    UUID class >> new [
	"Return a new UUIDv1."

	<category: 'instance-creation'>
	^(self new: self defaultSize) initialize
    ]

    initialize [
	"Fill in the fields of a new UUIDv1."

	<category: 'private'>
	| t |
	GeneratorMutex critical: [
	    t := self class timeValue bitAnd: 16rFFFFFFFFFFFFFFF.
	    t <= LastTime
		ifTrue: [ SequenceValue := (SequenceValue + 1) bitAnd: 16383 ].

	    LastTime := t.
	    self at: 1 put: ((t bitShift: -24) bitAnd: 255).
	    self at: 2 put: ((t bitShift: -16) bitAnd: 255).
	    self at: 3 put: ((t bitShift: -8) bitAnd: 255).
	    self at: 4 put: (t bitAnd: 255).
	    self at: 5 put: ((t bitShift: -40) bitAnd: 255).
	    self at: 6 put: ((t bitShift: -32) bitAnd: 255).
	    self at: 7 put: (t bitShift: -56) + 16r10.
	    self at: 8 put: ((t bitShift: -48) bitAnd: 255).
	    self at: 9 put: (SequenceValue bitShift: -8) + 16r80.
	    self at: 10 put: (SequenceValue bitAnd: 255).
	    self at: 13 put: ((Node bitShift: -40) bitAnd: 255).
	    self at: 14 put: ((Node bitShift: -32) bitAnd: 255).
	    self at: 15 put: ((Node bitShift: -24) bitAnd: 255).
	    self at: 16 put: ((Node bitShift: -16) bitAnd: 255).
	    self at: 11 put: ((Node bitShift: -8) bitAnd: 255).
	    self at: 12 put: (Node bitAnd: 255)]
    ]

    printOn: aStream from: a to: b [
	<category: 'private'>
	self from: a to: b do: [:each |
	    aStream nextPut: (Character digitValue: (each bitShift: -4)).
	    aStream nextPut: (Character digitValue: (each bitAnd: 15)) ]
    ]

    printOn: aStream [
	"Print the bytes in the receiver in UUID format."
	<category: 'printing'>
	self printOn: aStream from: 1 to: 4.
	aStream nextPut: $-.
	self printOn: aStream from: 5 to: 6.
	aStream nextPut: $-.
	self printOn: aStream from: 7 to: 8.
	aStream nextPut: $-.
	self printOn: aStream from: 9 to: 10.
	aStream nextPut: $-.
	self printOn: aStream from: 11 to: 16.
    ]
]


Eval [
    UUID initialize.
]

