"======================================================================
|
|   ANSI exception handling classes
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2000, 2001, 2002 Free Software Foundation, Inc.
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

Signal subclass: #Exception
    instanceVariableNames: 'creator'
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Language-Exceptions'!

Exception class instanceVariableNames: 'coreException'.

Exception subclass: #Error
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Language-Exceptions'.

Exception subclass: #Notification
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Language-Exceptions'!

Notification subclass: #Warning
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Language-Exceptions'.

Error subclass: #Halt
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Language-Exceptions'!

Halt subclass: #ArithmeticError
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Language-Exceptions'.

Halt subclass: #MessageNotUnderstood
    instanceVariableNames: 'message receiver'
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Language-Exceptions'!

ArithmeticError subclass: #ZeroDivide
    instanceVariableNames: 'dividend'
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Language-Exceptions'!

Exception comment:
'An Exception defines the characteristics of an exceptional event
in a different way than CoreExceptions.  Instead of creating an
hierarchy of objects and setting attributes of the objects, you
create an hierarchy of classes and override methods in those classes;
instances of those classes are passed to the handlers instead of
instances of the common class Signal.

Internally, Exception and every subclass of it hold onto a
CoreException, so the two mechanisms are actually interchangeable.'.

Error comment:
'Error represents a fatal error.  Instances of it are not resumable.'.

Halt comment:
'Halt represents a resumable error, usually a bug.'.

Notification comment:
'Notification represents a resumable, exceptional yet non-erroneous,
situation.  Signaling a notification in absence of an handler simply
returns nil.'.

MessageNotUnderstood comment:
'MessageNotUnderstood represents an error during message lookup. Signaling
it is the default action of the #doesNotUnderstand: handler'.

ArithmeticError comment:
'An ArithmeticError exception is raised by numeric classes when a program
tries to do something wrong, such as extracting the square root of a
negative number.'.

ZeroDivide comment:
'A ZeroDivide exception is raised by numeric classes when a program tries
to divide by zero.  Information on the dividend is available to the
handler.'.

Warning comment:
'Warning represents an `important'' but resumable error.'!


Smalltalk addSubspace: #SystemExceptions!

Namespace current: SystemExceptions!

Notification subclass: #ProcessBeingTerminated
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Language-Exceptions'.

Notification subclass: #EndOfStream
      instanceVariableNames: 'stream'
      classVariableNames: ''
      poolDictionaries: ''
      category: 'Language-Exceptions'!

EndOfStream comment: 
'I am raised when a stream reaches its end.'!

Error subclass: #NotEnoughElements
      instanceVariableNames: 'remainingCount'
      classVariableNames: ''
      poolDictionaries: ''
      category: 'Language-Exceptions'!

NotEnoughElements comment: 
'I am raised when one invokes #next: but not enough items remain in the
stream.'!

Error subclass: #InvalidValue
      instanceVariableNames: 'value'
      classVariableNames: ''
      poolDictionaries: ''
      category: 'Language-Exceptions'!

InvalidValue comment: 
'I am raised when one invokes a method with an invalid receiver or argument.'!

InvalidValue subclass: #NotIndexable
      instanceVariableNames: ''
      classVariableNames: ''
      poolDictionaries: ''
      category: 'Language-Exceptions'!

NotIndexable comment: 
'I am raised when an object is not indexable.'!

InvalidValue subclass: #ReadOnlyObject
      instanceVariableNames: ''
      classVariableNames: ''
      poolDictionaries: ''
      category: 'Language-Exceptions'!

ReadOnlyObject comment: 
'I am raised when one writes to a read-only object.'!

InvalidValue subclass: #EmptyCollection
      instanceVariableNames: ''
      classVariableNames: ''
      poolDictionaries: ''
      category: 'Language-Exceptions'!

EmptyCollection comment: 
'I am raised when one invokes a method on an empty collection.'!

InvalidValue subclass: #InvalidArgument
      instanceVariableNames: ''
      classVariableNames: ''
      poolDictionaries: ''
      category: 'Language-Exceptions'!

InvalidArgument comment: 
'I am raised when one invokes a method with an invalid argument.'!

InvalidArgument subclass: #AlreadyDefined
      instanceVariableNames: ''
      classVariableNames: ''
      poolDictionaries: ''
      category: 'Language-Exceptions'!

AlreadyDefined comment: 
'I am raised when one tries to define a symbol (class or pool variable) that
is already defined.'!


InvalidArgument subclass: #ArgumentOutOfRange
      instanceVariableNames: 'low high'
      classVariableNames: ''
      poolDictionaries: ''
      category: 'Language-Exceptions'!

ArgumentOutOfRange comment: 
'I am raised when one invokes a method with an argument outside of its
valid range.'!

ArgumentOutOfRange subclass: #IndexOutOfRange
      instanceVariableNames: 'collection'
      classVariableNames: ''
      poolDictionaries: ''
      category: 'Language-Exceptions'!

IndexOutOfRange comment: 
'I am raised when one invokes am accessor method with an index outside of its
valid range.'!


InvalidArgument subclass: #InvalidSize
      instanceVariableNames: ''
      classVariableNames: ''
      poolDictionaries: ''
      category: 'Language-Exceptions'!

InvalidSize comment: 
'I am raised when an argument has an invalid size.'!


InvalidArgument subclass: #NotFound
      instanceVariableNames: ''
      classVariableNames: ''
      poolDictionaries: ''
      category: 'Language-Exceptions'!

NotFound comment: 
'I am raised when something is searched without success.'!


InvalidValue subclass: #WrongClass
      instanceVariableNames: 'validClasses'
      classVariableNames: ''
      poolDictionaries: ''
      category: 'Language-Exceptions'!

WrongClass comment: 
'I am raised when an argument is constrained to be an instance of a determinate
class, and this constraint is not respected by the caller.'!

WrongClass subclass: #MustBeBoolean
      instanceVariableNames: ''
      classVariableNames: ''
      poolDictionaries: ''
      category: 'Language-Exceptions'!

MustBeBoolean comment: 
'I am raised when one invokes a boolean method on a non-boolean.'!

InvalidValue subclass: #ProcessTerminated
      instanceVariableNames: ''
      classVariableNames: ''
      poolDictionaries: ''
      category: 'Language-Exceptions'!

ProcessTerminated comment: 
'I am raised when somebody tries to resume or interrupt a terminated process.'!


InvalidValue subclass: #InvalidProcessState
      instanceVariableNames: ''
      classVariableNames: ''
      poolDictionaries: ''
      category: 'Language-Exceptions'!

InvalidProcessState comment: 
'I am an error raised when trying to resume a terminated process, or
stuff like that.'!


Error subclass: #MutationError
      instanceVariableNames: ''
      classVariableNames: ''
      poolDictionaries: ''
      category: 'Language-Exceptions'!

MutationError comment: 
'I am an error raised when a class is mutated in an invalid way.'!


Error subclass: #VMError
      instanceVariableNames: ''
      classVariableNames: ''
      poolDictionaries: ''
      category: 'Language-Exceptions'!

VMError comment: 
'I am an error related to the innards of the system.'!


VMError subclass: #SecurityError
      instanceVariableNames: 'failedPermission '
      classVariableNames: ''
      poolDictionaries: ''
      category: 'Language-Exceptions'!

SecurityError comment: 
'I am an error raised when an untrusted object tries to do an insecure
operation.'!


VMError subclass: #VerificationError
      instanceVariableNames: ''
      classVariableNames: ''
      poolDictionaries: ''
      category: 'Language-Exceptions'!

VerificationError comment: 
'I am raised when the verification of a method fails.'!


VMError subclass: #BadReturn
      instanceVariableNames: ''
      classVariableNames: ''
      poolDictionaries: ''
      category: 'Language-Exceptions'!

BadReturn comment: 
'I am raised when one tries to return from an already-terminated method.'!


VMError subclass: #UserInterrupt
      instanceVariableNames: ''
      classVariableNames: ''
      poolDictionaries: ''
      category: 'Language-Exceptions'!

UserInterrupt comment: 
'I am raised when one presses Ctrl-C.'!


VMError subclass: #NoRunnableProcess
      instanceVariableNames: ''
      classVariableNames: ''
      poolDictionaries: ''
      category: 'Language-Exceptions'!

NoRunnableProcess comment: 
'I am raised when no runnable process can be found in the image.'!


VMError subclass: #PrimitiveFailed
      instanceVariableNames: ''
      classVariableNames: ''
      poolDictionaries: ''
      category: 'Language-Exceptions'!

PrimitiveFailed comment: 
'I am raised when a primitive fails for some reason.'!


PrimitiveFailed subclass: #WrongArgumentCount
      instanceVariableNames: ''
      classVariableNames: ''
      poolDictionaries: ''
      category: 'Language-Exceptions'!

WrongArgumentCount comment: 
'I am raised when one tries to evaluate a method (via #perform:...) or a
block but passes the wrong number of arguments.'!


PrimitiveFailed subclass: #CInterfaceError
      instanceVariableNames: ''
      classVariableNames: ''
      poolDictionaries: ''
      category: 'Language-Exceptions'!

CInterfaceError comment: 
'I am raised when an error happens that is related to the C interface.'!


PrimitiveFailed subclass: #FileError
      instanceVariableNames: ''
      classVariableNames: ''
      poolDictionaries: ''
      category: 'Language-Exceptions'!

FileError comment: 
'I am raised when an error happens that is related to the file system.'!


Error subclass: #NotImplemented
      instanceVariableNames: ''
      classVariableNames: ''
      poolDictionaries: ''
      category: 'Language-Exceptions'!

NotImplemented comment: 
'I am raised when a method is called that has not been implemented.'!


NotImplemented subclass: #NotYetImplemented
      instanceVariableNames: ''
      classVariableNames: ''
      poolDictionaries: ''
      category: 'Language-Exceptions'!

NotYetImplemented comment: 
'I am raised when a method is called that has not been implemented yet.'!


NotImplemented subclass: #ShouldNotImplement
      instanceVariableNames: ''
      classVariableNames: ''
      poolDictionaries: ''
      category: 'Language-Exceptions'!

ShouldNotImplement comment: 
'I am raised when a method is called that a class wishes that is not
called.'!


ShouldNotImplement subclass: #WrongMessageSent
      instanceVariableNames: 'selector suggestedSelector'
      classVariableNames: ''
      poolDictionaries: ''
      category: 'Language-Exceptions'!

WrongMessageSent comment: 
'I am raised when a method is called that a class wishes that is not
called.  This exception also includes a suggestion on which message
should be sent instead'!

ShouldNotImplement subclass: #SubclassResponsibility
      instanceVariableNames: ''
      classVariableNames: ''
      poolDictionaries: ''
      category: 'Language-Exceptions'!

SubclassResponsibility comment: 
'I am raised when a method is called whose implementation is the responsibility
of concrete subclass.'!


Namespace current: Smalltalk!

!Exception class methodsFor: 'instance creation'!

new
    "Create an instance of the receiver, which you will be able to
     signal later."

    | ctx creator |
    ctx := thisContext parentContext.
    [ (creator := ctx receiver) == self ] whileTrue: [
	ctx := ctx parentContext ].

    ^self basicNew
	initialize: creator
!

signal
    "Create an instance of the receiver, give it default attributes,
     and signal it immediately."

    ^self new signal
!

signal: messageText
    "Create an instance of the receiver, set its message text,
     and signal it immediately."

    ^self new
	messageText: messageText;
	signal
! !


!Exception class methodsFor: 'creating ExceptionCollections'!

, aTrappableEvent
    "Answer an ExceptionCollection containing all the exceptions in the
     receiver and all the exceptions in aTrappableEvent"

    ^ExceptionSet new
	add: self coreException;
	add: aTrappableEvent;
	yourself
! !


!Exception class methodsFor: 'initialization'!

initialize
    "Initialize the `links' between the core exception handling system
     and the ANSI exception handling system."

    "Usually, a coreException has no defined `resumable' state, because
     Exception overrides Signal>>#isResumable and gives an answer without
     asking the core exception.  For backwards compatibility, however, we
     must give a state to these (in case someone uses `on: ExAll do: ...')."

    (ExAll := CoreException basicNew)
	defaultHandler: [ :sig | self primError: sig messageText ];
	depth: 0;
	signalClass: Signal;
	isResumable: true;
	yourself.

    (coreException := ExAll newChild)
	defaultHandler: [ :sig | sig defaultAction ];
	signalClass: self;
	isResumable: true;
	yourself.

    (ExError := Error coreException)
	isResumable: false.

    (ExDoesNotUnderstand := MessageNotUnderstood coreException)
	isResumable: true.

    (ExHalt := Halt coreException)
	isResumable: true.

    (ExUserBreak := SystemExceptions.UserInterrupt coreException)
	isResumable: false.
! !


!Exception class methodsFor: 'interoperability with TrappableEvents'!

allExceptionsDo: aBlock
    "Private - Pass the coreException to aBlock"
    
    aBlock value: self coreException
!

coreException
    "Private - Answer the coreException which represents instances of
     the receiver"

    coreException isNil ifFalse: [ ^coreException ].

    ^coreException := self superclass coreException newChild
	defaultHandler: [ :sig | sig defaultAction ];
	signalClass: self;
	yourself
!

whenSignalledIn: onDoBlock do: handlerBlock exitBlock: exitBlock
    "Private - Create an ExceptionHandler from the arguments and register it"

    self coreException
	whenSignalledIn: onDoBlock
	do: handlerBlock
	exitBlock: exitBlock
! !


!Exception class methodsFor: 'comparison'!

goodness: anException
    "Answer how good the receiver is at handling the given exception.  A
     negative value indicates that the receiver is not able to handle
     the exception."

    ^self coreException goodness: anException
!

handles: anException
    "Answer whether the receiver handles `anException'."

    ^(anException isKindOf: Exception)
	ifTrue: [ anException isKindOf: self ]
	ifFalse: [ self coreException handles: anException ]
! !


!Exception methodsFor: 'comparison'!

= anObject
    "Answer whether the receiver is equal to anObject.  This is true if
     either the receiver or its coreException are the same object as anObject."

    "This definition is needed to make #handles: work for ExceptionCollections.
     `(Error, Warning) handles: Error new' must work even if the
     ExceptionCollections contains the coreExceptions associated to Error
     and Warning (see Exception class>>#,)."
    ^self == anObject or: [ self exception == anObject ]
!

hash
    "Answer an hash value for the receiver."
    ^self exception hash
! !


!Exception methodsFor: 'private'!

asAnsiException
    ^self
!
	        
initialize: anObject
    "Initialize the receiver's instance variables."
    
    creator := anObject.
    self
	initArguments: #();
	initException: self class coreException;
	messageText: self description
! !


!Exception methodsFor: 'exception description'!

description
    "Answer a textual description of the exception."
    ^'An exception has occurred'
!

isResumable
    "Answer true.  Exceptions are by default resumable."
    ^true
!

defaultAction
    "Execute the default action that is attached to the receiver."
    self creator primError: self messageText
! !


!Exception methodsFor: 'exception signaling'!

signal
    "Raise the exceptional event represented by the receiver"
    self exception instantiateNextHandler: self.
    ^self activateHandler: self isResumable
!

signal: messageText
    "Raise the exceptional event represented by the receiver, setting
     its message text to messageText."
    ^self messageText: messageText; signal
! !


!Exception methodsFor: 'private - copying'!

copyFrom: aSignal
    "Private - Initialize from another instance of Signal"

    (aSignal isKindOf: Exception) ifTrue: [ self initialize: aSignal creator ].
    super copyFrom: aSignal.
!

creator
    ^creator
! !


!Notification methodsFor: 'exception description'!

description
    "Answer a textual description of the exception."
    ^'An exceptional condition has occurred, but it is not to be considered
an error.'!

isResumable
    "Answer true.  Notification exceptions are by default resumable."
    ^true
!

defaultAction
    "Do the default action for notifications, which is to resume execution
     of the context which signaled the exception."
    self resume: nil
! !


!Warning methodsFor: 'exception description'!

description
    "Answer a textual description of the exception."
    ^'An exceptional condition has occurred.  It is reported to the user
even though it is not to be considered an error.'
! !


!Error methodsFor: 'exception description'!

description
    "Answer a textual description of the exception."
    ^'An exceptional condition has occurred, and has prevented normal
continuation of processing.'
!

isResumable
    "Answer false.  Error exceptions are by default unresumable; subclasses
     can override this method if desired."
    ^false
! !


!Halt methodsFor: 'description'!

description
    "Answer a textual description of the exception."
    ^'#halt was sent.'
!

isResumable
    "Answer true.  #halt exceptions are by default resumable."
    ^true
! !



!ArithmeticError methodsFor: 'description'!

description
    "Answer a textual description of the exception."
    ^'The program attempted to do an impossible arithmetic operation'
! !


!ZeroDivide class methodsFor: 'instance creation'!

dividend: aNumber
    "Create a new ZeroDivide object remembering that the dividend was 
     aNumber."
    ^super new dividend: aNumber
!

new
    "Create a new ZeroDivide object; the dividend is conventionally
     set to zero."
    ^super new dividend: 0
! !

!ZeroDivide methodsFor: 'accessing'!

dividend
    "Answer the number that was being divided by zero"
    ^dividend
! !

!ZeroDivide methodsFor: 'private'!

dividend: aNumber
    dividend := aNumber
! !

!ZeroDivide methodsFor: 'description'!

description
    "Answer a textual description of the exception."
    ^'The program attempted to divide a number by zero'
! !


!MessageNotUnderstood methodsFor: 'accessing'!

message
    "Answer the message that wasn't understood"
    ^message
!

receiver
    "Answer the object to whom the message send was directed"
    ^receiver
! !

!MessageNotUnderstood methodsFor: 'private'!

message: aMessage receiver: anObject
    message := aMessage.
    receiver := anObject.

    self messageText: ('did not understand ', message selector printString)
! !

!MessageNotUnderstood methodsFor: 'description'!

description
    "Answer a textual description of the exception."
    ^'The program sent a message which was not understood by the receiver.'
! !


!Number methodsFor: 'error raising' "ifTrue: false"!

arithmeticError: msg
    "Raise an ArithmeticError exception having msg as its message text."
    ^ArithmeticError new signal: msg
!

zeroDivide
    "Raise a division-by-zero (ZeroDivide) exception whose dividend
     is the receiver."
    ^(ZeroDivide dividend: self) signal
! !


!Object methodsFor: 'error raising' "ifTrue: false"!

doesNotUnderstand: aMessage
    "Called by the system when a selector was not found. message is a
     Message containing information on the receiver"

     "aMessage inspect."
     "thisContext parentContext method inspect."
     "ObjectMemory abort."
     ^MessageNotUnderstood new
	message: aMessage receiver: self;
	signal
!

error: message
    "Display a walkback for the receiver, with the given error message.
     Signal an `Error' exception (you can trap it the old way too, with
     `ExError'"
    ^Error new
	signal: message
!

halt: message
    "Display a walkback for the receiver, with the given error message.
     Signal an `Halt' exception (you can trap it the old way too, with
     `ExHalt')"
    ^Halt new
	signal: message
! !

Exception initialize!


!SystemExceptions.ProcessBeingTerminated methodsFor: 'accessing'!

description
    "Answer a textual description of the exception."
    ^'the current process is being terminated'! !

!SystemExceptions.EndOfStream class methodsFor: 'signaling'!

signalOn: stream
    "Answer an exception reporting the parameter has reached its end."
    ^self new
	stream: stream;
	signal
! !

!SystemExceptions.EndOfStream methodsFor: 'accessing'!

description
    "Answer a textual description of the exception."
    ^'end of stream reached'!

stream
    "Answer the stream whose end was reached."
    ^stream!

stream: anObject
    "Set the stream whose end was reached."
    stream := anObject! !

!SystemExceptions.NotEnoughElements class methodsFor: 'signaling'!

signalOn: remainingCount
    "Answer an exception reporting the parameter as invalid."
    ^self new
	remainingCount: remainingCount;
	signal
! !

!SystemExceptions.NotEnoughElements methodsFor: 'accessing'!

description
    "Answer a textual description of the exception."
    ^'premature end of stream'!

messageText
    "Answer an exception's message text."
    ^'%1: %2 element(s) missing' bindWith: self basicMessageText
	with: self remainingCount!

remainingCount
    "Answer the number of items that were to be read."
    ^remainingCount!

remainingCount: anObject
    "Set the number of items that were to be read."
    remainingCount := anObject! !

!SystemExceptions.InvalidValue class methodsFor: 'signaling'!

signalOn: value
    "Answer an exception reporting the parameter as invalid."
    ^self new
	value: value;
	signal
!

signalOn: value reason: reason
    "Answer an exception reporting `value' as invalid, for the given
     reason."
    ^self new
	value: value;
	signal: reason
! !

!SystemExceptions.InvalidValue methodsFor: 'accessing'!

description
    "Answer a textual description of the exception."
    ^'unknown error'!

messageText
    "Answer an exception's message text."
    ^'Invalid value %1: %2' bindWith: self value with: self basicMessageText!

value
    "Answer the object that was found to be invalid."
    ^value!

value: anObject
    "Set the object that was found to be invalid."
    value := anObject! !

!SystemExceptions.InvalidArgument methodsFor: 'accessing'!

messageText
    "Answer an exception's message text."
    ^'Invalid argument %1: %2'
	bindWith: self value
	with: self basicMessageText! !

!SystemExceptions.AlreadyDefined methodsFor: 'accessing'!

description
    "Answer a description for the error"
    ^'symbol already defined'! !

!SystemExceptions.ArgumentOutOfRange class methodsFor: 'signaling'!

signalOn: value mustBeBetween: low and: high
    "Raise the exception.  The given value was not between low and high."
    | errorString |
    errorString := RegressionTesting
	ifTrue: [ 'argument out of range' ]
	ifFalse: [ 'argument must be between ', low printString,
		' and ', high printString ].

    ^self new
	value: value;
	low: low;
	high: high;
	signal: errorString
! !

!SystemExceptions.ArgumentOutOfRange methodsFor: 'accessing'!

description
    "Answer a textual description of the exception."
    ^'argument out of range'!

low
    "Answer the lowest value that was permitted."
    ^low!

low: aMagnitude
    "Set the lowest value that was permitted."
    low := aMagnitude!

high
    "Answer the highest value that was permitted."
    ^high!

high: aMagnitude
    "Set the highest value that was permitted."
    high := aMagnitude! !

!SystemExceptions.IndexOutOfRange class methodsFor: 'signaling'!

signalOn: aCollection withIndex: value
    "The given index was out of range in aCollection."
    ^self new
	collection: aCollection;
	value: value;
	signal
! !

!SystemExceptions.IndexOutOfRange methodsFor: 'accessing'!

description
    "Answer a textual description of the exception."
    ^'index out of range'!

messageText
    "Answer an exception's message text."
    ^'Invalid index %1: %2'
	bindWith: self value with: self basicMessageText!

collection
    "Answer the collection that triggered the error"
    ^collection!

collection: anObject
    "Set the collection that triggered the error"
    collection := anObject! !

!SystemExceptions.EmptyCollection methodsFor: 'accessing'!

description
    "Answer a textual description of the exception."
    ^'the collection is empty'! !

!SystemExceptions.InvalidSize methodsFor: 'accessing'!

description
    "Answer a textual description of the exception."
    ^'invalid size'! !

!SystemExceptions.NotFound class methodsFor: 'accessing'!

signalOn: value what: aString
    "Raise an exception; aString specifies what was not found (a key,
     an object, a class, and so on)."
    ^self new
	value: value;
	signal: aString, ' not found'!

!SystemExceptions.NotFound methodsFor: 'accessing'!

description
    "Answer a textual description of the exception."
    ^'not found'! !

!SystemExceptions.WrongClass class methodsFor: 'signaling'!

signalOn: anObject mustBe: aClassOrArray
    "Raise an exception.  The given object should have been an instance
     of one of the classes indicated by aClassOrArray (which should be
     a single class or an array of classes).  Whether instances of
     subclasses are allowed should be clear from the context, though
     in general (i.e. with the exception of a few system messages)
     they should be."

    (aClassOrArray isKindOf: Collection) ifFalse: [
	^self signalOn: anObject mustBe: { aClassOrArray binding } ].

    ^self new
	validClasses: aClassOrArray;
	value: anObject;
	signal
! !

!SystemExceptions.WrongClass methodsFor: 'accessing'!

description
    "Answer a textual description of the exception."
    ^'wrong argument type'!

messageText
    "Answer an exception's message text."
    ^'Invalid argument %1: must be %2'
	bindWith: self value with: self validClassesString!

validClasses
    "Answer the list of classes whose instances would have been valid."
    ^validClasses!

validClassesString
    "Answer the list of classes whose instances would have been valid,
    formatted as a string."
    ^String streamContents: [ :str |
	validClasses keysAndValuesDo: [ :idx :binding |
	    | name class |
	    idx > 1 ifTrue: [
		idx = validClasses size
		    ifFalse: [ str nextPutAll: ', ' ]
		    ifTrue: [ str nextPutAll: ' or ' ]
	    ].
	    class := binding value.
	    name := class nameIn: Namespace current.
	    name first isVowel
		ifTrue: [ str nextPutAll: 'an ' ]
		ifFalse: [ str nextPutAll: 'a ' ].

	    str nextPutAll: name
	]
    ]!

validClasses: aCollection
    "Set the list of classes whose instances would have been valid."
    validClasses := aCollection! !

!SystemExceptions.MustBeBoolean class methodsFor: 'signaling'!

signalOn: anObject
    ^self signalOn: anObject mustBe: #( #{Boolean} )! !

!SystemExceptions.NotIndexable methodsFor: 'accessing'!

description
    "Answer a textual description of the exception."
    ^'object not indexable'! !

!SystemExceptions.ReadOnlyObject methodsFor: 'accessing'!

description
    "Answer a textual description of the exception."
    ^'object is read-only'! !

!SystemExceptions.SecurityError class methodsFor: 'accessing'!

signal: aPermission
    "Raise the exception, setting to aPermission the permission
     that was tested and failed."
    ^self new
	failedPermission: aPermission;
	signal! !

!SystemExceptions.SecurityError methodsFor: 'accessing'!

description
    "Answer a textual description of the exception."
    ^'insecure operation in an untrusted context'!

failedPermission
    "Answer the permission that was tested and that failed."
    ^failedPermission!

failedPermission: anObject
    "Set which permission was tested and failed."
    failedPermission := anObject! !

!SystemExceptions.VerificationError methodsFor: 'accessing'!

description
    "Answer a textual description of the exception."
    ^'a method did not pass the bytecode verification process'! !

!SystemExceptions.BadReturn methodsFor: 'accessing'!

description
    "Answer a textual description of the exception."
    ^'return from a dead method context'! !

!SystemExceptions.CInterfaceError methodsFor: 'accessing'!

description
    "Answer a textual description of the exception."
    ^'error in the C-language interface'! !

!SystemExceptions.FileError methodsFor: 'accessing'!

description
    "Answer a textual description of the exception."
    ^'file system error'! !

!SystemExceptions.MutationError methodsFor: 'accessing'!

description
    "Answer a textual description of the exception."
    ^'cannot mutate the class this way'! !

!SystemExceptions.InvalidProcessState methodsFor: 'accessing'!

description
    "Answer a textual description of the exception."
    ^'invalid operation for this process'! !

!SystemExceptions.VMError methodsFor: 'accessing'!

description
    "Answer a textual description of the exception."
    ^'virtual machine error'! !

!SystemExceptions.NoRunnableProcess methodsFor: 'accessing'!

description
    "Answer a textual description of the exception."
    ^'no runnable process'! !

!SystemExceptions.PrimitiveFailed methodsFor: 'accessing'!

description
    "Answer a textual description of the exception."
    ^'primitive operation failed'! !

!SystemExceptions.WrongArgumentCount methodsFor: 'accessing'!

description
    "Answer a textual description of the exception."
    ^'wrong number of arguments'! !

!SystemExceptions.UserInterrupt methodsFor: 'accessing'!

description
    "Answer a textual description of the exception."
    ^'interrupted!!!'! !

!SystemExceptions.NotImplemented methodsFor: 'accessing'!

description
    "Answer a textual description of the exception."
    ^'method is not implemented'! !

!SystemExceptions.NotYetImplemented methodsFor: 'accessing'!

description
    "Answer a textual description of the exception."
    ^'not yet implemented'! !

!SystemExceptions.ProcessTerminated methodsFor: 'accessing'!

description
    "Answer a textual description of the exception."
    ^'process has/was already terminated'! !

!SystemExceptions.ShouldNotImplement methodsFor: 'accessing'!

description
    "Answer a textual description of the exception."
    ^'should not be implemented in this class'! !

!SystemExceptions.SubclassResponsibility methodsFor: 'accessing'!

description
    "Answer a textual description of the exception."
    ^'method is responsibility of a subclass'! !

!SystemExceptions.WrongMessageSent class methodsFor: 'signaling'!

signalOn: selector useInstead: aSymbol
    "Raise an exception, signaling which selector was sent and suggesting
     a valid alternative."
    ^self new
	selector: selector;
	suggestedSelector: aSymbol;
	signal
! !

!SystemExceptions.WrongMessageSent methodsFor: 'accessing'!

messageText
    "Answer an exception's message text."
    ^'%1, use %2 instead'
	bindWith: self basicMessageText
	with: self suggestedSelector storeString!

selector
    "Answer which selector was sent."
    ^selector!

selector: aSymbol
    "Set which selector was sent."
    selector := aSymbol!

suggestedSelector
    "Answer a valid alternative to the selector that was used."
    ^suggestedSelector!

suggestedSelector: aSymbol
    "Set a valid alternative to the selector that was used."
    suggestedSelector := aSymbol! !
