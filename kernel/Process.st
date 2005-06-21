"======================================================================
|
|   Process Method Definitions
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2002,2003
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


Link subclass: #Process
     instanceVariableNames: 'suspendedContext priority myList name unwindPoints interruptLock interrupts'
     classVariableNames: ''
     poolDictionaries: ''
     category: 'Language-Processes'
!

Process comment: 
'I represent a unit of computation.  My instances are independantly
executable blocks that have a priority associated with them, and they
can suspend themselves and resume themselves however they wish.' !


!Process class methodsFor: 'private'!

on: aBlockContext at: aPriority suspend: aBoolean
    "Private - Create a process running aBlockContext at the given
     priority.  The process is suspended immediately after
     initialization if aBoolean is true"
    ^self new onBlock: aBlockContext at: aPriority suspend: aBoolean
! !



!Process methodsFor: 'basic'!

lowerPriority
    "Lower a bit the priority of the receiver. A #lowerPriority will
     cancel a previous #raisePriority, and vice versa."
    self priority: self priority - 1!

raisePriority
    "Raise a bit the priority of the receiver. A #lowerPriority will
     cancel a previous #raisePriority, and vice versa."
    self priority: self priority + 1!

singleStep
    "Execute a limited amount of code (usually a bytecode, or up to the
     next backward jump, or up to the next message send) of the receiver,
     which must in a ready-to-run state (neither executing nor terminating
     nor suspended), then restart running the current process.  The current
     process should have higher priority than the receiver.  For better
     performance, use the underlying primitive, Process>>#singleStepWaitingOn:."
    ^self singleStepWaitingOn: Semaphore new!

suspend
    "Do nothing if we're already suspended. Note that the blue book made
     suspend a primitive - but the real primitive is yielding control to
     another process. Suspending is nothing more than taking ourselves out
     of every scheduling list and THEN yielding control to another process"

    self isSuspended ifTrue: [ ^nil ].
    myList := Processor changePriorityListOf: self to: priority suspend: true.
    self yield
!

terminate
    "Terminate the receiver after having evaluated all the #ensure: and
     #ifCurtailed: blocks that are active in it.  This is done by signalling
     a ProcessBeingTerminated notification."
    [
        Processor activeProcess == self
	    ifFalse: [
		self queueInterrupt: [ SystemExceptions.ProcessBeingTerminated signal ].
		^self
	    ].
    ] valueWithoutPreemption.

    SystemExceptions.ProcessBeingTerminated signal!

primTerminate
    "Terminate the receiver - This is nothing more than prohibiting to
     resume the process, then suspending it."
    suspendedContext := nil.
    self suspend
! !



!Process methodsFor: 'printing'!

printOn: aStream
    "Print a representation of the receiver on aStream"

    aStream
	print: self class;
	nextPut: $(;
	print: name;
	nextPutAll: ' at ';
	nextPutAll: (Processor priorityName: self priority);
	nextPut: $,.

     "The order here is important!"
     self isActive ifTrue: [ aStream nextPutAll: ' active)'. ^self ].
     self isTerminated ifTrue: [ aStream nextPutAll: ' terminated)'. ^self ].
     self isWaiting ifTrue: [ aStream nextPutAll: ' waiting on a semaphore)'. ^self ].
     self isSuspended ifTrue: [ aStream nextPutAll: ' suspended)'. ^self ].
     self isReady ifTrue: [ aStream nextPutAll: ' ready to run)'. ^self ].
     aStream nextPutAll: ' undefined state)'.
! !


!Process methodsFor: 'accessing'!

externalInterruptsEnabled
    "Answer whether the receiver is executed with interrupts enabled"

    ^interrupts isNil or: [ interrupts <= 0 ]
!

suspendedContext
    "Answer the context that the process was executing at the time it was
     suspended."
    ^suspendedContext
!

name
    "Answer the user-friendly name of the process."
    ^name
!

name: aString
    "Give the name aString to the process"
    name := aString
!

priority
    "Answer the receiver's priority"
    ^priority
!

priority: anInteger
    "Change the receiver's priority to anInteger"
    | old |

    (anInteger < Processor lowestPriority) |
    (anInteger > Processor highestPriority)
	ifTrue: [ SystemExceptions.ArgumentOutOfRange signalOn: anInteger
	    mustBeBetween: Processor lowestPriority
	    and: Processor highestPriority ].

    self setPriorityFrom: Processor activePriority to: anInteger suspend: false!

setPriorityFrom: activePriority to: anInteger suspend: aBoolean
    "Change the priority to anInteger.  If aBoolean is true,
     suspend the process after having done so; if it is false,
     check if it is nicer to relinquish control from the running
     process (based on the priority of the active process, that
     is passed in activePriority) and if this is the case, preempt it."

    | state |
    [
	state := #wait.
	self isReady ifTrue: [ state := #ready ].
	self isActive ifTrue: [ state := #active ].

	state = #wait ifFalse: [
	    myList := Processor
	        changePriorityListOf: self
	        to: anInteger
	        suspend: aBoolean
	].

	priority := anInteger.
	(aBoolean
	    or: [ (state = #ready and: [ activePriority < priority ])
		or: [ state = #active and: [ activePriority > priority ]]])

	    ifTrue: [ Processor yield ]

    ] valueWithoutPreemption
!

valueWithoutInterrupts: aBlock
    "Evaluate aBlock and delay all interrupts that are requested during its
     execution to after aBlock returns."
    ^self interruptLock critical: aBlock
!

queueInterrupt: aBlock
    "Force the receiver to be interrupted and to evaluate aBlock as soon as it
     becomes the active process (this could mean NOW if the receiver is active).
     If the process is temporarily suspended or waiting on a semaphore, it is
     temporarily woken up so that the interrupt is processed as soon as the
     process priority allows to do.  Answer the receiver."

    self interruptLock critical: [
	| block suspended semaphore |
	self isActive
	    ifTrue: [ aBlock value. ^self ].

        self isTerminated
	    ifTrue: [ ^SystemExceptions.ProcessTerminated signalOn: self ].

	semaphore := myList.
	suspended := self isReady not.
	block := suspended
	    ifFalse: [ self suspend. aBlock ]
	    ifTrue: [
		semaphore isNil
		    ifTrue: [ [self evaluate: aBlock ifNotTerminated: [self suspend]] ]
		    ifFalse: [ [self evaluate: aBlock ifNotTerminated: [semaphore wait]] ]
	    ].

	suspendedContext := block asContext: suspendedContext.
	self resume
    ].
! !


!Process methodsFor: 'private'!

evaluate: aBlock ifNotTerminated: unwindBlock
    | terminated |
    terminated := false.
    [
	aBlock on: ProcessBeingTerminated do: [ :sig | terminated := true. sig pass ].
    ] ensure: [
	terminated ifFalse: [ unwindBlock value ]
    ]
!

unwindPoints
    unwindPoints isNil ifTrue: [ unwindPoints := OrderedCollection new ].
    ^unwindPoints
!

interruptLock
    "Answer the RecursionLock object used to prevent nested interrupts."

    "Fast path for interruptLock ~~ nil."
    interruptLock isNil ifFalse: [ ^interruptLock ].

    "Slow path for when initialization is needed."
    ^[
	"Look out for race conditions!"
        interruptLock isNil ifTrue: [ interruptLock := RecursionLock new ].
	interruptLock
    ] valueWithoutPreemption!

startExecution: aDirectedMessage

    "It is important to retrieve this before we start the
     process, because we want to choose whether to continue
     running the new process based on the *old* activePriority,
     not the one of the new process which is the maximum one."

    [ aDirectedMessage send ]
	on: SystemExceptions.ProcessBeingTerminated
	do: [ :sig | sig return ].
!

onBlock: aBlockClosure at: aPriority suspend: aBoolean
    | closure activePriority |

    "It is important to retrieve this before we start the
     process, because we want to choose whether to continue
     running the new process based on the *old* activePriority,
     not the one of the new process which is the maximum one."

    activePriority := Processor activePriority.
    closure := [
	[
	    self setPriorityFrom: activePriority to: aPriority suspend: aBoolean.
	    aBlockClosure value ]

	    on: SystemExceptions.ProcessBeingTerminated
	    do: [ :sig | sig return ].

	self primTerminate
    ].

    "Start the Process immediately so that we get into the
     #on:do: handler.  Otherwise, we will not be able to
     terminate the process with #terminate."
    suspendedContext := closure asContext: nil.
    priority := Processor unpreemptedPriority.
    self resume
!

isActive
    "Answer whether the receiver is running"
    ^self == Processor activeProcess
!

isReady
    "Answer whether the receiver is not suspended nor waiting on a
     semaphore (maybe it is active, maybe it is not, though)"
    ^myList == (Processor processesAt: priority)
!

isSuspended
    "Answer whether the receiver is suspended through #suspend"
    ^myList isNil
!

isTerminated
    "Answer whether the receiver has already terminated"
    ^suspendedContext isNil
!

isWaiting
    "Answer whether the receiver is wating on a semaphore"
    ^self isReady not & self isSuspended not
! !

