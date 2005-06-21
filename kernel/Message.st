"======================================================================
|
|   Message Method Definitions
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001
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


Object subclass: #Message
       instanceVariableNames: 'selector args'
       classVariableNames: ''
       poolDictionaries: ''
       category: 'Language-Implementation'
!

Message comment: 
'I am a virtually existent class.  By that I mean that logically instances of 
my class are created whenever a message is sent to an object, but in reality
my instances are only created to hold a message that has failed, so that
error reporting methods can examine the sender and arguments.' !
	   


!Message methodsFor: 'basic'!

printOn: aStream
    "Print a representation of the receiver on aStream"

    (self selector includes: $:)
	ifFalse: [
	    aStream nextPutAll: self selector.
	    self arguments do: [ :arg |
		aStream
		    nextPutAll: ' <';
		    print: arg;
		    nextPutAll: '> '
	    ]
	]
	ifTrue: [
	    (self selector substrings: $:) with: self arguments do: [:sel :arg |
		aStream
		    nextPutAll: sel;
		    nextPutAll: ': <';
		    print: arg;
		    nextPutAll: '> '
	    ]
	]
!

sendTo: aReceiver
    "Resend to aReceiver"
    ^aReceiver perform: selector withArguments: args
!

reinvokeFor: aReceiver
    "Resend to aReceiver - present for compatibility"
    ^aReceiver perform: selector withArguments: args
! !


!Message methodsFor: 'accessing'!

selector: aSymbol
    "Set the receiver's selector"
    selector := aSymbol
!

arguments: anArray
    "Set the receiver's arguments"
    args := anArray
!

selector
    "Answer the receiver's selector"
    ^selector
!

argument
    "Answer the first of the receiver's arguments"
    ^args at: 1
!

arguments
    "Answer the receiver's arguments"
    ^args
! !


!Message class methodsFor: 'creating instances'!

selector: aSymbol arguments: anArray
    "Create a new Message with the given selector and arguments"
    ^self new selector: aSymbol; arguments: anArray
! !

