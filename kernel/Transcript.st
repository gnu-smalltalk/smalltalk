"======================================================================
|
|   Smalltalk Transcript object (TextCollector class)
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2008,2009
| Free Software Foundation, Inc.
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



Stream subclass: TextCollector [
    | semaphore receiver selector |
    
    <category: 'Streams'>
    <comment: 'I am a thread-safe class that maps between standard Stream protocol and
a single message to another object (its selector is pluggable and should
roughly correspond to #nextPutAll:).  I am, in fact, the class that
implements the global Transcript object.'>

    TextCollector class >> new [
	<category: 'accessing'>
	self shouldNotImplement
    ]

    TextCollector class >> message: receiverToSelectorAssociation [
	"Answer a new instance of the receiver, that uses the message identified
	 by anAssociation to perform write operations.  anAssociation's
	 key is the receiver, while its value is the selector."

	<category: 'accessing'>
	^(self basicNew)
	    initialize;
	    message: receiverToSelectorAssociation
    ]

    message [
	"Answer an association representing the message to be sent
	 to perform write operations.  The key is the receiver, the value is the
	 selector"

	<category: 'set up'>
	^receiver -> selector
    ]

    message: receiverToSelectorAssociation [
	"Set the message to be sent to perform write operations
	 to the one represented by anAssociation.  anAssociation's key is the
	 receiver, while its value is the selector"

	<category: 'set up'>
	receiver := receiverToSelectorAssociation key.
	selector := receiverToSelectorAssociation value
    ]

    cr [
	"Emit a new-line (carriage return) to the Transcript"

	<category: 'accessing'>
	self nl
    ]

    endEntry [
	"Emit two new-lines.  This method is present for compatibility with
	 VisualWorks."

	<category: 'accessing'>
	self
	    nl;
	    nl
    ]

    nextPut: aCharacter [
	"Emit aCharacter to the Transcript"

	<category: 'accessing'>
	self nextPutAll: (String with: aCharacter)
    ]

    next: anInteger put: anObject [
	"Write anInteger copies of anObject to the Transcript"

	<category: 'accessing'>
	self nextPutAll: (String new: anInteger withAll: anObject)
    ]

    critical: aBlock [
	"Evaluate aBlock while holding the Transcript lock"

	<category: 'accessing'>
	semaphore critical: aBlock
    ]

    next: n putAll: aString startingAt: pos [
	"Write aString to the Transcript"

	<category: 'accessing'>
	semaphore critical: 
		[self primNextPutAll: (aString copyFrom: pos to: pos + n - 1).
		Processor idle]
    ]

    show: aString [
	"Write aString to the Transcript"

	<category: 'accessing'>
	semaphore critical: 
		[self primNextPutAll: aString.
		Processor idle]
    ]

    showCr: aString [
	"Write aString to the Transcript, followed by a new-line character"

	<category: 'accessing'>
	semaphore critical: 
		[self primNextPutAll: aString.
		self primNextPutAll: Character nl asString.
		Processor idle]
    ]

    showOnNewLine: aString [
	"Write aString to the Transcript, preceded by a new-line character"

	<category: 'accessing'>
	semaphore critical: 
		[self primNextPutAll: Character nl asString.
		self primNextPutAll: aString.
		Processor idle]
    ]

    print: anObject [
	"Print anObject's representation to the Transcript"

	<category: 'printing'>
	semaphore critical: 
		[self primNextPutAll: anObject printString.
		Processor idle]
    ]

    printOn: aStream [
	"Print a representation of the receiver onto aStream"

	<category: 'printing'>
	self == Transcript 
	    ifTrue: [aStream nextPutAll: 'Transcript']
	    ifFalse: [super printOn: aStream]
    ]

    store: anObject [
	"Print Smalltalk code which evaluates to anObject on the Transcript"

	<category: 'storing'>
	semaphore critical: 
		[self primNextPutAll: anObject storeString.
		Processor idle]
    ]

    storeOn: aStream [
	"Print Smalltalk code which evaluates to the receiver onto aStream"

	<category: 'storing'>
	self == Transcript 
	    ifTrue: [aStream nextPutAll: 'Transcript']
	    ifFalse: [super storeOn: aStream]
    ]

    primNextPutAll: aString [
	"Private - Forward the writing request to the actual object"

	<category: 'private'>
	[receiver perform: selector with: aString]
	    on: Error do: [:ex | stderr nextPutAll: aString; flush. ex return]
    ]

    initialize [
	"Private - Initialize the receiver's instance variables"

	<category: 'private'>
	semaphore := RecursionLock new
    ]
]



Eval [
    Smalltalk at: #Transcript
	put: (TextCollector message: stdout -> #nextPutAllFlush:)
]

