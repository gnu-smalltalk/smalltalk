"======================================================================
|
|   Inferior process control
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2002, 2006, 2007 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| GNU Smalltalk is free software; you can redistribute it and/or modify it
| under the terms of the GNU General Public License as published by the Free
| Software Foundation; either version 2, or (at your option) any later version.
| 
| GNU Smalltalk is distributed in the hope that it will be useful, but WITHOUT
| ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
| FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
| details.
| 
| You should have received a copy of the GNU General Public License along with
| GNU Smalltalk; see the file COPYING.  If not, write to the Free Software
| Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
|
 ======================================================================"


Object subclass: #Debugger
	instanceVariableNames: 'debugProcess process breakpointContext 
				stepSemaphore '
	classVariableNames: 'MethodLineMapCache'
	poolDictionaries: ''
	category: 'System-Debugging'
!

Debugger comment:
'I provide debugging facilities for another inferior process.  I have
methods that allow the controlled process to proceed with varying
granularity.  In addition, I keep a cache mapping instruction
pointer bytecodes to line numbers.'!

Namespace current: SystemExceptions!

Notification subclass: #DebuggerReentered
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'System-Debugging'
!

DebuggerReentered comment:
'This notification is raised when the debugger is started on a process
that was already being debugged.  Trapping it allows the pre-existing
debugger to keep control of the process.'!

!DebuggerReentered methodsFor: 'description'!

description
    "Answer a textual description of the exception."
    ^'the debugger was started on an already debugged process'! !

Namespace current: Smalltalk!

!Debugger class methodsFor: 'source code'!

currentLineIn: aContext
    | lineMap method |
    method := aContext method.
    MethodLineMapCache isNil ifTrue: [
	MethodLineMapCache := WeakKeyIdentityDictionary new ].
    lineMap := MethodLineMapCache
	at: method
	ifAbsentPut: [ method sourceCodeMap ].
    ^lineMap
	at: aContext ip + 1
	ifAbsent: [ 1 ]
! !

!Debugger class methodsFor: 'instance creation'!

on: aProcess
    "Suspend aProcess and return a new Debugger that controls aProcess.
     aProcess must not be the currently running process."
    aProcess == Processor activeProcess
	ifTrue: [self error: 'cannot attach to current process'].
    aProcess suspend.
    ^self new initializeFor: aProcess! !

!Debugger class methodsFor: 'disabling debugging'!

debuggerClass
    ^nil
! !

!Debugger methodsFor: 'inferior process properties'!

isActive
    "Answer true if the inferior process is still running."
    ^process notNil and: [ process suspendedContext notNil ]
!

process
    "Answer the inferior process."
    ^process
!

currentLine
    "Return the line number in traced process."
    self isActive ifFalse: [ ^'' ].
    ^self suspendedContext currentLine
!

suspendedContext
    "Answer the suspended execution state of the inferior process."
    ^process suspendedContext
! !

!Debugger methodsFor: 'stepping commands'!

stopInferior
    "Suspend the inferior process and raise a DebuggerReentered notification
     in the controlling process."
    self stopInferior: nil
!

stopInferior: anObject
    "Suspend the inferior process and raise a DebuggerReentered notification
     in the controlling process with anObject as the exception's message."
    | exception |
    [
        [
	    process suspend.
            debugProcess
		queueInterrupt: [
		    self disableBreakpointContext.
	            SystemExceptions.DebuggerReentered signal: anObject ];
	        resume.
	] on: Exception do: [ :ex |
	    exception := ex.
	    process resume
	].
    ] forkAt: Processor unpreemptedPriority.

    "Pass the exception on in the calling process."
    exception isNil ifFalse: [ exception signal ]
!

stepBytecode
    "Run a single bytecode in the inferior process."
    debugProcess := Processor activeProcess.
    process singleStepWaitingOn: stepSemaphore.
    process suspend.
    debugProcess := nil.
!

step
    "Run to the end of the current line in the inferior process or to the
     next message send."
    | context line |
    context := self suspendedContext.
    line := self currentLine.
    [
	self stepBytecode.
	self suspendedContext == context and: [ line = self currentLine ]
    ] whileTrue
!

next
    "Run to the end of the current line in the inferior process, skipping
     over message sends."
    | context line |
    context := self suspendedContext.
    line := self currentLine.
    [
	self stepBytecode.
	(self suspendedContext notNil
	    and: [ self suspendedContext parentContext == context ])
	        ifTrue: [ self finish: self suspendedContext ].
	self suspendedContext == context and: [ line = self currentLine ]
    ] whileTrue
!

finish
    "Run to the next return."
    self finish: self suspendedContext
!

finish: aContext
    "Run up until aContext returns."
    <debugging: true>
    | proc cont context retVal |

    "First, use the slow scheme for internal exception handling contexts.
     These are more delicate and in general pretty small, so it is not
     expensive."
    aContext isInternalExceptionHandlingContext
	ifTrue: [ ^self slowFinish: aContext ].
    [ self suspendedContext isInternalExceptionHandlingContext ]
	whileTrue: [ self slowFinish: self suspendedContext ].

    "Create a context that will restart the debugger and place it in the
     chain.  We don't really use the continuation object directly but,
     if we use the methods in Continuation, we are sure that contexts
     are set up correctly."
    debugProcess := Processor activeProcess.
    retVal := Continuation currentDo: [ :cc | cont := cc ].
    Processor activeProcess == debugProcess
	ifTrue: [
	    "Put our context below aContext and restart the debugged process."
	    context := cont stack.

	    context instVarAt: MethodContext instSize put: 2.
	    context parentContext: aContext parentContext.
	    aContext parentContext: context.
	    [
		breakpointContext := aContext.
		debugProcess suspend.
		process resume.
	    ] forkAt: Processor unpreemptedPriority.

	    "Finish the continuation context, which is at the `retVal' line
	     below."
	    debugProcess := nil.
	    self slowFinish: context ]

	ifFalse: [
	    "We arrive here when we finish execution of aContext.  Put the
	     debugger process in control again."
	    [
		breakpointContext := nil.
		process suspend.
		debugProcess resume
	    ] forkAt: Processor unpreemptedPriority.
	    ^retVal ]
!

slowFinish
    "Run in single-step mode up to the next return."
    self slowFinish: self suspendedContext
!

slowFinish: aContext
    "Run in single-step mode until aContext returns."
    | context newContext |
    context := self suspendedContext.
    [
	[
	    self stepBytecode.
	    self suspendedContext == context
	] whileTrue.

	newContext := self suspendedContext.

	newContext notNil "no context? exit"
	    and: [
		"a send? go on"
		newContext parentContext == context or: [
		    "aContext still in the chain? go on"
		    self includes: aContext ] ]
    ] whileTrue.
!

continue
    "Terminate the controlling process and continue execution of the
     traced process."
    | theDebugProcess theProcess |
    theDebugProcess := Processor activeProcess.
    theProcess := process.
    [
        debugProcess := nil.
        process := nil.
	theDebugProcess terminate.
	theProcess resume
    ] forkAt: Processor unpreemptedPriority.

    "Just in case we get here."
    theDebugProcess primTerminate
! !


!Debugger methodsFor: 'private'!

disableBreakpointContext
    "Remove the context inserted set by #finish:."
    | theBreakpointContext |
    theBreakpointContext := breakpointContext.
    breakpointContext := nil.
    debugProcess := nil.

    theBreakpointContext isNil ifFalse: [
	theBreakpointContext
	    parentContext: theBreakpointContext parentContext parentContext ]!

includes: aContext
    "Answer whether aContext is still in the stack of the traced process."
    | context |
    context := self suspendedContext.
    [
	context isNil ifTrue: [ ^false ].
	context == aContext ifTrue: [ ^true ].
	context := context parentContext.
    ] repeat
!

initializeFor: aProcess
    process := aProcess.
    stepSemaphore := Semaphore new!


!ContextPart methodsFor: 'source code'!

currentLine
    "Answer the 1-based number of the line that is pointed to by the receiver's
     instruction pointer."
    ^Debugger currentLineIn: self
!

!ContextPart methodsFor: 'debugging'!

debugger
    "Answer the debugger that is attached to the given context.  It
     is always nil unless the DebugTools package is loaded."
    | ctx home |
    ctx := self.
    [ ctx isNil ] whileFalse: [
	home := ctx home.
        (home notNil and: [
	    (home method attributeAt: #debugging: ifAbsent: [ nil ]) notNil])
	        ifTrue: [ ^ctx receiver ].

	ctx := ctx parentContext ].
    ^nil
! !

!BlockClosure methodsFor: 'instance creation'!

forkDebugger
    "Suspend the currently running process and fork the receiver into a new
     process, passing a Debugger object that controls the currently running
     process."
    | process |
    process := Processor activeProcess.
    [
	process suspend.
	Processor activeProcess priority: process priority.
	self value: (Debugger on: process)
    ] forkAt: Processor unpreemptedPriority.
! !

