"======================================================================
|
|   DirectedMessage Method Definitions
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1999, 2000, 2001, 2002 Free Software Foundation, Inc.
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
| 330, Boston, MA 02111-1307, USA.  
|
 ======================================================================"



Message subclass: #DirectedMessage
    instanceVariableNames: 'receiver '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Language-Implementation'!

DirectedMessage comment: 
'I represent a message send: I contain the receiver, selector and arguments
for a message.'!
	   

!DirectedMessage methodsFor: 'basic'!

printOn: aStream
    "Print a representation of the receiver on aStream"

    aStream print: receiver; space.
    super printOn: aStream
!

send
    "Send the message"
    ^self sendTo: receiver
!

value
    "Send the message (this message provides interoperability
     between DirectedMessages and blocks)"
    ^self sendTo: receiver
! !


!DirectedMessage methodsFor: 'accessing'!

receiver: anObject
    "Change the receiver"
    receiver := anObject
!

receiver
    "Answer the receiver"
    ^receiver
! !


!DirectedMessage methodsFor: 'multiple process'!

fork
    "Create a new process executing the receiver and start it"
    ^Process
        on: self
        at: Processor activePriority
        suspend: false
!

forkAt: priority
    "Create a new process executing the receiver with given priority
     and start it"
    ^Process
        on: self
        at: priority
        suspend: false
!

newProcess
    "Create a new process executing the receiver in suspended state.
     The priority is the same as for the calling process. The receiver
     must not contain returns"
    ^Process
        on: self
        at: Processor activePriority
        suspend: true
! !


!DirectedMessage methodsFor: 'saving and loading'!

reconstructOriginalObject
    "This method is used when DirectedMessages are used together
     with PluggableProxies (see ObjectDumper).  It sends the receiver
     to reconstruct the object that was originally stored."
    ^self send
! !


!DirectedMessage class methodsFor: 'creating instances'!

selector: aSymbol arguments: anArray 
    self shouldNotImplement
!

selector: aSymbol arguments: anArray receiver: anObject
    "Create a new instance of the receiver"

    ^(super selector: aSymbol arguments: anArray)
	receiver: anObject
! !
