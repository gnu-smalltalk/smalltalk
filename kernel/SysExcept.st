"======================================================================
|
|   ANSI exception handling classes
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2000, 2001, 2002, 2007, 2008, 2009 Free Software Foundation, Inc.
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



Exception subclass: Error [
    
    <category: 'Language-Exceptions'>
    <comment: 'Error represents a fatal error.  Instances of it are not resumable.'>

    description [
	"Answer a textual description of the exception."

	<category: 'exception description'>
	^'An exceptional condition has occurred, and has prevented normal
continuation of processing.'
    ]

    isResumable [
	"Answer false.  Error exceptions are by default unresumable; subclasses
	 can override this method if desired."

	<category: 'exception description'>
	^false
    ]
]



Exception subclass: Notification [
    
    <category: 'Language-Exceptions'>
    <comment: 'Notification represents a resumable, exceptional yet non-erroneous,
situation.  Signaling a notification in absence of an handler simply
returns nil.'>

    description [
	"Answer a textual description of the exception."

	<category: 'exception description'>
	^'An exceptional condition has occurred, but it is not to be considered
an error.'
    ]

    isResumable [
	"Answer true.  Notification exceptions are by default resumable."

	<category: 'exception description'>
	^true
    ]

    defaultAction [
	"Do the default action for notifications, which is to resume execution
	 of the context which signaled the exception."

	<category: 'exception description'>
	self resume: nil
    ]
]



Notification subclass: Warning [
    
    <category: 'Language-Exceptions'>
    <comment: 'Warning represents an `important'' but resumable error.'>

    description [
	"Answer a textual description of the exception."

	<category: 'exception description'>
	^'An exceptional condition has occurred.  It is reported to the user
even though it is not to be considered an error.'
    ]
]


Exception subclass: Halt [
    
    <category: 'Language-Exceptions'>
    <comment: 'Halt represents a resumable error, usually a bug.'>

    description [
	"Answer a textual description of the exception."

	<category: 'description'>
	^'#halt was sent.'
    ]

    isResumable [
	"Answer true.  #halt exceptions are by default resumable."

	<category: 'description'>
	^true
    ]
]



Error subclass: ArithmeticError [
    
    <category: 'Language-Exceptions'>
    <comment: 'An ArithmeticError exception is raised by numeric classes when a program
tries to do something wrong, such as extracting the square root of a
negative number.'>

    description [
	"Answer a textual description of the exception."

	<category: 'description'>
	^'The program attempted to do an impossible arithmetic operation'
    ]

    isResumable [
	"Answer true.  Arithmetic exceptions are by default resumable."

	<category: 'description'>
	^true
    ]
]



Error subclass: MessageNotUnderstood [
    | message receiver |
    
    <category: 'Language-Exceptions'>
    <comment: 'MessageNotUnderstood represents an error during message lookup. Signaling
it is the default action of the #doesNotUnderstand: handler'>

    message [
	"Answer the message that wasn't understood"

	<category: 'accessing'>
	^message
    ]

    receiver [
	"Answer the object to whom the message send was directed"

	<category: 'accessing'>
	^receiver
    ]

    message: aMessage receiver: anObject [
	<category: 'private'>
	message := aMessage.
	receiver := anObject.
	self messageText: 'did not understand ' , message selector printString
    ]

    description [
	"Answer a textual description of the exception."

	<category: 'description'>
	^'The program sent a message which was not understood by the receiver.'
    ]

    isResumable [
	"Answer true.  #doesNotUnderstand: exceptions are by default resumable."

	<category: 'description'>
	^true
    ]
]



ArithmeticError subclass: ZeroDivide [
    | dividend |
    
    <category: 'Language-Exceptions'>
    <comment: 'A ZeroDivide exception is raised by numeric classes when a program tries
to divide by zero.  Information on the dividend is available to the
handler.'>

    ZeroDivide class >> dividend: aNumber [
	"Create a new ZeroDivide object remembering that the dividend was
	 aNumber."

	<category: 'instance creation'>
	^super new dividend: aNumber
    ]

    ZeroDivide class >> new [
	"Create a new ZeroDivide object; the dividend is conventionally
	 set to zero."

	<category: 'instance creation'>
	^super new dividend: 0
    ]

    dividend [
	"Answer the number that was being divided by zero"

	<category: 'accessing'>
	^dividend
    ]

    dividend: aNumber [
	<category: 'private'>
	dividend := aNumber
    ]

    description [
	"Answer a textual description of the exception."

	<category: 'description'>
	^'The program attempted to divide a number by zero'
    ]
]



Namespace current: SystemExceptions [

Notification subclass: ProcessBeingTerminated [
    
    <category: 'Language-Exceptions'>
    <comment: 'I am raised when a process is terminated.'>

    | semaphore |

    ProcessBeingTerminated class >> initialize [
	(UndefinedObject>>#'__terminate')
	    makeReadOnly: false;
	    descriptor: ((MethodInfo new: 1)
		methodClass: UndefinedObject;
		selector: #'__terminate';
		at: 1 put: (Message
		    selector: #exceptionHandlerSearch:reset:
		    arguments: {
			[ :context :signal |
			    (self handles: signal)
				ifTrue: [
				    signal
					onDoBlock: nil
					handlerBlock: [ :sig | thisContext environment continue: nil ]
					onDoContext: nil
					previousState: nil.
				    #found ]
				ifFalse: [nil] ].
			[ :context | ] });
		yourself);
	    makeReadOnly: true
    ]

    description [
	"Answer a textual description of the exception."

	<category: 'accessing'>
	^'the current process is being terminated'
    ]

    semaphore [
	"If the process was waiting on a semaphore, answer it."

	<category: 'accessing'>
	^semaphore
    ]

    semaphore: aSemaphore [
	"If the process was waiting on a semaphore, answer it."

	<category: 'accessing'>
	semaphore := aSemaphore
    ]
]

]


Namespace current: SystemExceptions [

Notification subclass: EndOfStream [
    | stream |
    
    <category: 'Language-Exceptions'>
    <comment: 'I am raised when a stream reaches its end.'>

    EndOfStream class >> signalOn: stream [
	"Answer an exception reporting the parameter has reached its end."

	<category: 'signaling'>
	^(self new)
	    stream: stream;
	    signal
    ]

    description [
	"Answer a textual description of the exception."

	<category: 'accessing'>
	^'end of stream reached'
    ]

    stream [
	"Answer the stream whose end was reached."

	<category: 'accessing'>
	^stream
    ]

    stream: anObject [
	"Set the stream whose end was reached."

	<category: 'accessing'>
	stream := anObject
    ]
]

]



Namespace current: SystemExceptions [

Error subclass: NotEnoughElements [
    | remainingCount |
    
    <category: 'Language-Exceptions'>
    <comment: 'I am raised when one invokes #next: but not enough items remain in the
stream.'>

    NotEnoughElements class >> signalOn: remainingCount [
	"Answer an exception reporting the parameter as invalid."

	<category: 'signaling'>
	^(self new)
	    remainingCount: remainingCount;
	    signal
    ]

    description [
	"Answer a textual description of the exception."

	<category: 'accessing'>
	^'premature end of stream'
    ]

    messageText [
	"Answer an exception's message text."

	<category: 'accessing'>
	^'%1: %2 element(s) missing' % 
		{self basicMessageText.
		self remainingCount}
    ]

    remainingCount [
	"Answer the number of items that were to be read."

	<category: 'accessing'>
	^remainingCount
    ]

    remainingCount: anObject [
	"Set the number of items that were to be read."

	<category: 'accessing'>
	remainingCount := anObject
    ]
]

]



Namespace current: SystemExceptions [

Error subclass: InvalidValue [
    | value |
    
    <category: 'Language-Exceptions'>
    <comment: 'I am raised when one invokes a method with an invalid receiver or argument.'>

    InvalidValue class >> signalOn: value [
	"Answer an exception reporting the parameter as invalid."

	<category: 'signaling'>
	^(self new)
	    value: value;
	    signal
    ]

    InvalidValue class >> signalOn: value reason: reason [
	"Answer an exception reporting `value' as invalid, for the given
	 reason."

	<category: 'signaling'>
	^(self new)
	    value: value;
	    signal: reason
    ]

    description [
	"Answer a textual description of the exception."

	<category: 'accessing'>
	^'unknown error'
    ]

    messageText [
	"Answer an exception's message text."

	<category: 'accessing'>
	^'Invalid value %1: %2' % 
		{self value.
		self basicMessageText}
    ]

    value [
	"Answer the object that was found to be invalid."

	<category: 'accessing'>
	^value
    ]

    value: anObject [
	"Set the object that was found to be invalid."

	<category: 'accessing'>
	value := anObject
    ]
]

]



Namespace current: SystemExceptions [

InvalidValue subclass: InvalidState [
    
    <category: 'Language-Exceptions'>
    <comment: 'I am raised when one invokes a method and the receiver or an argument
are in an invalid state for the method.'>

    messageText [
	"Answer an exception's message text."

	<category: 'accessing'>
	^'%1 is in an invalid state: %2' % 
		{self value.
		self basicMessageText}
    ]
]

]



Namespace current: SystemExceptions [

InvalidValue subclass: NotIndexable [
    
    <category: 'Language-Exceptions'>
    <comment: 'I am raised when an object is not indexable.'>

    description [
	"Answer a textual description of the exception."

	<category: 'accessing'>
	^'object not indexable'
    ]
]

]



Namespace current: SystemExceptions [

InvalidValue subclass: ReadOnlyObject [
    
    <category: 'Language-Exceptions'>
    <comment: 'I am raised when one writes to a read-only object.'>

    description [
	"Answer a textual description of the exception."

	<category: 'accessing'>
	^'object is read-only'
    ]
]

]



Namespace current: SystemExceptions [

InvalidValue subclass: EmptyCollection [
    
    <category: 'Language-Exceptions'>
    <comment: 'I am raised when one invokes a method on an empty collection.'>

    description [
	"Answer a textual description of the exception."

	<category: 'accessing'>
	^'the collection is empty'
    ]
]

]



Namespace current: SystemExceptions [

InvalidValue subclass: InvalidArgument [
    
    <category: 'Language-Exceptions'>
    <comment: 'I am raised when one invokes a method with an invalid argument.'>

    messageText [
	"Answer an exception's message text."

	<category: 'accessing'>
	^'Invalid argument %1: %2' % 
		{self value.
		self basicMessageText}
    ]
]

]



Namespace current: SystemExceptions [

InvalidArgument subclass: AlreadyDefined [
    
    <category: 'Language-Exceptions'>
    <comment: 'I am raised when one tries to define a symbol (class or pool variable) that
is already defined.'>

    description [
	"Answer a description for the error"

	<category: 'accessing'>
	^'symbol already defined'
    ]
]

]



Namespace current: SystemExceptions [

InvalidArgument subclass: ArgumentOutOfRange [
    | low high |
    
    <category: 'Language-Exceptions'>
    <comment: 'I am raised when one invokes a method with an argument outside of its
valid range.'>

    ArgumentOutOfRange class >> signalOn: value mustBeBetween: low and: high [
	"Raise the exception.  The given value was not between low and high."

	<category: 'signaling'>
	| errorString |
	errorString := RegressionTesting 
		    ifTrue: ['argument out of range']
		    ifFalse: 
			['argument must be between ' , low printString , ' and ' , high printString].
	^(self new)
	    value: value;
	    low: low;
	    high: high;
	    signal: errorString
    ]

    description [
	"Answer a textual description of the exception."

	<category: 'accessing'>
	^'argument out of range'
    ]

    low [
	"Answer the lowest value that was permitted."

	<category: 'accessing'>
	^low
    ]

    low: aMagnitude [
	"Set the lowest value that was permitted."

	<category: 'accessing'>
	low := aMagnitude
    ]

    high [
	"Answer the highest value that was permitted."

	<category: 'accessing'>
	^high
    ]

    high: aMagnitude [
	"Set the highest value that was permitted."

	<category: 'accessing'>
	high := aMagnitude
    ]
]

]



Namespace current: SystemExceptions [

ArgumentOutOfRange subclass: IndexOutOfRange [
    | collection |
    
    <category: 'Language-Exceptions'>
    <comment: 'I am raised when one invokes am accessor method with an index outside of its
valid range.'>

    IndexOutOfRange class >> signalOn: aCollection withIndex: value [
	"The given index was out of range in aCollection."

	<category: 'signaling'>
	^(self new)
	    collection: aCollection;
	    value: value;
	    signal
    ]

    description [
	"Answer a textual description of the exception."

	<category: 'accessing'>
	^'index out of range'
    ]

    messageText [
	"Answer an exception's message text."

	<category: 'accessing'>
	^'Invalid index %1: %2' % 
		{self value.
		self basicMessageText}
    ]

    collection [
	"Answer the collection that triggered the error"

	<category: 'accessing'>
	^collection
    ]

    collection: anObject [
	"Set the collection that triggered the error"

	<category: 'accessing'>
	collection := anObject
    ]
]

]



Namespace current: SystemExceptions [

InvalidArgument subclass: InvalidSize [
    
    <category: 'Language-Exceptions'>
    <comment: 'I am raised when an argument has an invalid size.'>

    description [
	"Answer a textual description of the exception."

	<category: 'accessing'>
	^'invalid size'
    ]
]

]



Namespace current: SystemExceptions [

InvalidArgument subclass: NotFound [
    
    <category: 'Language-Exceptions'>
    <comment: 'I am raised when something is searched without success.'>

    NotFound class >> signalOn: value what: aString [
	"Raise an exception; aString specifies what was not found (a key,
	 an object, a class, and so on)."

	<category: 'accessing'>
	^(self new)
	    value: value;
	    signal: aString , ' not found'
    ]

    NotFound class >> signalOn: value reason: aString [
	"Raise an exception: reason specifies the reason of the exception."

	<category: 'accessing'>
	^(self new)
	    value: value;
	    signal: aString
    ]
 
    description [
	"Answer a textual description of the exception."

	<category: 'accessing'>
	^'not found'
    ]
]

]



Namespace current: SystemExceptions [

InvalidValue subclass: WrongClass [
    | validClasses |
    
    <category: 'Language-Exceptions'>
    <comment: 'I am raised when an argument is constrained to be an instance of a determinate
class, and this constraint is not respected by the caller.'>

    WrongClass class >> signalOn: anObject mustBe: aClassOrArray [
	"Raise an exception.  The given object should have been an instance
	 of one of the classes indicated by aClassOrArray (which should be
	 a single class or an array of classes).  Whether instances of
	 subclasses are allowed should be clear from the context, though
	 in general (i.e. with the exception of a few system messages)
	 they should be."

	<category: 'signaling'>
	(aClassOrArray isKindOf: Collection) 
	    ifFalse: [^self signalOn: anObject mustBe: {aClassOrArray binding}].
	^(self new)
	    validClasses: aClassOrArray;
	    value: anObject;
	    signal
    ]

    description [
	"Answer a textual description of the exception."

	<category: 'accessing'>
	^'wrong argument type'
    ]

    messageText [
	"Answer an exception's message text."

	<category: 'accessing'>
	self validClasses isNil 
	    ifTrue: [^'Invalid argument ' , self value printString].
	^'Invalid argument %1: must be %2' % 
		{self value.
		self validClassesString}
    ]

    validClasses [
	"Answer the list of classes whose instances would have been valid."

	<category: 'accessing'>
	^validClasses
    ]

    validClassesString [
	"Answer the list of classes whose instances would have been valid,
	 formatted as a string."

	<category: 'accessing'>
	^String streamContents: 
		[:str | 
		validClasses keysAndValuesDo: 
			[:idx :classOrBinding | 
			| name class |
			idx > 1 
			    ifTrue: 
				[idx = validClasses size 
				    ifFalse: [str nextPutAll: ', ']
				    ifTrue: [str nextPutAll: ' or ']].
			class := classOrBinding isClass 
				    ifTrue: [classOrBinding]
				    ifFalse: [classOrBinding value].
			name := class nameIn: Namespace current.
			name first isVowel 
			    ifTrue: [str nextPutAll: 'an ']
			    ifFalse: [str nextPutAll: 'a '].
			str nextPutAll: name]]
    ]

    validClasses: aCollection [
	"Set the list of classes whose instances would have been valid."

	<category: 'accessing'>
	validClasses := aCollection
    ]
]

]



Namespace current: SystemExceptions [

WrongClass subclass: MustBeBoolean [
    
    <category: 'Language-Exceptions'>
    <comment: 'I am raised when one invokes a boolean method on a non-boolean.'>

    MustBeBoolean class >> signalOn: anObject [
	"Signal a new exception, with the bad value in question being
	 anObject."
	<category: 'signaling'>
	^self signalOn: anObject mustBe: #(#{Boolean})
    ]
]

]



Namespace current: SystemExceptions [

InvalidValue subclass: ProcessTerminated [
    
    <category: 'Language-Exceptions'>
    <comment: 'I am raised when somebody tries to resume or interrupt a terminated process.'>

    description [
	"Answer a textual description of the exception."

	<category: 'accessing'>
	^'process has/was already terminated'
    ]
]

]



Namespace current: SystemExceptions [

InvalidValue subclass: InvalidProcessState [
    
    <category: 'Language-Exceptions'>
    <comment: 'I am an error raised when trying to resume a terminated process, or
stuff like that.'>

    description [
	"Answer a textual description of the exception."

	<category: 'accessing'>
	^'invalid operation for this process'
    ]
]

]



Namespace current: SystemExceptions [

Error subclass: MutationError [
    
    <category: 'Language-Exceptions'>
    <comment: 'I am an error raised when a class is mutated in an invalid way.'>

    MutationError class >> new [
	"Create an instance of the receiver, which you will be able to
	 signal later."

	<category: 'instance creation'>
	^self basicNew initialize: nil
    ]

    description [
	"Answer a textual description of the exception."

	<category: 'accessing'>
	^'cannot mutate the class this way'
    ]
]

]



Namespace current: SystemExceptions [

Error subclass: VMError [
    
    <category: 'Language-Exceptions'>
    <comment: 'I am an error related to the innards of the system.'>

    description [
	"Answer a textual description of the exception."

	<category: 'accessing'>
	^'virtual machine error'
    ]
]

]



Namespace current: SystemExceptions [

VMError subclass: SecurityError [
    | failedPermission |
    
    <category: 'Language-Exceptions'>
    <comment: 'I am an error raised when an untrusted object tries to do an insecure
operation.'>

    SecurityError class >> signal: aPermission [
	"Raise the exception, setting to aPermission the permission
	 that was tested and failed."

	<category: 'accessing'>
	^(self new)
	    failedPermission: aPermission;
	    signal
    ]

    description [
	"Answer a textual description of the exception."

	<category: 'accessing'>
	^'insecure operation in an untrusted context'
    ]

    failedPermission [
	"Answer the permission that was tested and that failed."

	<category: 'accessing'>
	^failedPermission
    ]

    failedPermission: anObject [
	"Set which permission was tested and failed."

	<category: 'accessing'>
	failedPermission := anObject
    ]
]

]



Namespace current: SystemExceptions [

VMError subclass: VerificationError [
    
    <category: 'Language-Exceptions'>
    <comment: 'I am raised when the verification of a method fails.'>

    description [
	"Answer a textual description of the exception."

	<category: 'accessing'>
	^'a method did not pass the bytecode verification process'
    ]
]

]



Namespace current: SystemExceptions [

VMError subclass: BadReturn [
    
    <category: 'Language-Exceptions'>
    <comment: 'I am raised when one tries to return from an already-terminated method.'>

    description [
	"Answer a textual description of the exception."

	<category: 'accessing'>
	^'return from a dead method context'
    ]
]

]



Namespace current: SystemExceptions [

VMError subclass: UserInterrupt [
    
    <category: 'Language-Exceptions'>
    <comment: 'I am raised when one presses Ctrl-C.'>

    description [
	"Answer a textual description of the exception."

	<category: 'accessing'>
	^'interrupted!!!'
    ]
]

]



Namespace current: SystemExceptions [

VMError subclass: NoRunnableProcess [
    
    <category: 'Language-Exceptions'>
    <comment: 'I am raised when no runnable process can be found in the image.'>

    description [
	"Answer a textual description of the exception."

	<category: 'accessing'>
	^'no runnable process'
    ]
]

]



Namespace current: SystemExceptions [

VMError subclass: PrimitiveFailed [
    
    <category: 'Language-Exceptions'>
    <comment: 'I am raised when a primitive fails for some reason.'>

    description [
	"Answer a textual description of the exception."

	<category: 'accessing'>
	^'primitive operation failed'
    ]
]

]



Namespace current: SystemExceptions [

PrimitiveFailed subclass: WrongArgumentCount [
    
    <category: 'Language-Exceptions'>
    <comment: 'I am raised when one tries to evaluate a method (via #perform:...) or a
block but passes the wrong number of arguments.'>

    description [
	"Answer a textual description of the exception."

	<category: 'accessing'>
	^'wrong number of arguments'
    ]
]

]



Namespace current: SystemExceptions [

PrimitiveFailed subclass: CInterfaceError [
    
    <category: 'Language-Exceptions'>
    <comment: 'I am raised when an error happens that is related to the C interface.'>

    description [
	"Answer a textual description of the exception."

	<category: 'accessing'>
	^'error in the C-language interface'
    ]
]

]



Namespace current: SystemExceptions [

PrimitiveFailed subclass: FileError [
    
    <category: 'Language-Exceptions'>
    <comment: 'I am raised when an error happens that is related to the file system.'>

    description [
	"Answer a textual description of the exception."

	<category: 'accessing'>
	^'file system error'
    ]
]

]



Namespace current: SystemExceptions [

Error subclass: NotImplemented [
    
    <category: 'Language-Exceptions'>
    <comment: 'I am raised when a method is called that has not been implemented.'>

    description [
	"Answer a textual description of the exception."

	<category: 'accessing'>
	^'method is not implemented'
    ]
]

]



Namespace current: SystemExceptions [

NotImplemented subclass: NotYetImplemented [
    
    <category: 'Language-Exceptions'>
    <comment: 'I am raised when a method is called that has not been implemented yet.'>

    description [
	"Answer a textual description of the exception."

	<category: 'accessing'>
	^'not yet implemented'
    ]
]

]



Namespace current: SystemExceptions [

NotImplemented subclass: ShouldNotImplement [
    
    <category: 'Language-Exceptions'>
    <comment: 'I am raised when a method is called that a class wishes that is not
called.'>

    description [
	"Answer a textual description of the exception."

	<category: 'accessing'>
	^'should not be implemented in this class'
    ]
]

]



Namespace current: SystemExceptions [

ShouldNotImplement subclass: WrongMessageSent [
    | selector suggestedSelector |
    
    <category: 'Language-Exceptions'>
    <comment: 'I am raised when a method is called that a class wishes that is not
called.  This exception also includes a suggestion on which message
should be sent instead'>

    WrongMessageSent class >> signalOn: selector useInstead: aSymbol [
	"Raise an exception, signaling which selector was sent and suggesting
	 a valid alternative."

	<category: 'signaling'>
	^(self new)
	    selector: selector;
	    suggestedSelector: aSymbol;
	    signal
    ]

    messageText [
	"Answer an exception's message text."

	<category: 'accessing'>
	^'%1, use %2 instead' % 
		{self basicMessageText.
		self suggestedSelector storeString}
    ]

    selector [
	"Answer which selector was sent."

	<category: 'accessing'>
	^selector
    ]

    selector: aSymbol [
	"Set which selector was sent."

	<category: 'accessing'>
	selector := aSymbol
    ]

    suggestedSelector [
	"Answer a valid alternative to the selector that was used."

	<category: 'accessing'>
	^suggestedSelector
    ]

    suggestedSelector: aSymbol [
	"Set a valid alternative to the selector that was used."

	<category: 'accessing'>
	suggestedSelector := aSymbol
    ]
]

]



Namespace current: SystemExceptions [

ShouldNotImplement subclass: SubclassResponsibility [
    
    <category: 'Language-Exceptions'>
    <comment: 'I am raised when a method is called whose implementation is the responsibility
of concrete subclass.'>

    description [
	"Answer a textual description of the exception."

	<category: 'accessing'>
	^'method is responsibility of a subclass'
    ]
]

]



Namespace current: SystemExceptions [

Exception subclass: UnhandledException [

    | originalException |

    <category: 'Language-Exception'>
    <comment: 'I am raised when a backtrace is shown to terminate the
current process.'>

    description [
	"Answer a textual description of the exception."

	<category: 'accessing'>
	^'an unhandled exception occurred in the current process'
    ]

    defaultAction [
	"Terminate the current process."

	<category: 'accessing'>
	| debugger debuggerClass context |
	Transcript flush.
	debugger := Processor activeDebugger.
	debugger isNil ifFalse: [^debugger stopInferior: self messageText ].
	debuggerClass := thisContext debuggerClass.
	debuggerClass isNil 
	    ifFalse: [^debuggerClass open: self originalException creator printString , ' error: ' , self messageText ].

	"Default behavior - print backtrace"
	RegressionTesting ifFalse: [self originalException creator basicPrint].
	Transcript
	    nextPutAll: ' error: ';
	    display: self messageText;
	    nl.
	RegressionTesting 
	    ifFalse: 
		[context := thisContext.
		[context isInternalExceptionHandlingContext] 
		    whileTrue: [context := context parentContext].
		context backtraceOn: Transcript].

	thisContext environment continue: nil
    ]

    instantiateDefaultHandler [
	"Private - Fill the receiver with information on its default handler."

	<category: 'private'>
        | signalingContext resumeContext |

	"This exception is kind of special, as we forcedly have to find
         a place to resume---even if the exception was not resumable!
         This typically will happens when the user steps out of the
         exception handling gobbledegook in the debugger."
        signalingContext := thisContext.
        [resumeContext := signalingContext parentContext.
        resumeContext isEnvironment not
            and: [resumeContext isInternalExceptionHandlingContext]]
                whileTrue: [signalingContext := resumeContext].

	self 
	    onDoBlock: nil
	    handlerBlock: [ :ex | ex defaultAction ]
	    onDoContext: signalingContext
	    previousState: nil
    ]

    originalException [
	"Answer the uncaught exception."

	<category: 'accessing'>
	^originalException
    ]

    originalException: anObject [
	"Set the uncaught exception to anObject."

	<category: 'accessing'>
	originalException := anObject
    ]
]

]



Namespace current: Kernel [

Notification subclass: TimeoutNotification [
    | delay |
    <category: 'Language-Implementation'>
    <comment: 'I get send by the timeout handling of a Delay
and I am the indication that the time is up and that one should come
to an end.'>

    TimeoutNotification class >> on: aDelay [
        <category: 'creation'>
        ^ self new
            delay: aDelay; yourself
    ]

    delay: aDelay [
        <category: 'private'>
        delay := aDelay
    ]

    delay [
        <category: 'private'>
        ^ delay
    ]

    isResumable [
        <category: 'private'>
        ^ false
    ]

    defaultAction [
	"We are not resumable, so do nothing.  This should really never happen."

	<category: 'exception description'>
    ]
]

]

Number extend [

    arithmeticError: msg [
	"Raise an ArithmeticError exception having msg as its message text."

	<category: 'error raising'>
	^ArithmeticError new signal: msg
    ]

    zeroDivide [
	"Raise a division-by-zero (ZeroDivide) exception whose dividend
	 is the receiver."

	<category: 'error raising'>
	^(ZeroDivide dividend: self) signal
    ]

]



Object extend [

    doesNotUnderstand: aMessage [
	"Called by the system when a selector was not found. message is a
	 Message containing information on the receiver"

	"aMessage inspect."

	"thisContext parentContext method inspect."

	"ObjectMemory abort."

	<category: 'error raising'>
	^(MessageNotUnderstood new)
	    message: aMessage receiver: self;
	    signal
    ]

    error: message [
	"Display a walkback for the receiver, with the given error message.
	 Signal an `Error' exception."

	<category: 'error raising'>
	^Error new signal: message
    ]

    halt: message [
	"Display a walkback for the receiver, with the given error message.
	 Signal an `Halt' exception."

	<category: 'error raising'>
	^Halt new signal: message
    ]

]



Eval [
    SystemExceptions.ProcessBeingTerminated initialize
]

