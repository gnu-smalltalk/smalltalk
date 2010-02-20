"======================================================================
|
|   Core (instance-based) exception handling classes
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999, 2000, 2001, 2002, 2003, 2008, 2009
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

"Create these symbols. AnsiExcept.st will assign values to them; Also create
 some classes"



Object subclass: ExceptionSet [
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



Object subclass: Exception [
    | creator tag messageText resumeBlock onDoBlock handlerBlock context isNested previousState |
    
    <category: 'Language-Exceptions'>
    <comment: '
My instances describe an exception that has happened, and are passed to
exception handlers. Classes describe the kind of exception.

Apart from containing information on the generated exception,
my instances contain methods that allow you to resume
execution, leave the #on:do:... block, and pass the exception to an
handler with a lower priority.'>

    NoTag := nil.

    Exception class >> resetAllHandlers [
       "Private, class - Reset the handlers for all the exceptions; that is, the
        next handlers used will be the first to be declared"

       <category: 'private'>
       thisContext scanBacktraceForAttribute: #exceptionHandlerSearch:reset:
           do: [:context :attr | (attr arguments at: 2) value: context]
    ]

    Exception class >> new [
        "Create an instance of the receiver, which you will be able to
         signal later."

        <category: 'instance creation'>
        | ctx creator |
        ctx := thisContext parentContext.
        [(creator := ctx receiver) == self] whileTrue: [ctx := ctx parentContext].
        ^self basicNew initialize: creator
    ]

    Exception class >> signal [
        "Create an instance of the receiver, give it default attributes,
         and signal it immediately."

        <category: 'instance creation'>
        ^self new signal
    ]

    Exception class >> signal: messageText [
        "Create an instance of the receiver, set its message text,
         and signal it immediately."

        <category: 'instance creation'>
        ^(self new)
            messageText: messageText;
            signal
    ]

    Exception class >> , aTrappableEvent [
        "Answer an ExceptionCollection containing all the exceptions in the
         receiver and all the exceptions in aTrappableEvent"

        <category: 'creating ExceptionCollections'>
        ^(ExceptionSet new)
            add: self;
            add: aTrappableEvent;
            yourself
    ]

    Exception class >> allExceptionsDo: aBlock [
        "Private - Pass ourselves to aBlock"

        <category: 'interoperability with TrappableEvents'>
        aBlock value: self
    ]

    Exception class >> goodness: anExceptionClass [
        "Answer how good the receiver is at handling the given exception.  A
         negative value indicates that the receiver is not able to handle
         the exception."

        <category: 'comparison'>
        | depth found c target |
        depth := -100000.
        target := self.
        c := anExceptionClass.
        [c == target ifTrue: [ depth := 0 ].
        c == Exception] whileFalse: [c := c superclass. depth := depth + 1].

        "In general, the deeper is the exception, the more fine-grained the
         control is and the higher is the goodness (as long as the receiver
         can handle the exception)."
        ^depth
    ]

    Exception class >> handles: anException [
        "Answer whether the receiver handles `anException'."

        <category: 'comparison'>
        | target |
        target := anException class asClass.
        self == target ifTrue: [^true].
        ^target inheritsFrom: self
    ]

    = anObject [
        "Answer whether the receiver is equal to anObject.  This is true if
         either the receiver or its class are the same object as anObject."

        <category: 'comparison'>
        ^self == anObject
    ]

    initialize: anObject [
        "Initialize the receiver's instance variables."

        <category: 'private'>
        creator := anObject.
        tag := self noTag.
        self messageText: self description
    ]

    description [
        "Answer a textual description of the exception."

        <category: 'exception description'>
        ^'An exception has occurred'
    ]

    isResumable [
        "Answer true.  Exceptions are by default resumable."

        <category: 'exception description'>
        ^true
    ]

    defaultAction [
        "Execute the default action that is attached to the receiver."

        <category: 'exception description'>
        self resignalAsUnhandled: self messageText
    ]

    signal [
        "Raise the exceptional event represented by the receiver"

        <category: 'exception signaling'>
        self instantiateNextHandlerFrom: thisContext.
        ^self activateHandler: (onDoBlock isNil and: [ self isResumable ])
    ]

    signal: messageText [
        "Raise the exceptional event represented by the receiver, setting
         its message text to messageText."

        <category: 'exception signaling'>
        ^self
            messageText: messageText;
            signal
    ]

    creator [
        <category: 'private - copying'>
        ^creator
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

    isNested [
	"Answer whether the current exception handler is within the scope of
	 another handler for the same exception."

	<category: 'exception handling'>
	isNested isNil ifTrue: [isNested := false].
	^isNested
    ]

    instantiateNextHandlerFrom: aContext [
	"Private - Fill the receiver with information on the next handler for
         it, possibly a handler for a parent or the default handler."

	<category: 'private'>
	aContext parentContext scanBacktraceForAttribute: #exceptionHandlerSearch:reset:
	    do: 
		[:context :attr | 
		| status |
		status := (attr arguments at: 1) value: context value: self.
		status == #found ifTrue: [^self]].

        self instantiateDefaultHandler.
    ]

    instantiateDefaultHandler [
	"Private - Fill the receiver with information on its default handler."

	<category: 'private'>
	self 
	    onDoBlock: nil
	    handlerBlock: [ :ex | ex defaultAction ]
	    onDoContext: nil
	    previousState: nil
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
        signal instantiateNextHandlerFrom: self context.
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
        signal instantiateNextHandlerFrom: self context.
        ^self return: (signal activateHandler: true)
    ]

    resignalAsUnhandled: message [
	"This might start the debugger... Note that we use #basicPrint
	 'cause #printOn: might invoke an error."

	<category: 'built ins'>
	| exc |
	exc := SystemExceptions.UnhandledException new
	    originalException: self;
	    messageText: message; yourself.
	thisContext parentContext
	    scanBacktraceFor: #(#resignalAsUnhandled:)
	    do: [ :ctx | ^exc defaultAction ].

	self resignalAs: exc
    ]

    resume [
	"If the exception is resumable, resume the execution of the block that
	 raised the exception; the method that was used to signal the exception
	 will answer the receiver.
	 Use this method IF AND ONLY IF you know who caused the exception and if
	 it is possible to resume it in that particular case"

	<category: 'exception handling'>
	self isResumable 
	    ifFalse: [self resignalAsUnhandled: 'Exception not resumable - #resume failed'].
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
	    ifFalse: [self resignalAsUnhandled: 'Exception not resumable - #resume: failed'].
	self resetHandler.
	resumeBlock value: anObject
    ]

    resignalAs: replacementException [
	"Reinstate all handlers and execute the handler for `replacementException';
	 control does not return to the currently active exception handler. The
	 new Signal object that is created has the same contents as the receiver
	 (this might or not be correct -- if it isn't you can use an idiom such
	 as `sig retryUsing: [ replacementException signal ])"

	<category: 'exception handling'>
	self class resetAllHandlers.
        replacementException instantiateNextHandlerFrom: thisContext.
        ^replacementException return: (replacementException activateHandler: true)
    ]

    retry [
	"Re-execute the receiver of the #on:do: message. All handlers are
	 reinstated: watch out, this can easily cause an infinite loop."

	<category: 'exception handling'>
	onDoBlock isNil 
	    ifTrue: [self resignalAsUnhandled: 'No exception handler effective - #retry failed'].
	self class resetAllHandlers.
	self return: onDoBlock value
    ]

    retryUsing: aBlock [
	"Execute aBlock reinstating all handlers, and return its result from
	 the #signal method."

	<category: 'exception handling'>
	self class resetAllHandlers.
	self return: aBlock value
    ]

    signalingContext [
	"Return the execution context for the place that signaled the
	 exception, or nil if it is not available anymore (for example
	 if the exception handler has returned."
	| context |
        context := resumeBlock outerContext home.
        [context notNil and: [context isInternalExceptionHandlingContext]]
            whileTrue: [context := context parentContext].
        ^context
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
	    ifTrue: [self resignalAsUnhandled: 'No exception handler effective - #return failed'].
	self class resetAllHandlers.
	context parentContext continue: nil
    ]

    return: anObject [
	"Exit the #on:do: snippet, answering anObject to its caller."

	<category: 'exception handling'>
	context isNil 
	    ifTrue: [self resignalAsUnhandled: 'No exception handler effective - #return: failed'].
	self class resetAllHandlers.
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
	result := handlerBlock cull: self.
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
	onDoBlock isNil 
	    ifFalse: [context at: context numArgs + 1 put: previousState]
    ]

    noTag [
	<category: 'private'>
	NoTag isNil ifTrue: [NoTag := Object new].
	^NoTag
    ]
]
