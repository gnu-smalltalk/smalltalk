"======================================================================
|
|   Core (instance-based) exception handling classes
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1999, 2000, 2001, 2002, 2003 Free Software Foundation, Inc.
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



"Create these symbols. AnsiExcept.st will assign values to them; Also create
 some classes"

Smalltalk at: #ExAll put: nil.
Smalltalk at: #ExHalt put: nil.
Smalltalk at: #ExError put: nil.
Smalltalk at: #ExDoesNotUnderstand put: nil.
Smalltalk at: #ExUserBreak put: nil.

Object subclass: #Signal
    instanceVariableNames: 'exception arguments tag messageText resumeBlock onDoBlock handlerBlock context nested previousState'
    classVariableNames: 'NoTag'
    poolDictionaries: ''
    category: 'Language-Exceptions'.

Object subclass: #TrappableEvent
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Language-Exceptions'!

TrappableEvent subclass: #CoreException
    instanceVariableNames: 'parent resumable description defaultHandler signalClass depth'
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Language-Exceptions'.

TrappableEvent subclass: #ExceptionSet
    instanceVariableNames: 'collection'
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Language-Exceptions'!

"The classes were created. Add their comments."

TrappableEvent comment: '
I am an abstract class for arguments passed to #on:do:... methods in
BlockClosure. I define a bunch of methods that apply to CoreExceptions
and ExceptionSets: they allow you to create ExceptionSets
and examine all the exceptions to be trapped.'.

CoreException comment: '
My instances describe a single event that can be trapped using #on:do:...,
contain whether such execution can be resumed after such an event, a
description of what happened, and a block that is used as an handler by
default. Using my methods you can raise exceptions and create new exceptions.
Exceptions are organized in a kind of hierarchy (different from the class
hierarchy): intercepting an exception will intercept all its children too.

CoreExceptions are different from ANSI Exceptions in that the signaled
exception is not an instance of the CoreException, instead it belongs
to a different class, Signal.  ANSI Exceptions inherit from Signal but
hold on to a CoreException via a class-instance variable.'.

ExceptionSet comment: '
My instances are not real exceptions: they can only be used as arguments to
#on:do:... methods in BlockClosure. They act as shortcuts that allows you to
use the same handler for many exceptions without having to write duplicate
code'.

Signal comment: '
My instances describe an exception that has happened, and are passed to
exception handlers. Apart from containing information on the generated
exception and its arguments, they contain methods that allow you to resume
execution, leave the #on:do:... snippet, and pass the exception to an handler
with a lower priority.'!


!TrappableEvent methodsFor: 'instance creation'!

, aTrappableEvent
    "Answer an ExceptionSet containing all the exceptions in the
     receiver and all the exceptions in aTrappableEvent"

    ^ExceptionSet new
	add: self;
	add: aTrappableEvent;
	yourself
! !


!TrappableEvent methodsFor: 'enumerating'!

allExceptionsDo: aBlock
    "Execute aBlock, passing it an Exception for every exception in the
     receiver."

    self subclassResponsibility
!

goodness: exception
    "Answer how good the receiver is at handling the given exception.  A
     negative value indicates that the receiver is not able to handle
     the exception."
    self subclassResponsibility
!

handles: exception
    "Answer whether the receiver handles `exception'."

    self subclassResponsibility
! !


!CoreException methodsFor: 'basic'!

postCopy
    "Modify the receiver so that the description is deep copied"
    super postCopy.
    self description: self description copy
! !


!CoreException methodsFor: 'accessing'!

defaultHandler
    "Answer the default handler for the receiver"

    ^defaultHandler
!

defaultHandler: aBlock
    "Set the default handler of the receiver to aBlock. A Signal object will
     be passed to aBlock"

    defaultHandler := aBlock
!

description
    "Answer a description of the receiver"
    ^description
!

description: aString
    "Set the description of the receiver to aString"
    description := aString
!

parent
    "Answer the parent of the receiver"
    ^parent
!

isResumable
    "Answer true if the receiver is resumable"
    ^resumable
!

isResumable: aBoolean
    "Set the resumable flag of the receiver to aBoolean"
    resumable := aBoolean
!

signalClass
    "Answer the subclass of Signal to be passed to handler blocks
     that handle the receiver"
    ^signalClass
!

signalClass: aClass
    "Set which subclass of Signal is to be passed to handler blocks
     that handle the receiver"
    signalClass := aClass
! !


!CoreException methodsFor: 'instance creation'!

newChild
    "Answer a child exception of the receiver. Its properties are set to those
     of the receiver"

    ^self species basicNew
	description: self description copy;
	isResumable: self isResumable;
	depth: self depth + 1;
	defaultHandler: nil;
	parent: self;
	signalClass: Signal;
	yourself
! !


!CoreException methodsFor: 'exception handling'!

signal
    "Raise the exception described by the receiver, passing no parameters"
    
    "This is not refactored to avoid too long backtraces"
    | signal |
    signal := signalClass new
	initArguments: #();
	initException: self.

    self instantiateNextHandler: signal.
    ^signal activateHandler: false
!

signalWith: arg
    "Raise the exception described by the receiver, passing the parameter arg"

    "This is not refactored to avoid too long backtraces"
    | signal |
    signal := signalClass new
	initArguments: {arg};
	initException: self.

    self instantiateNextHandler: signal.
    ^signal activateHandler: false
!

signalWith: arg with: arg2
    "Raise the exception described by the receiver, passing the parameters arg
     and arg2"

    "This is not refactored to avoid too long backtraces"
    | signal |
    signal := signalClass new
	initArguments: {arg. arg2};
	initException: self.

    self instantiateNextHandler: signal.
    ^signal activateHandler: false
!

signalWithArguments: args
    "Raise the exception described by the receiver, passing the parameters in
     args"

    "This is not refactored to avoid too long backtraces"
    | signal |
    signal := signalClass new
	initArguments: args;
	initException: self.

    self instantiateNextHandler: signal.
    ^signal activateHandler: false
! !


!CoreException methodsFor: 'enumerating'!

allExceptionsDo: aBlock
    "Private - Evaluate aBlock for every exception in the receiver. As it contains just one
     exception, evaluate it just once, passing the receiver"

    aBlock value: self
!

goodness: exception
    "Answer how good the receiver is at handling the given exception.  A
     negative value indicates that the receiver is not able to handle
     the exception."

    (self handles: exception) ifFalse: [ ^-1 ].

    "In general, the deeper is the exception, the more fine-grained the
     control is and the higher is the goodness (as long as the receiver
     can handle the exception)."
    ^depth
!

handles: exceptionOrSignal
    "Answer whether the receiver handles `exceptionOrSignal'."

    | exc |
    (exceptionOrSignal class == self class)
	ifFalse: [ ^self handles: exceptionOrSignal exception ].

    exc := exceptionOrSignal.
    [   exc == self ifTrue: [ ^true ].
	exc isNil
    ] whileFalse: [
	exc := exc parent.
    ].
    ^false
! !


!CoreException methodsFor: 'private'!

depth
    "Private - Answer the depth of the receiver in the exception hierarchy"
    ^depth
!

depth: anInteger
    "Private - Set the depth of the receiver in the exception hierarchy"
    depth := anInteger
!

instantiateNextHandler: aSignal
    "Private - Tell aSignal what it needs on the next handler for the receiver.
     If one is not found found, look for an handler for our parent, until one
     is found or ExAll if reached and there is no handler. In this case, answer
     the default handler for anException."

    | exc nested |
    exc := self.

    [
	nested := false. 
	thisContext 
	    scanBacktraceFor:
		#(#on:do:
		  #on:do:on:do:
		  #on:do:on:do:on:do:
		  #on:do:on:do:on:do:on:do:
		  #on:do:on:do:on:do:on:do:on:do:)
	    do: [ :context || best bestGoodness goodness activeHandlers |
		bestGoodness := -1.
		activeHandlers := context at: context numArgs + 1.

		1 to: context numArgs - 1 by: 2 do: [ :i |
		    goodness := (context at: i) goodness: exc.
		    goodness > -1 ifTrue: [
		        (activeHandlers bitAt: i) = 1 ifTrue: [
			    "Sorry, this handler is already active..."
			    nested := true.
			    goodness := -1.
			]
		    ].
		    goodness > bestGoodness ifTrue: [
			best := i.
			bestGoodness := goodness.
		    ]
		].

		"Now instantiate the best handler we found"
		best isNil ifFalse: [
		    context
			at: context numArgs + 1
			put: (activeHandlers setBit: best).

		    aSignal
			onDoBlock: context receiver
			handlerBlock: (context at: best + 1)
			onDoContext: context
			nested: nested
			previousState: activeHandlers.

		    ^self
		]
	    ].

	exc == ExAll
    ]   whileFalse: [
	exc := exc parent
    ].
    aSignal
	onDoBlock: nil
	handlerBlock: self actualDefaultHandler
	onDoContext: nil
	nested: false
	previousState: nil
!

activateOuterHandlerFor: aSignal
    "Private - Raise the exception described by the receiver, passing a
     Signal modeled after aSignal, and returning the return value of the
     handler."

    "This is not refactored to avoid too long backtraces"
    | signal |
    signal := signalClass new
	initException: self;
	copyFrom: aSignal.

    self instantiateNextHandler: signal.
    ^signal activateHandler: true
!

actualDefaultHandler
    "Private - Answer the default handler for the receiver. It differs from
     #defaultHandler because if the default handler of the parent has to be
     used #defaultHandler answers nil, while #actualDefaultHandler calls
     #actualDefaultHandler for the parent and answers its result"

    ^defaultHandler isNil
	ifTrue: [self parent actualDefaultHandler]
	ifFalse: [defaultHandler]
! !


!CoreException methodsFor: 'private - accessing'!

parent: anException
    "Private - Set the parent of the receiver to anException"
    parent := anException
! !


!CoreException class methodsFor: 'instance creation'!

new
    "Create a new exception whose parent is ExAll"

    ^ExAll newChild
! !


!CoreException class methodsFor: 'private'!

resetAllHandlers
    "Private, class - Reset the handlers for all the exceptions; that is, the
     next handlers used will be the first to be declared"

    thisContext
	scanBacktraceFor: #(#on:do: #on:do:on:do:
		#on:do:on:do:on:do: #on:do:on:do:on:do:on:do: 
		#on:do:on:do:on:do:on:do:on:do:)
	do: [ :context |
	    context receiver class == BlockClosure ifTrue: [
		context at: context numArgs + 1 put: 0
	    ]
	]
! !


!ExceptionSet class methodsFor: 'instance creation'!

new
    "Private - Answer a new, empty ExceptionSet"
    ^self basicNew
	collection: Set new
! !


!ExceptionSet methodsFor: 'enumerating'!

allExceptionsDo: aBlock
    "Private - Evaluate aBlock for every exception in the receiver. Answer the
     receiver"

    collection do: aBlock
!

goodness: exception
    "Answer how good the receiver is at handling the given exception.  A
     negative value indicates that the receiver is not able to handle
     the exception."
    ^collection
	inject: -1
	into: [ :old :each | old max: (each goodness: exception) ]
!

handles: exception
    "Answer whether the receiver handles `exception'."

    ^collection
	anySatisfy: [ :someItem | someItem handles: exception ]
! !


!ExceptionSet methodsFor: 'private - accessing'!

add: aTrappableEvent
    "Private - Add aTrappableEvent to the receiver and answer aTrappableEvent"
    aTrappableEvent allExceptionsDo: [ :exc | collection add: exc ].

    ^aTrappableEvent
!

collection: aSet
    "Private - Set the collection of exception included in the receiver to
     aSet"
    collection := aSet.
    ^self
! !


!Signal methodsFor: 'accessing'!

argumentCount
    "Answer how many arguments the receiver has"
    ^arguments size
!

argument
    "Answer the first argument of the receiver"
    ^arguments at: 1
!

arguments
    "Answer the arguments of the receiver"
    ^arguments
!

description
    "Answer the description of the raised exception"
    ^self exception description
!

basicMessageText
    "Answer an exception's message text.  Do not override this method."
    ^messageText
!

messageText
    "Answer an exception's message text."
    ^messageText
!

messageText: aString
    "Set an exception's message text."
    messageText := aString
!

tag
    "Answer an exception's tag value.  If not specified, it
     is the same as the message text."
    ^tag == self noTag
	ifTrue: [ self messageText ]
	ifFalse: [ tag ]
!

tag: anObject
    "Set an exception's tag value.  If nil, the tag value will
     be the same as the message text."
    tag := anObject
!

exception
    "Answer the CoreException that was raised"
    ^exception
! !


!Signal methodsFor: 'exception handling'!

defaultAction
    "Execute the default handler for the raised exception"
    self exception actualDefaultHandler value: self
!

isNested
    "Answer whether the current exception handler is within the scope of
     another handler for the same exception."
    ^nested
!

isResumable
    "Answer whether the exception that instantiated the receiver is resumable."
    ^self exception isResumable
!

outer
    "Raise the exception that instantiated the receiver, passing the same
     parameters.
     If the receiver is resumable and the evaluated exception action resumes
     then the result returned from #outer will be the resumption value of the
     evaluated exception action. If the receiver is not resumable or if the
     exception action does not resume then this message will not return, and
     #outer will be equivalent to #pass."

    ^self exception activateOuterHandlerFor: self
!

pass
    "Yield control to the enclosing exception action for the receiver.
     Similar to #outer, but control does not return to the currently active exception
     handler."

    ^self return: (self exception activateOuterHandlerFor: self)
!

resume
    "If the exception is resumable, resume the execution of the block that
     raised the exception; the method that was used to signal the exception
     will answer the receiver.
     Use this method IF AND ONLY IF you know who caused the exception and if
     it is possible to resume it in that particular case"

    self isResumable ifFalse: [
	self primError: 'Exception not resumable - #resume failed'
    ].

    self resetHandler.
    resumeBlock value: self
!

resume: anObject
    "If the exception is resumable, resume the execution of the block that
     raised the exception; the method that was used to signal the exception
     will answer anObject.
     Use this method IF AND ONLY IF you know who caused the exception and if
     it is possible to resume it in that particular case"

    self isResumable ifFalse: [
	self primError: 'Exception not resumable - #resume: failed'
    ].

    self resetHandler.
    resumeBlock value: anObject
!

resignalAs: replacementException
    "Reinstate all handlers and execute the handler for `replacementException';
     control does not return to the currently active exception handler. The
     new Signal object that is created has the same arguments as the receiver
     (this might or not be correct -- if it isn't you can use an idiom such
     as `sig retryUsing: [ replacementException signal ])"

    CoreException resetAllHandlers.
    replacementException passFor: self
!

retry
    "Re-execute the receiver of the #on:do: message. All handlers are
     reinstated: watch out, this can easily cause an infinite loop."

    onDoBlock isNil ifTrue: [
	self primError: 'No exception handler effective - #retry failed'
    ].
    CoreException resetAllHandlers.
    self return: onDoBlock value
!

retryUsing: aBlock
    "Execute aBlock reinstating all handlers, and return its result from
     the #signal method."

    CoreException resetAllHandlers.
    self return: aBlock value
!

return
    "Exit the #on:do: snippet, answering anObject to its caller"

    context isNil ifTrue: [
	self primError: 'No exception handler effective - #return failed'
    ].
    context parentContext continue: nil.
!

return: anObject
    "Exit the #on:do: snippet, answering anObject to its caller"

    context isNil ifTrue: [
	self primError: 'No exception handler effective - #return failed'
    ].
    context parentContext continue: anObject.
! !


!Signal methodsFor: 'private'!

activateHandler: resumeBoolean
    "Run the handler, passing to it aSignal, an instance of Signal.  aBoolean
     indicates the action (either resuming the receiver of #on:do:... or
     exiting it) to be taken upon leaving from the handler block."

    | result |
    resumeBlock := [ :object |
	self resetHandler.
	^object ].

    result := handlerBlock value: self.
    resumeBoolean
	ifTrue: [
	    self resetHandler.
	    ^result
	].

    context parentContext continue: result
!

onDoBlock: wdBlock handlerBlock: hBlock onDoContext: ctx nested: aBoolean previousState: anInteger
    "Initialize the receiver's instance variables."
    nested := aBoolean.
    previousState := anInteger.
    context := ctx.
    onDoBlock := wdBlock.
    handlerBlock := hBlock.
    ^self
!

resetHandler
    "Mark the handler that the receiver is using as not active."
    context isNil ifFalse: [
	context at: context numArgs + 1 put: previousState ]
!

copyFrom: aSignal
    "Private - Initialize from another instance of Signal"

    self
	initArguments: aSignal arguments;
	messageText: aSignal messageText;
	tag: aSignal tag
!

initArguments: args
    "Private - set the Signal's arguments to args."

    arguments := args.
    tag := self noTag.
!

initException: exc
    "Private - set the exception that was raised to exc"

    exception := exc.
    messageText := exc description.
!

noTag
    NoTag isNil ifTrue: [ NoTag := Object new ].
    ^NoTag
! !


!Object methodsFor: 'built ins'!

primError: message

    "This might start the debugger... Note that we use #basicPrint
     'cause #printOn: might invoke an error."

    | debuggerClass context |
    Transcript initialize.    
    stdout flush.
    debuggerClass := thisContext debuggerClass.
    debuggerClass isNil ifFalse: [
	^debuggerClass
	    openOn: Processor activeProcess
	    message: self class printString, ' error: ', message
    ].

    "Default behavior - print backtrace"
    RegressionTesting ifFalse: [ self basicPrint ].
    stdout
	nextPutAll: ' error: ';
	display: message;
	nl.

    RegressionTesting ifFalse: [
	context := thisContext.
	[ context isInternalExceptionHandlingContext ]
	    whileTrue: [ context := context parentContext ].

	context backtraceOn: stdout
    ].

    stdout flush.
    ContextPart unwind
! !

"
An example of exception handling follows:

| loopExitException random |
random := Random new.
loopExitException := ExAll newChild.
^[ [
      random next < 0.2 ifTrue: [ loopExitException signal ].
      1 error: 'hello!'
   ] repeat
 ] on: loopExitException do: [:sig | sig return: 'bye' ]
   on: ExError do: [:sig | sig arguments printNl. sig resume ]

"

"
[
   [ Error signal ] on: Error do: [ :sig | 'passing' printNl. sig pass ]
] on: Error do: [ :sig | 'passed' printNl. sig inspect ]
"
