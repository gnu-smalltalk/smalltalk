"======================================================================
|
|   ContextPart Method Definitions
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
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"



Object variableSubclass: #ContextPart
       instanceVariableNames: 'parent nativeIP ip sp receiver method '
       classVariableNames: ''
       poolDictionaries: ''
       category: 'Language-Implementation'
!

ContextPart comment: 
'My instances represent executing Smalltalk code, which represent the local
environment of executable code. They contain a stack and also provide some
methods that can be used in inspection or debugging.' !


!ContextPart class methodsFor: 'private'!

spIndex
    ^4
!

checkPresenceOfJIT
    thisContext isJIT
	ifTrue: [ Smalltalk addFeature: #JIT ]
	ifFalse: [ Smalltalk removeFeature: #JIT ]
! !


!ContextPart class methodsFor: 'exception handling'!

backtrace
    "Print a backtrace from the caller to the bottom of the stack on the
     Transcript"
    thisContext parentContext backtraceOn: Transcript
!

backtraceOn: aStream
    "Print a backtrace from the caller to the bottom of the stack on aStream"
    thisContext parentContext backtraceOn: aStream
!

removeLastUnwindPoint
    "Private - Return and remove the last context marked as an unwind point,
     or our environment if the last unwind point belongs to another
     environment."

    | unwindPoints |
    unwindPoints := Processor activeProcess unwindPoints.

    ^unwindPoints isEmpty
	ifTrue: [ thisContext environment ]
	ifFalse: [ unwindPoints removeLast ].
!

lastUnwindPoint
    "Private - Return the last context marked as an unwind point, or
     our environment if none is."

    | unwindPoints |
    unwindPoints := Processor activeProcess unwindPoints.

    ^unwindPoints isEmpty
	ifTrue: [ thisContext environment ]
	ifFalse: [ unwindPoints at: unwindPoints size ].
!

unwind
    "Return execution to the last context marked as an unwind point, returning
     nil on that stack."
    self unwind: nil
!

unwind: returnValue
    "Return execution to the last context marked as an unwind point, returning
     returnValue on that stack."
    | point |
    point := self removeLastUnwindPoint.
    point isProcess ifTrue: [
	Processor terminateActive
	"Bye bye, we never get past here."
    ].
    point continue: returnValue
! !


!ContextPart methodsFor: 'printing'!

backtrace
    "Print a backtrace from the receiver to the bottom of the stack on the
     Transcript."
    self backtraceOn: Transcript
!

backtraceOn: aStream
    "Print a backtrace from the caller to the bottom of the stack on aStream."
    | ctx |
    ctx := self.
    [ ctx isNil or: [ ctx isEnvironment ] ] whileFalse: [
	ctx isDisabled ifFalse: [
	    ctx printOn: aStream.
	    aStream nl
	].
	ctx := ctx parentContext
    ]
! !


!ContextPart methodsFor: 'debugging'!

debuggerClass
    "Answer which debugger should be used to debug the current
     context chain.  The class with the highest debugging
     priority is picked among those mentioned in the chain."
    | ctx debuggerClass currentClass last |
    ctx := self.
    last := self class lastUnwindPoint.
    [
	currentClass := ctx receiver class debuggerClass.
	currentClass isNil ifTrue: [ ^nil ].
	(debuggerClass isNil
	    or: [ currentClass debuggingPriority > debuggerClass debuggingPriority ])
		ifTrue: [ debuggerClass := currentClass ].

	ctx == last | ctx isNil
    ] whileFalse: [
	ctx := ctx parentContext
    ].
    ^debuggerClass
!

isInternalExceptionHandlingContext
    "Answer whether the receiver is a context that should be hidden to the user
     when presenting a backtrace."

    self subclassResponsibility
! !


!ContextPart methodsFor: 'accessing'!

client
    "Answer the client of this context, that is, the object that sent the
     message that created this context. Fail if the receiver has no parent"

    ^self parentContext receiver
!

environment
    "To create a valid execution environment for the interpreter even before
     it starts, GST creates a fake context whose selector is nil and which
     can be used as a marker for the current execution environment. This
     method answers that context.
     For processes, it answers the process block itself"
    | ctx next |
    ctx := self.
    [   next := ctx parentContext.
	ctx isEnvironment | next isNil
    ]   whileFalse: [ ctx := next ].

    ^ctx
!

initialIP
    "Answer the value of the instruction pointer when execution starts
     in the current context"
    ^0
!

isDisabled
    "Answers whether the context is skipped when doing a return.  Contexts
     are marked as disabled whenever a non-local return is done (either by
     returning from the enclosing method of a block, or with the
     #continue: method of ContextPart) and there are unwind contexts such
     as those created by #ensure:.  All non-unwind contexts are then
     marked as disabled."
    self subclassResponsibility
!

isUnwind
    "Answers whether the context must continue execution even after a
     non-local return (a return from the enclosing method of a block, or
     a call to the #continue: method of ContextPart).  Such contexts are
     created by #ensure:."
    self subclassResponsibility
!

isEnvironment
    "To create a valid execution environment for the interpreter even
     before it starts, GST creates a fake context which invokes a special
     ``termination'' method.  Such a context can be used as a marker for
     the current execution environment.  Answer whether the receiver is
     that kind of context."
    self subclassResponsibility
!

isProcess
    "Answer whether the receiver represents a process context, i.e. a context
     created by BlockClosure>>#newProcess. Such a context can be recognized
     because it has no parent but its flags are different from those of the
     contexts created by the VM's prepareExecutionEnvironment function."
    ^self parentContext isNil & self isEnvironment not
!

parentContext
    "Answer the context that called the receiver"
    ^parent
!

parentContext: aContext
    "Set the context to which the receiver will return"
    
    "Fixed typing isn't usually good, but this is too important"
    (aContext class superclass == ContextPart) | (aContext isNil)
	ifFalse: [ ^SystemExceptions.WrongClass signalOn: aContext mustBe: ContextPart ].

    parent := aContext
!

ip
    "Answer the current instruction pointer into the receiver"
    "This funny implementation thwarts the interpreter's optimizing effort"
    ^ip yourself
!

ip: newIP
    "Set the instruction pointer for the receiver"
    "Fixed typing isn't usually good, but this is too important"
    newIP isSmallInteger
	ifFalse: [ ^SystemExceptions.WrongClass signalOn: newIP mustBe: SmallInteger ].
    ip := newIP
!

size
    "Answer the number of valid fields for the receiver. Any read
     access from (self size + 1) to (self basicSize) has undefined
     results - even crashing"
    ^self sp + 1
!

sp
    "Answer the current stack pointer into the receiver"
    "This funny implementation thwarts the interpreter's optimizing effort"
    ^sp yourself
!

validSize
    "Answer how many elements in the receiver should be inspected"
    ^self size
!

numArgs
    "Answer the number of arguments passed to the receiver"
    ^self method numArgs
!

numTemps
    "Answer the number of temporaries used by the receiver"
    ^self method numTemps
!

push: anObject
    "Push an object on the receiver's stack."

    "Since the newly accessible slots may have contained garbage, this method
     stores into the cell *before* they become accessible."

    self at: self size + 1 put: anObject.
    sp := sp + 1
!

sp: newSP
    "Set the stack pointer for the receiver."

    "Storing into the stack pointer is a potentially dangerous thing, so
     this code tests that sp is effectively a number.  Also, since the
     newly accessible slots may have contained garbage, this method
     stores nil into any cells that become accessible."

    newSP isSmallInteger
	ifFalse: [ ^SystemExceptions.WrongClass signalOn: newSP mustBe: SmallInteger ].

    newSP > sp ifTrue: [
	sp + 1 to: newSP do: [ :i | self at: i put: nil ]
    ].
    sp := newSP
!

method
    "Return the CompiledMethod being executed"
    ^method
!

methodClass
    "Return the class in which the CompiledMethod being executed is defined"
    ^self method methodClass
!

isBlock
    "Answer whether the receiver is a block context"
    self subclassResponsibility
!

receiver
    "Return the receiver (self) for the method being executed"
    "This funny implementation thwarts the interpreter's optimizing effort"
    ^receiver yourself
!

selector
    "Return the selector for the method being executed"
    ^self method selector
!

home
    "Answer the MethodContext to which the receiver refers"
    self subclassResponsibility
! !


!ContextPart methodsFor: 'private'!

isJIT
    ^nativeIP ~~ 0
! !


!ContextPart methodsFor: 'exception handling'!

mark
    "Add the receiver as a possible unwind point"
    Processor activeProcess unwindPoints addLast: self
! !


!ContextPart methodsFor: 'copying'!

deepCopy
    "Answer a copy of the entire stack, but don't copy any
     of the other instance variables of the context."
    ^self copyStack!

copyStack
    "Answer a copy of the entire stack."
    | ret ctx |
    ret := ctx := self copy.
    [ ctx parentContext isNil ] whileFalse: [
        ctx parentContext: (ctx := ctx parentContext copy) ].

    ^ret! !


!ContextPart methodsFor: 'enumerating'!

scanBacktraceForAttribute: selector do: aBlock
    "Scan the backtrace for contexts which have the attribute selector
     listed in selectors; if one is found, invoke aBlock passing the
     context and the attribute."
    | ctx last attr |
    ctx := self.
    last := self class lastUnwindPoint.
    [ ctx == last | ctx isNil ] whileFalse: [
	(ctx isBlock not and: [
	    attr := ctx method attributeAt: selector ifAbsent: [ nil ].
	    attr notNil ])
		ifTrue: [ aBlock value: ctx value: attr ].

	ctx := ctx parentContext
    ].
!

scanBacktraceFor: selectors do: aBlock
    "Scan the backtrace for contexts whose selector is among those
     listed in selectors; if one is found, invoke aBlock passing the
     context."
    | ctx last |
    ctx := self.
    last := self class lastUnwindPoint.
    [ ctx == last | ctx isNil ] whileFalse: [
	(ctx isBlock not and: [
	    selectors includes: ctx selector ])
		ifTrue: [ aBlock value: ctx ].

	ctx := ctx parentContext
    ].
! !


!ContextPart methodsFor: 'security checks'!

securityCheckForName: name
    self isUntrusted ifFalse: [ ^self ].

    ^self doSecurityCheckForName: name actions: #() target: nil
!

securityCheckForName: name action: action
    self isUntrusted ifFalse: [ ^self ].

    ^self doSecurityCheckForName: name actions: { action } target: nil
!

securityCheckForName: name target: target
    self isUntrusted ifFalse: [ ^self ].

    ^self doSecurityCheckForName: name actions: #() target: target
!

securityCheckForName: name actions: actions target: target
    self isUntrusted ifFalse: [ ^self ].

    ^self doSecurityCheckForName: name actions: actions target: target
!

doSecurityCheckForName: name actions: actions target: target
    | perm ctx |
    perm := Permission new
	name: name
	actions: actions;
	target: target.

    (self checkSecurityFor: perm)
	ifFalse: [ (SecurityError for: perm) signal ].
!

checkSecurityFor: perm
    | state foundAnnotation |
    "First of all, check against the static permissions for this
     context."
    (self receiver class check: perm) ifFalse: [ ^false ].

    "Then, check the dynamic permissions.  So:
     1) check if a method was specifically denying access,
     2) look for a deeper context whose static permissions
	denies access, but stop if a method is specifically
	granting access."

    self method isAnnotated ifTrue: [
	foundAnnotation := false.
	self method attributesDo: [ :each || newPerm |
	    each selector = #permission: ifTrue: [
		newPerm := each arguments at: 1.

		(newPerm implies: perm) ifTrue: [
		    "Should we check if the granted permission is statically
		     available?  Of course, you can only grant permissions if you
		     own them statically, so the real question is, should we
		     check perm or newPerm?  The answer is perm (which has
		     already been found to be available), hence we can skip
		     an expensive static permission check.  Suppose we have a
		     method that grants access to all files: it makes more sense
		     if it means ``grant access to all files allowed by the class
		     security policy'', rather than ``grant access to all files if
		     the security policy allows it, else do not grant access to
		     any file''."
		    foundAnnotation := true.
		    state := newPerm isAllowing
		]
	    ]
	].
	foundAnnotation ifTrue: [ ^state ].
    ].

    "Nope, no special regulations were found in this method.  Look in the
     parent context, and grant permission if the bottom is reached."

    ^self parentContext isNil or: [
	self parentContext checkSecurityFor: perm ]
! !


!ContextPart class methodsFor: 'built ins'!

thisContext
    "Return the value of the thisContext variable.  Called internally
     when the variable is accessed."

    <primitive: VMpr_ContextPart_thisContext>
! !

!ContextPart methodsFor: 'built ins'!

continue: anObject
    "Resume execution from the receiver, faking that the context on
     top of it in the execution chain has returned anObject.  The
     receiver must belong to the same process as the executing context,
     otherwise the results are not predictable.  All #ensure: (and
     possibly #ifCurtailed:) blocks between the currently executing
     context and the receiver are evaluated (which is not what
     would happen if you directly bashed at the parent context of
     thisContext)."

    <primitive: VMpr_ContextPart_continue>
    self badReturnError
! !


