"======================================================================
|
|   Message Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2008
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



Object subclass: Message [
    | selector args |
    
    <category: 'Language-Implementation'>
    <comment: 'I represent a message send.  My instances are created to hold a message
that has failed, so that error reporting methods can examine the sender
and arguments, but also to represent method attributes (like
<primitive: 111> since their syntax is isomorphic to that of a
message send.'>

    Message class >> selector: aSymbol argument: anObject [
	"Create a new Message with the given selector and argument"

	<category: 'creating instances'>
	^(self new)
	    selector: aSymbol;
	    arguments: { anObject }
    ]

    Message class >> selector: aSymbol arguments: anArray [
	"Create a new Message with the given selector and arguments"

	<category: 'creating instances'>
	^(self new)
	    selector: aSymbol;
	    arguments: anArray
    ]

    printAsAttributeOn: aStream [
	"Print a representation of the receiver on aStream, modeling
	 it after the source code for a attribute."

	<category: 'basic'>
	aStream nextPut: $<.
	(self selector includes: $:) 
	    ifFalse: 
		[aStream nextPutAll: self selector.
		self arguments do: [:arg | aStream store: arg]]
	    ifTrue: 
		[(self selector substrings: $:) with: self arguments
		    do: 
			[:sel :arg | 
			aStream
			    nextPutAll: sel;
			    nextPutAll: ': ';
			    store: arg;
			    nextPut: $ ]].
	aStream nextPut: $>
    ]

    printOn: aStream [
	"Print a representation of the receiver on aStream"

	<category: 'printing'>
	(self selector includes: $:) 
	    ifFalse: 
		[aStream nextPutAll: self selector.
		self arguments do: 
			[:arg | 
			aStream
			    nextPutAll: ' <';
			    print: arg;
			    nextPutAll: '> ']]
	    ifTrue: 
		[(self selector substrings: $:) with: self arguments
		    do: 
			[:sel :arg | 
			aStream
			    nextPutAll: sel;
			    nextPutAll: ': <';
			    print: arg;
			    nextPutAll: '> ']]
    ]

    sendTo: aReceiver [
	"Resend to aReceiver"

	<category: 'printing'>
	^aReceiver perform: selector withArguments: args
    ]

    reinvokeFor: aReceiver [
	"Resend to aReceiver - present for compatibility"

	<category: 'printing'>
	^aReceiver perform: selector withArguments: args
    ]

    selector: aSymbol [
	"Set the receiver's selector"

	<category: 'accessing'>
	selector := aSymbol
    ]

    arguments: anArray [
	"Set the receiver's arguments"

	<category: 'accessing'>
	args := anArray
    ]

    selector [
	"Answer the receiver's selector"

	<category: 'accessing'>
	^selector
    ]

    argument [
	"Answer the first of the receiver's arguments"

	<category: 'accessing'>
	^args at: 1
    ]

    arguments [
	"Answer the receiver's arguments"

	<category: 'accessing'>
	^args
    ]
]

