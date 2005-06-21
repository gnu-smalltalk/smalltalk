"======================================================================
|
|   MethodContext Method Definitions
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2002
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


ContextPart variableSubclass: #MethodContext
       instanceVariableNames: 'flags '
       classVariableNames: ''
       poolDictionaries: ''
       category: 'Language-Implementation'
!

MethodContext comment: 
'My instances represent an actively executing method.  They record various
bits of information about the execution environment, and contain the
execution stack.' !


!MethodContext methodsFor: 'printing'!

printOn: aStream
    "Print a representation for the receiver on aStream"

    self receiver class printOn: aStream in: Namespace current.

    self receiver class == self methodClass ifFalse: [
	aStream nextPut: $(.
	self methodClass printOn: aStream in: Namespace current.
	aStream nextPut: $).
    ].
    aStream
	nextPutAll: '>>';
	print: self selector.

    self isDisabled ifTrue: [
	aStream nextPutAll: '<disabled>'
    ]
! !



!MethodContext methodsFor: 'accessing'!

isDisabled
    "Answers whether the receiver has actually ended execution and will
     be skipped when doing a return.  BlockContexts are removed from the
     chain whenever a non-local return is done, but MethodContexts need to
     stay there in case there is a non-local return from the #ensure:
     block."
    ^flags == 1
!

isUnwind
    "Answers whether the context must continue execution even after a
     non-local return (a return from the enclosing method of a block, or
     a call to the #continue: method of ContextPart).  Such contexts are
     created only by #ensure:."
    ^(flags bitAnd: 2) == 2
!

isEnvironment
    "To create a valid execution environment for the interpreter even before
     it starts, GST creates a fake context whose selector is nil and which
     can be used as a marker for the current execution environment.  Answer
     whether the receiver is that kind of context."
    ^(flags bitAnd: 4) == 4
!

sender
    "Return the context from which the receiver was sent"
    ^self parentContext
!

home
    "Answer the MethodContext to which the receiver refers
     (i.e. the receiver itself)"
    ^self
!

isBlock
    "Answer whether the receiver is a block context"
    ^false
! !
