"======================================================================
|
|   DirectedMessage Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999, 2000, 2001, 2002, 2008 Free Software Foundation, Inc.
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



Message subclass: DirectedMessage [
    | receiver |
    
    <category: 'Language-Implementation'>
    <comment: 'I represent a message send: I contain the receiver, selector and arguments
for a message.'>

    DirectedMessage class >> selector: aSymbol arguments: anArray [
	<category: 'creating instances'>
	self shouldNotImplement
    ]

    DirectedMessage class >> receiver: anObject selector: aSymbol [
	"Create a new instance of the receiver"

	<category: 'creating instances'>
	^(super selector: aSymbol arguments: #()) receiver: anObject
    ]

    DirectedMessage class >> receiver: receiverObject selector: aSymbol argument: argumentObject [
	"Create a new instance of the receiver"

	<category: 'creating instances'>
	^(super selector: aSymbol argument: argumentObject) receiver: receiverObject
    ]

    DirectedMessage class >> receiver: anObject selector: aSymbol arguments: anArray [
	"Create a new instance of the receiver"

	<category: 'creating instances'>
	^(super selector: aSymbol arguments: anArray) receiver: anObject
    ]

    DirectedMessage class >> selector: aSymbol arguments: anArray receiver: anObject [
	"Create a new instance of the receiver"

	<category: 'creating instances'>
	^(super selector: aSymbol arguments: anArray) receiver: anObject
    ]

    printOn: aStream [
	"Print a representation of the receiver on aStream"

	<category: 'basic'>
	aStream
	    print: receiver;
	    space.
	super printOn: aStream
    ]

    method [
	"Return the method that is the result of the lookup."

	<category: 'basic'>
        ^receiver class lookupSelector: self selector
    ]

    send [
	"Send the message"

	<category: 'basic'>
	^self sendTo: receiver
    ]

    value [
	"Send the message (this message provides interoperability
	 between DirectedMessages and blocks)"

	<category: 'basic'>
	^self sendTo: receiver
    ]

    value: anObject [
	"Send the message with the sole argument anObject (this message
	 provides interoperability between DirectedMessages and blocks)"

	<category: 'basic'>
	^receiver perform: self selector with: anObject
    ]

    value: obj1 value: obj2 [
	"Send the message with the arguments obj1 and obj2 (this message
	 provides interoperability between DirectedMessages and blocks)"

	<category: 'basic'>
	^receiver perform: self selector with: obj1 with: obj2
    ]

    valueWithArguments: anArray [
	"Send the message with the arguments replaced by anArray (this
	 message provides interoperability between DirectedMessages and blocks)"

	<category: 'basic'>
	^receiver perform: self selector withArguments: anArray
    ]

    receiver: anObject [
	"Change the receiver"

	<category: 'accessing'>
	receiver := anObject
    ]

    receiver [
	"Answer the receiver"

	<category: 'accessing'>
	^receiver
    ]

    fork [
	"Create a new process executing the receiver and start it"

	<category: 'multiple process'>
	^Process 
	    on: self
	    at: Processor activePriority
	    suspend: false
    ]

    forkAt: priority [
	"Create a new process executing the receiver with given priority
	 and start it"

	<category: 'multiple process'>
	^Process 
	    on: self
	    at: priority
	    suspend: false
    ]

    newProcess [
	"Create a new process executing the receiver in suspended state.
	 The priority is the same as for the calling process. The receiver
	 must not contain returns"

	<category: 'multiple process'>
	^Process 
	    on: self
	    at: Processor activePriority
	    suspend: true
    ]

    reconstructOriginalObject [
	"This method is used when DirectedMessages are used together
	 with PluggableProxies (see ObjectDumper).  It sends the receiver
	 to reconstruct the object that was originally stored."

	<category: 'saving and loading'>
	^self send
    ]
]

