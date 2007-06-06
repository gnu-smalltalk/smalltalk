"======================================================================
|
|   Continuation Method Definitions
|
|
 ======================================================================"


"======================================================================
|
| Copyright (C) 2007 University of Manchester
| Originally by Ian Piumarta, rewritten by Paolo Bonzini.
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

Object subclass: #Continuation
    instanceVariableNames: 'stack '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Language-Implementation'!

Continuation comment:
'At my heart, I am something like the goto instruction; my creation
sets the label, and my methods do the jump.  However, this is a really
powerful kind of goto instruction. If your hair is turning green at
this point, don''t worry as you will probably only deal with users
of continuations, rather than with the concept itself.'!


!Continuation class methodsFor: 'instance creation'!

escapeDo: aBlock
    "Pass a continuation to the one-argument block, knowing that aBlock
     does not fall off (either because it includes a method return, or
     because it yields control to another continuation).  If it does,
     an exception will be signalled and the current process terminated."
    aBlock value: (self new stack: thisContext parentContext).
    SystemExceptions.BadReturn signal.
    Processor activeProcess terminate!

current
    "Return a continuation."
    ^self new stack: thisContext parentContext copyStack!

currentDo: aBlock
    "Pass a continuation to the one-argument block, aBlock and return the
     result of evaluating it."
    ^aBlock value: (self new stack: thisContext parentContext copyStack)! !

!Continuation methodsFor: 'invocation'!

oneShotValue
    "Return nil to the original continuation, which becomes unusable.
     Attempting to reactivate it will cause an exception.  This is an
     optimization over #value."
    ^self resume: nil nextContinuation: nil!

oneShotValue: v
    "Return anObject to the original continuation, which becomes unusable.
     Attempting to reactivate it will cause an exception.  This is an
     optimization over #value:."
    ^self resume: v nextContinuation: nil!

callCC
    "Activate the original continuation, passing back in turn a continuation
     for the caller.  The called continuation becomes unusable, and
     any attempt to reactivate it will cause an exception.  This is not
     a limitation, in general, because this method is used to replace a
     continuation with another (see the implementation of the Generator class)."
    | cont |
    cont := Continuation new stack: thisContext parentContext.
    ^self resume: cont nextContinuation: nil!

value
    "Return nil to the original continuation, copying the stack to allow
     another activation."
    ^self resume: nil nextContinuation: stack copyStack!

value: anObject
    "Return anObject to the original continuation, copying the stack to allow
     another activation."
    ^self resume: anObject nextContinuation: stack copyStack!

valueWithArguments: aCollection
    "Return the sole element of aCollection to the original continuation
     (or nil if aCollection is empty), copying the stack to allow
     another activation"
    aCollection size == 0 ifTrue: [ ^self value: nil ].
    aCollection size == 1 ifFalse: [^self value: (aCollection at: 1)].
    SystemExceptions.InvalidArgument
	signalOn: aCollection
	reason: 'continuations can only be resumed with zero or one argument'! !

!Continuation methodsFor: 'private'!

resume: returnValue nextContinuation: aContext
    <primitive: VMpr_Continuation_resume>
    SystemExceptions.BadReturn signal.
    Processor activeProcess terminate.
    ^returnValue

    "The primitive is equivalent to this code:
    | continuation |
    stack isNil ifTrue: [ ^self primitiveFailed ].
    continuation := stack.
    stack := aContext.
    thisContext parentContext: continuation.
    ^returnValue"!

stack
    ^stack!

stack: s
    stack := s! !

