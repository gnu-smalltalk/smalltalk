"======================================================================
|
|   Magritte compatibility methods for GNU Smalltalk
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



Object subclass: MACompatibility [
    
    <category: 'Magritte-Model-Core'>
    <comment: 'I am providing all the platform compatibility code on my class side, so that porting to different Smalltalk dialects can concentrate in a single place.'>

    ShowLicense := false.

    MACompatibility class >> allSubInstancesOf: aClass do: aBlock [
	"Evaluate the aBlock for all instances of aClass and all its subclasses."

	<category: 'environment'>
	aClass allSubinstancesDo: aBlock
    ]

    MACompatibility class >> classNamed: aString [
	"Return the class named aString, nil if the class can't be found."

	<category: 'environment'>
	^(aString subStrings: $.) inject: Smalltalk into: [ :old :each |
	    old at: each asSymbol ifAbsent: [ ^nil ] ]
    ]

    MACompatibility class >> openWorkspace: aContentsString titled: aTitleString [
	"Open a new wokspace with the contents aContentsString and the title aTitleString."

	ShowLicense ifFalse: [ ^self ].
	('%1

%2
' % { aTitleString asUppercase. aContentsString }) displayOn: stderr
    ]

    MACompatibility class >> referenceStream: aReadWriteStream [
	"Return a stream instance to operate on aReadWriteStream being able to serialize and deserialize objects by sending #nextPut: and #next. Squeak: The implementation of ReferenceStream doesn't work well together with the default WriteStream implementaiton, therefor we have to change it on the fly."

	<category: 'environment'>
	^ObjectDumper on: aReadWriteStream
    ]

    MACompatibility class >> uuid [
	"Answer a random object that is extremly likely to be unique over space and time."

	<category: 'environment'>
	^UUID new
    ]
]



ByteArray subclass: UUID [
    
    <shape: #byte>
    <category: 'Seaside-Core-Utilities'>
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



Symbol extend [
    isUnary [
	"Return true if the symbol represents a Unary selector."
	<category: 'testing'>

	^self numArgs = 0
    ]
]

FileDescriptor extend [
    binary [
	"Do nothing, needed for Squeak compatibility."

	<category: 'squeak compatibility'>
    ]
]

Object extend [
    asString [
	"Return the #displayString, needed for Squeak compatibility."

	<category: 'squeak compatibility'>
        ^self displayString
    ]

    isCollection [
	"Return false, needed for Squeak compatibility."

	<category: 'squeak compatibility'>
        ^false
    ]

    isEmptyOrNil [ 
	"Return false, needed for Squeak compatibility."

	<category: 'squeak compatibility'>
        ^false
    ]

    isVariableBinding [
	"Return false, needed by Magritte-Seaside."

	<category: 'squeak compatibility'>
        ^false
    ]

]

Association extend [
    isVariableBinding [
	"Return false, needed by Magritte-Seaside."

	<category: 'squeak compatibility'>
        ^true
    ]
]

Collection extend [
    intersection: b [
	"Return the set of elements common to the receiver and B."

	<category: 'squeak compatibility'>
        ^self asSet & b
    ]

    hasEqualElements: b [
	"Compare the elements in the receiver and B.  Can be improved,
	 looking at Squeak's implementation."

	<category: 'squeak compatibility'>
        ^self asArray = b asArray
    ]

    isCollection [
	"Return true, needed for Squeak compatibility."

	<category: 'squeak compatibility'>
        ^true
    ]

    isEmptyOrNil [
	"Return true if the collection is empty, needed for Squeak
	 compatibility."

	<category: 'squeak compatibility'>
        ^self isEmpty
    ]
]

SequenceableCollection extend [
    sort: aBlock [
	"Sort the items of the receiver according to the sort block,
	 aBlock."

	<category: 'squeak compatibility'>
	self
	    replaceFrom: 1
	    to: self size
	    with: (self asSortedCollection: aBlock)
	    startingAt: 1
    ]
]

SortedCollection extend [
    sort: aBlock [
	"Sort the items of the receiver according to the sort block,
	 aBlock, and change the sort block to aBlock."

	<category: 'squeak compatibility'>
	sortBlock := aBlock.
	self sortFrom: firstIndex to: lastIndex.
        sorted := true.
        lastOrdered := lastIndex
    ]
]

UndefinedObject extend [
    isEmptyOrNil [
	"Return true, needed for Squeak compatibility."

	<category: 'squeak compatibility'>
	^true
    ]
]

String extend [
    includesSubstring: aString caseSensitive: aBoolean [
	"Needed for Squeak compatibility."

	<category: 'squeak compatibility'>
	aBoolean ifTrue: [ ^(self indexOfSubCollection: aString) > 0 ].
	^(self asLowercase indexOfSubCollection: aString asLowercase) > 0
    ]
]

ValueHolder extend [
    contents [
	"Needed for Squeak compatibility."
	^self value
    ]
    contents: anObject [
	"Needed for Squeak compatibility."
	self value: anObject
    ]
]

Time extend [
    print24: boolean24 showSeconds: booleanSec on: aStream [
        "Print a representation of the receiver on aStream according
	 to the given flags.  Needed for Squeak compatibility."

        <category: 'arithmetic'>
	| h |
	h := boolean24 ifTrue: [ self hour24 ] ifFalse: [ self hour12 ].
        h printOn: aStream.
        aStream nextPut: $:.
        self minutes < 10 ifTrue: [aStream nextPut: $0].
        self minutes printOn: aStream.
	booleanSec ifFalse: [ ^self ].
        aStream nextPut: $:.
        self seconds < 10 ifTrue: [aStream nextPut: $0].
        self seconds printOn: aStream
    ]
]

Object subclass: MAVisitor [
    MAVisitor class >> new [
	<category: 'instance creation'>
	^super new initialize
    ]
    initialize [
	<category: 'initialization'>
    ]
]



Eval [
    UUID initialize.
]
