"======================================================================
|
|   Core (instance-based) exception handling classes
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999, 2000, 2001, 2002, 2003, 2008 Free Software Foundation, Inc.
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

"Create these symbols. AnsiExcept.st will assign values to them; Also create
 some classes"



Eval [
    Smalltalk at: #ExAll put: nil.
    Smalltalk at: #ExHalt put: nil.
    Smalltalk at: #ExError put: nil.
    Smalltalk at: #ExDoesNotUnderstand put: nil.
    Smalltalk at: #ExUserBreak put: nil
]



Namespace current: Kernel [

Object subclass: TrappableEvent [
    
    <category: 'Language-Exceptions'>
    <comment: '
I am an abstract class for arguments passed to #on:do:... methods in
BlockClosure. I define a bunch of methods that apply to CoreExceptions
and ExceptionSets: they allow you to create ExceptionSets
and examine all the exceptions to be trapped.'>

    , aTrappableEvent [
	"Answer an ExceptionSet containing all the exceptions in the
	 receiver and all the exceptions in aTrappableEvent"

	<category: 'instance creation'>
	^(ExceptionSet new)
	    add: self;
	    add: aTrappableEvent;
	    yourself
    ]

    allExceptionsDo: aBlock [
	"Execute aBlock, passing it an Exception for every exception in the
	 receiver."

	<category: 'enumerating'>
	self subclassResponsibility
    ]

    goodness: exception [
	"Answer how good the receiver is at handling the given exception.  A
	 negative value indicates that the receiver is not able to handle
	 the exception."

	<category: 'enumerating'>
	self subclassResponsibility
    ]

    handles: exception [
	"Answer whether the receiver handles `exception'."

	<category: 'enumerating'>
	self subclassResponsibility
    ]
]

]



Namespace current: Kernel [

TrappableEvent subclass: CoreException [
    | parent resumable description defaultHandler signalClass depth |
    
    <category: 'Language-Exceptions'>
    <comment: '
My instances describe a single event that can be trapped using #on:do:...,
contain whether such execution can be resumed after such an event, a
description of what happened, and a block that is used as an handler by
default. Using my methods you can raise exceptions and create new exceptions.
Exceptions are organized in a kind of hierarchy (different from the class
hierarchy): intercepting an exception will intercept all its children too.

CoreExceptions are different from ANSI Exceptions in that the signaled
exception is not an instance of the CoreException, instead it belongs
to a different class, Signal.  ANSI Exceptions inherit from Signal but
hold on to a CoreException via a class-instance variable.'>

    CoreException class >> new [
	"Create a new exception whose parent is ExAll"

	<category: 'instance creation'>
	^ExAll newChild
    ]

    CoreException class >> resetAllHandlers [
	"Private, class - Reset the handlers for all the exceptions; that is, the
	 next handlers used will be the first to be declared"

	<category: 'private'>
	thisContext scanBacktraceForAttribute: #exceptionHandlerSearch:reset:
	    do: [:context :attr | (attr arguments at: 2) value: context]
    ]

    postCopy [
	"Modify the receiver so that the description is deep copied"

	<category: 'basic'>
	super postCopy.
	self description: self description copy
    ]

    defaultHandler [
	"Answer the default handler for the receiver"

	<category: 'accessing'>
	^defaultHandler
    ]

    defaultHandler: aBlock [
	"Set the default handler of the receiver to aBlock. A Signal object will
	 be passed to aBlock"

	<category: 'accessing'>
	defaultHandler := aBlock
    ]

    description [
	"Answer a description of the receiver"

	<category: 'accessing'>
	^description
    ]

    description: aString [
	"Set the description of the receiver to aString"

	<category: 'accessing'>
	description := aString
    ]

    parent [
	"Answer the parent of the receiver"

	<category: 'accessing'>
	^parent
    ]

    isResumable [
	"Answer true if the receiver is resumable"

	<category: 'accessing'>
	^resumable
    ]

    isResumable: aBoolean [
	"Set the resumable flag of the receiver to aBoolean"

	<category: 'accessing'>
	resumable := aBoolean
    ]

    signalClass [
	"Answer the subclass of Signal to be passed to handler blocks
	 that handle the receiver"

	<category: 'accessing'>
	^signalClass
    ]

    signalClass: aClass [
	"Set which subclass of Signal is to be passed to handler blocks
	 that handle the receiver"

	<category: 'accessing'>
	signalClass := aClass
    ]

    newChild [
	"Answer a child exception of the receiver. Its properties are set to those
	 of the receiver"

	<category: 'instance creation'>
	^(self species basicNew)
	    description: self description copy;
	    isResumable: self isResumable;
	    depth: self depth + 1;
	    defaultHandler: nil;
	    parent: self;
	    signalClass: Signal;
	    yourself
    ]

    signal [
	"Raise the exception described by the receiver, passing no parameters"

	"This is not refactored to avoid too long backtraces"

	<category: 'exception handling'>
	| signal |
	signal := (signalClass new)
		    initArguments: #();
		    initException: self.
	self instantiateNextHandler: signal from: thisContext.
	^signal activateHandler: false
    ]

    signalWith: arg [
	"Raise the exception described by the receiver, passing the parameter arg"

	"This is not refactored to avoid too long backtraces"

	<category: 'exception handling'>
	| signal |
	signal := (signalClass new)
		    initArguments: {arg};
		    initException: self.
	self instantiateNextHandler: signal from: thisContext.
	^signal activateHandler: false
    ]

    signalWith: arg with: arg2 [
	"Raise the exception described by the receiver, passing the parameters arg
	 and arg2"

	"This is not refactored to avoid too long backtraces"

	<category: 'exception handling'>
	| signal |
	signal := (signalClass new)
		    initArguments: 
			    {arg.
			    arg2};
		    initException: self.
	self instantiateNextHandler: signal from: thisContext.
	^signal activateHandler: false
    ]

    signalWithArguments: args [
	"Raise the exception described by the receiver, passing the parameters in
	 args"

	"This is not refactored to avoid too long backtraces"

	<category: 'exception handling'>
	| signal |
	signal := (signalClass new)
		    initArguments: args;
		    initException: self.
	self instantiateNextHandler: signal from: thisContext.
	^signal activateHandler: false
    ]

    allExceptionsDo: aBlock [
	"Private - Evaluate aBlock for every exception in the receiver. As it contains just one
	 exception, evaluate it just once, passing the receiver"

	<category: 'enumerating'>
	aBlock value: self
    ]

    goodness: exception [
	"Answer how good the receiver is at handling the given exception.  A
	 negative value indicates that the receiver is not able to handle
	 the exception."

	<category: 'enumerating'>
	(self handles: exception) ifFalse: [^-1].

	"In general, the deeper is the exception, the more fine-grained the
	 control is and the higher is the goodness (as long as the receiver
	 can handle the exception)."
	^depth
    ]

    handles: exceptionOrSignal [
	"Answer whether the receiver handles `exceptionOrSignal'."

	<category: 'enumerating'>
	| exc |
	exceptionOrSignal class == self class 
	    ifFalse: [^self handles: exceptionOrSignal exception].
	exc := exceptionOrSignal.
	
	[exc == self ifTrue: [^true].
	exc isNil] whileFalse: [exc := exc parent].
	^false
    ]

    depth [
	"Private - Answer the depth of the receiver in the exception hierarchy"

	<category: 'private'>
	^depth
    ]

    depth: anInteger [
	"Private - Set the depth of the receiver in the exception hierarchy"

	<category: 'private'>
	depth := anInteger
    ]

    instantiateNextHandler: aSignal from: aContext [
	"Private - Tell aSignal what it needs on the next handler for the receiver.
	 If none is found, look for an handler for our parent, until one
	 is found or ExAll if reached and there is no handler. In this case, answer
	 the default handler for anException."

	<category: 'private'>
	aContext parentContext scanBacktraceForAttribute: #exceptionHandlerSearch:reset:
	    do: 
		[:context :attr | 
		| status |
		status := (attr arguments at: 1) value: context value: aSignal.
		status == #found ifTrue: [^self]].
	aSignal 
	    onDoBlock: nil
	    handlerBlock: self actualDefaultHandler
	    onDoContext: nil
	    previousState: nil
    ]

    actualDefaultHandler [
	"Private - Answer the default handler for the receiver. It differs from
	 #defaultHandler because if the default handler of the parent has to be
	 used #defaultHandler answers nil, while #actualDefaultHandler calls
	 #actualDefaultHandler for the parent and answers its result"

	<category: 'private'>
	^defaultHandler isNil 
	    ifTrue: [self parent actualDefaultHandler]
	    ifFalse: [defaultHandler]
    ]

    parent: anException [
	"Private - Set the parent of the receiver to anException"

	<category: 'private - accessing'>
	parent := anException
    ]
]

]



Kernel.TrappableEvent subclass: ExceptionSet [
    | collection |
    
    <category: 'Language-Exceptions'>
    <comment: '
My instances are not real exceptions: they can only be used as arguments to
#on:do:... methods in BlockClosure. They act as shortcuts that allows you to
use the same handler for many exceptions without having to write duplicate
code'>

    ExceptionSet class >> new [
	"Private - Answer a new, empty ExceptionSet"

	<category: 'instance creation'>
	^self basicNew collection: Set new
    ]

    allExceptionsDo: aBlock [
	"Private - Evaluate aBlock for every exception in the receiver. Answer the
	 receiver"

	<category: 'enumerating'>
	collection do: aBlock
    ]

    goodness: exception [
	"Answer how good the receiver is at handling the given exception.  A
	 negative value indicates that the receiver is not able to handle
	 the exception."

	<category: 'enumerating'>
	^collection inject: -1
	    into: [:old :each | old max: (each goodness: exception)]
    ]

    handles: exception [
	"Answer whether the receiver handles `exception'."

	<category: 'enumerating'>
	^collection anySatisfy: [:someItem | someItem handles: exception]
    ]

    add: aTrappableEvent [
	"Private - Add aTrappableEvent to the receiver and answer aTrappableEvent"

	<category: 'private - accessing'>
	aTrappableEvent allExceptionsDo: [:exc | collection add: exc].
	^aTrappableEvent
    ]

    collection: aSet [
	"Private - Set the collection of exception included in the receiver to
	 aSet"

	<category: 'private - accessing'>
	collection := aSet.
	^self
    ]
]



Object subclass: Signal [
    | exception arguments tag messageText resumeBlock onDoBlock handlerBlock context isNested previousState |
    
    <category: 'Language-Exceptions'>
    <comment: '
My instances describe an exception that has happened, and are passed to
exception handlers. Apart from containing information on the generated
exception and its arguments, they contain methods that allow you to resume
execution, leave the #on:do:... snippet, and pass the exception to an handler
with a lower priority.'>

    NoTag := nil.

    argumentCount [
	"Answer how many arguments the receiver has"

	<category: 'accessing'>
	^arguments size
    ]

    argument [
	"Answer the first argument of the receiver"

	<category: 'accessing'>
	^arguments at: 1
    ]

    arguments [
	"Answer the arguments of the receiver"

	<category: 'accessing'>
	^arguments
    ]

    description [
	"Answer the description of the raised exception"

	<category: 'accessing'>
	^self exception description
    ]

    basicMessageText [
	"Answer an exception's message text.  Do not override this method."

	<category: 'accessing'>
	^messageText
    ]

    messageText [
	"Answer an exception's message text."

	<category: 'accessing'>
	^messageText
    ]

    messageText: aString [
	"Set an exception's message text."

	<category: 'accessing'>
	messageText := aString
    ]

    tag [
	"Answer an exception's tag value.  If not specified, it
	 is the same as the message text."

	<category: 'accessing'>
	^tag == self noTag ifTrue: [self messageText] ifFalse: [tag]
    ]

    tag: anObject [
	"Set an exception's tag value.  If nil, the tag value will
	 be the same as the message text."

	<category: 'accessing'>
	tag := anObject
    ]

    exception [
	"Answer the CoreException that was raised"

	<category: 'accessing'>
	^exception
    ]

    postCopy [
	"Modify the receiver so that it does not refer to any instantiated
	 exception handler."

	<category: 'copying'>
	onDoBlock := nil.
	handlerBlock := nil.
	context := nil.
	isNested := nil.
	previousState := nil
    ]

    defaultAction [
	"Execute the default handler for the raised exception"

	<category: 'exception handling'>
	self exception actualDefaultHandler value: self
    ]

    isNested [
	"Answer whether the current exception handler is within the scope of
	 another handler for the same exception."

	<category: 'exception handling'>
	isNested isNil ifTrue: [isNested := false].
	^isNested
    ]

    isResumable [
	"Answer whether the exception that instantiated the receiver is resumable."

	<category: 'exception handling'>
	^self exception isResumable
    ]

    outer [
	"Raise the exception that instantiated the receiver, passing the same
	 parameters.
	 If the receiver is resumable and the evaluated exception action resumes
	 then the result returned from #outer will be the resumption value of the
	 evaluated exception action. If the receiver is not resumable or if the
	 exception action does not resume then this message will not return, and
	 #outer will be equivalent to #pass."

	<category: 'exception handling'>
	<exceptionHandlingInternal: false>
	| signal |
	signal := self copy.
	signal isNested: true.
        self exception instantiateNextHandler: signal from: self context.
        ^signal activateHandler: true
    ]

    pass [
	"Yield control to the enclosing exception action for the receiver.
	 Similar to #outer, but control does not return to the currently active exception
	 handler."

	<category: 'exception handling'>
	<exceptionHandlingInternal: false>
	| signal |
	signal := self copy.
	signal isNested: true.
        self exception instantiateNextHandler: signal from: self context.
        ^self return: (signal activateHandler: true)
    ]

    resume [
	"If the exception is resumable, resume the execution of the block that
	 raised the exception; the method that was used to signal the exception
	 will answer the receiver.
	 Use this method IF AND ONLY IF you know who caused the exception and if
	 it is possible to resume it in that particular case"

	<category: 'exception handling'>
	self isResumable 
	    ifFalse: [self primError: 'Exception not resumable - #resume failed'].
	self resetHandler.
	resumeBlock value: self
    ]

    resume: anObject [
	"If the exception is resumable, resume the execution of the block that
	 raised the exception; the method that was used to signal the exception
	 will answer anObject.
	 Use this method IF AND ONLY IF you know who caused the exception and if
	 it is possible to resume it in that particular case"

	<category: 'exception handling'>
	self isResumable 
	    ifFalse: [self primError: 'Exception not resumable - #resume: failed'].
	self resetHandler.
	resumeBlock value: anObject
    ]

    resignalAs: replacementException [
	"Reinstate all handlers and execute the handler for `replacementException';
	 control does not return to the currently active exception handler. The
	 new Signal object that is created has the same arguments as the receiver
	 (this might or not be correct -- if it isn't you can use an idiom such
	 as `sig retryUsing: [ replacementException signal ])"

	<category: 'exception handling'>
	Kernel.CoreException resetAllHandlers.
        replacementException exception
	    instantiateNextHandler: replacementException from: thisContext.
        ^replacementException return: (replacementException activateHandler: true)
    ]

    retry [
	"Re-execute the receiver of the #on:do: message. All handlers are
	 reinstated: watch out, this can easily cause an infinite loop."

	<category: 'exception handling'>
	onDoBlock isNil 
	    ifTrue: [self primError: 'No exception handler effective - #retry failed'].
	Kernel.CoreException resetAllHandlers.
	self return: onDoBlock value
    ]

    retryUsing: aBlock [
	"Execute aBlock reinstating all handlers, and return its result from
	 the #signal method."

	<category: 'exception handling'>
	Kernel.CoreException resetAllHandlers.
	self return: aBlock value
    ]

    context [
	"Return the execution context for the #on:do: snippet"

	<category: 'exception handling'>
	^context
    ]

    return [
	"Exit the #on:do: snippet, answering nil to its caller."

	<category: 'exception handling'>
	context isNil 
	    ifTrue: [self primError: 'No exception handler effective - #return failed'].
	Kernel.CoreException resetAllHandlers.
	context parentContext continue: nil
    ]

    return: anObject [
	"Exit the #on:do: snippet, answering anObject to its caller."

	<category: 'exception handling'>
	context isNil 
	    ifTrue: [self primError: 'No exception handler effective - #return: failed'].
	Kernel.CoreException resetAllHandlers.
	context parentContext continue: anObject
    ]

    activateHandler: resumeBoolean [
	"Run the handler, passing to it aSignal, an instance of Signal.  aBoolean
	 indicates the action (either resuming the receiver of #on:do:... or
	 exiting it) to be taken upon leaving from the handler block."

	<category: 'private'>
	| result |
	<exceptionHandlingInternal: true>
	resumeBlock := 
		[:object | 
		self resetHandler.
		^object].
	result := handlerBlock value: self.
	resumeBoolean 
	    ifTrue: 
		[self resetHandler.
		^result].
	context parentContext continue: result
    ]

    isNested: aBoolean [
	"Set the receiver's isNested instance variable."

	<category: 'private'>
	isNested := aBoolean
    ]

    onDoBlock: wdBlock handlerBlock: hBlock onDoContext: ctx previousState: anInteger [
	"Initialize the receiver's instance variables."

	<category: 'private'>
	previousState := anInteger.
	context := ctx.
	onDoBlock := wdBlock.
	handlerBlock := hBlock.
	^self
    ]

    resetHandler [
	"Mark the handler that the receiver is using as not active."

	<category: 'private'>
	context isNil 
	    ifFalse: [context at: context numArgs + 1 put: previousState]
    ]

    initArguments: args [
	"Private - set the Signal's arguments to args."

	<category: 'private'>
	arguments := args.
	tag := self noTag
    ]

    initException: exc [
	"Private - set the exception that was raised to exc"

	<category: 'private'>
	exception := exc.
	messageText := exc description
    ]

    noTag [
	<category: 'private'>
	NoTag isNil ifTrue: [NoTag := Object new].
	^NoTag
    ]
]



Object extend [

    primError: message [
	"This might start the debugger... Note that we use #basicPrint
	 'cause #printOn: might invoke an error."

	<category: 'built ins'>
	| debugger debuggerClass context |
	Transcript initialize.
	stdout flush.
	debugger := Processor activeDebugger.
	debugger isNil ifFalse: [^debugger stopInferior: message].
	debuggerClass := thisContext debuggerClass.
	debuggerClass isNil 
	    ifFalse: [^debuggerClass open: self class printString , ' error: ' , message].

	"Default behavior - print backtrace"
	RegressionTesting ifFalse: [self basicPrint].
	stdout
	    nextPutAll: ' error: ';
	    display: message;
	    nl.
	RegressionTesting 
	    ifFalse: 
		[context := thisContext.
		[context isInternalExceptionHandlingContext] 
		    whileTrue: [context := context parentContext].
		context backtraceOn: stdout].
	stdout flush.
	ContextPart unwind
    ]

]

