"======================================================================
|
|   Process Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2002,2003,2007,2008,2009
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



Link subclass: Process [
    | suspendedContext priority myList name environment interruptLock interrupts |
    
    <category: 'Language-Processes'>
    <comment: 'I represent a unit of computation.  My instances are independantly
executable blocks that have a priority associated with them, and they
can suspend themselves and resume themselves however they wish.'>

    Process class >> on: aBlockClosure at: aPriority suspend: aBoolean [
	"Private - Create a process running aBlockClosure at the given
	 priority.  The process is suspended immediately after
	 initialization if aBoolean is true"

	<category: 'private'>
	^self new 
	    onBlock: aBlockClosure
	    at: aPriority
	    suspend: aBoolean
    ]

    debugger [
	"Return the object in charge of debugging the receiver.  This always returns
	 nil unless the DebugTools package is loaded."

	<category: 'basic'>
	^self context debugger
    ]

    context [
	"Return the execution context of the receiver."

	<category: 'basic'>
	^self == Processor activeProcess 
	    ifTrue: [thisContext parentContext]
	    ifFalse: [suspendedContext]
    ]

    makeUntrusted: aBoolean [
	"Set whether the receiver is trusted or not."

	<category: 'basic'>
	| ctx |
	ctx := self context.
	[ctx isNil] whileFalse: 
		[ctx makeUntrusted: aBoolean.
		ctx := ctx parentContext]
    ]

    lowerPriority [
	"Lower a bit the priority of the receiver. A #lowerPriority will
	 cancel a previous #raisePriority, and vice versa."

	<category: 'basic'>
	self priority: self priority - 1
    ]

    raisePriority [
	"Raise a bit the priority of the receiver. A #lowerPriority will
	 cancel a previous #raisePriority, and vice versa."

	<category: 'basic'>
	self priority: self priority + 1
    ]

    singleStep [
	"Execute a limited amount of code (usually a bytecode, or up to the
	 next backward jump, or up to the next message send) of the receiver,
	 which must in a ready-to-run state (neither executing nor terminating
	 nor suspended), then restart running the current process.  The current
	 process should have higher priority than the receiver.  For better
	 performance, use the underlying primitive, Process>>#singleStepWaitingOn:."

	<category: 'basic'>
	^self singleStepWaitingOn: Semaphore new
    ]

    suspend [
	"Do nothing if we're already suspended. Note that the blue book made
	 suspend a primitive - but the real primitive is yielding control to
	 another process. Suspending is nothing more than taking ourselves out
	 of every scheduling list and THEN yielding control to another process"

	<category: 'builtins'>
	<primitive: VMpr_Process_suspend>
    ]

    finalize [
	"Terminate processes that are GCed while waiting on a dead semaphore."

	<category: 'basic'>
	^self terminate
    ]

    terminate [
	"Terminate the receiver after having evaluated all the #ensure: and
	 #ifCurtailed: blocks that are active in it.  This is done by signalling
	 a ProcessBeingTerminated notification."

	<category: 'basic'>
	| semaphore |

	[self isTerminated ifTrue: [^self].
	Processor activeProcess == self 
	    ifFalse: 
		[semaphore := self isWaiting ifTrue: [myList].
		self queueInterrupt:
		    [SystemExceptions.ProcessBeingTerminated new
			semaphore: semaphore;
			signal].
		^self]] 
		valueWithoutPreemption.
	SystemExceptions.ProcessBeingTerminated signal
    ]

    update: aSymbol [
	"Private - Terminate the process when ObjectMemory class>>#quit:
	 is sent.  This is invoked only after #terminateOnQuit."

	<category: 'private'>
        aSymbol == #aboutToQuit ifTrue: [ self terminate ]
    ]

    terminateOnQuit [
	"Mark the receiver so that it is terminated when
	 ObjectMemory class>>#quit: is sent."

	<category: 'basic'>
        ObjectMemory addDependent: self
    ]

    primTerminate [
	"Terminate the receiver - This is nothing more than prohibiting to
	 resume the process, then suspending it."

	<category: 'basic'>
	self removeToBeFinalized.
	suspendedContext := nil.
	self suspend
    ]

    printOn: aStream [
	"Print a representation of the receiver on aStream"

	<category: 'printing'>
	aStream
	    print: self class;
	    nextPut: $(;
	    print: name;
	    nextPutAll: ' at ';
	    nextPutAll: (Processor priorityName: self priority);
	    nextPut: $,.

	"The order here is important!"
	self isActive 
	    ifTrue: 
		[aStream nextPutAll: ' active)'.
		^self].
	self isTerminated 
	    ifTrue: 
		[aStream nextPutAll: ' terminated)'.
		^self].
	self isWaiting 
	    ifTrue: 
		[aStream nextPutAll: ' waiting on a semaphore)'.
		^self].
	self isSuspended 
	    ifTrue: 
		[aStream nextPutAll: ' suspended)'.
		^self].
	self isReady 
	    ifTrue: 
		[aStream nextPutAll: ' ready to run)'.
		^self].
	aStream nextPutAll: ' undefined state)'
    ]

    externalInterruptsEnabled [
	"Answer whether the receiver is executed with interrupts enabled"

	<category: 'accessing'>
	^interrupts isNil or: [interrupts <= 0]
    ]

    suspendedContext [
	"Answer the context that the process was executing at the time it was
	 suspended."

	<category: 'accessing'>
	^suspendedContext
    ]

    suspendedContext: aContext [
	"Modify the context that the process was executing at the time it was
	 suspended."

	<category: 'accessing'>
	suspendedContext := aContext
    ]

    name [
	"Answer the user-friendly name of the process."

	<category: 'accessing'>
	^name
    ]

    name: aString [
	"Give the name aString to the process"

	<category: 'accessing'>
	name := aString
    ]

    priority [
	"Answer the receiver's priority"

	<category: 'accessing'>
	^priority
    ]

    priority: anInteger [
	"Change the receiver's priority to anInteger"

	<category: 'accessing'>
	(anInteger between: Processor lowestPriority 
	    and: Processor highestPriority) 
		ifFalse: 
		    [SystemExceptions.ArgumentOutOfRange 
			signalOn: anInteger
			mustBeBetween: Processor lowestPriority
			and: Processor highestPriority].

	[
	    | activePriority |
            activePriority := Processor activePriority.
	    priority := anInteger.
	    "Atomically move the process to the right list, preempting
             the current process if necessary."
            self isReady ifTrue: [self resume].
	] valueWithoutPreemption
    ]

    valueWithoutInterrupts: aBlock [
	"Evaluate aBlock and delay all interrupts that are requested during its
	 execution to after aBlock returns."

	<category: 'accessing'>
	^self interruptLock critical: aBlock
    ]

    signalInterrupt: anException [
	"Force the receiver to be interrupted and anException to be raised as
	 soon as it becomes the active process (this could mean NOW if the
         receiver is active).  If the process is suspended or waiting on a
         semaphore, it is woken up so that the interrupt is processed
         as soon as the process priority allows to do.  The exception should
         not be resumable to avoid that execution is continued without
         the process actually having gotten a signal on the semaphore (this
         restriction may be lifted in the future)."
        <category: '*timeout-private'>
        self interruptLock critical:
            [| block |
                self isActive
                    ifTrue:
                        [anException signal.
                         ^self].
                 self isTerminated ifFalse: [
                     block := [self evaluate: [anException signal]
                         ifNotTerminated: [self resume]].
                     suspendedContext := block asContext: suspendedContext.
                     self resume]]
    ]

    queueInterrupt: aBlock [
	"Force the receiver to be interrupted and to evaluate aBlock as soon as it
	 becomes the active process (this could mean NOW if the receiver is active).
	 If the process is temporarily suspended or waiting on a semaphore, it is
	 temporarily woken up so that the interrupt is processed as soon as the
	 process priority allows to do.  Answer the receiver."

	<category: 'accessing'>
	self interruptLock critical: 
		[| block suspended semaphore |
		self isActive 
		    ifTrue: 
			[aBlock value.
			^self].
		self isTerminated 
		    ifTrue: [^SystemExceptions.ProcessTerminated signalOn: self].
		semaphore := myList.
		suspended := self isReady not.
		block := suspended
			    ifFalse: 
				[self suspend.
				aBlock]
			    ifTrue: 
				[semaphore isNil 
				    ifTrue: [[self evaluate: aBlock ifNotTerminated: [self suspend]]]
				    ifFalse: [[self evaluate: aBlock ifNotTerminated: [semaphore wait]]]].
		suspendedContext := block asContext: suspendedContext.
		self resume]
    ]

    evaluate: aBlock ifNotTerminated: unwindBlock [
	<category: 'private'>
	| terminated |
	terminated := false.
	
	[aBlock on: ProcessBeingTerminated
	    do: 
		[:sig | 
		terminated := true.
		sig pass]] 
		ensure: [terminated ifFalse: [unwindBlock value]]
    ]

    environment [
	"This is private because it is not thread-safe.  Access via
	 ProcessorScheduler>>#environment only touches the environment
	 of the current process, so expensive semaphores are unnecessary.
	 We may want to revisit this in the future, but it won't be
	 backwards-incompatible."

	<category: 'private'>
	environment isNil ifTrue: [environment := IdentityDictionary new].
	^environment
    ]

    interruptLock [
	"Answer the RecursionLock object used to prevent nested interrupts."

	"Fast path for interruptLock ~~ nil."

	<category: 'private'>
	interruptLock isNil ifFalse: [^interruptLock].

	"Slow path for when initialization is needed."
	^
	["Look out for race conditions!"

	interruptLock isNil ifTrue: [interruptLock := RecursionLock new].
	interruptLock] 
		valueWithoutPreemption
    ]

    startExecution: aDirectedMessage [
	"It is important to retrieve this before we start the
	 process, because we want to choose whether to continue
	 running the new process based on the *old* activePriority,
	 not the one of the new process which is the maximum one."

	<category: 'private'>
	[aDirectedMessage send] on: SystemExceptions.ProcessBeingTerminated
	    do: [:sig | sig return]
    ]

    onBlock: aBlockClosure at: aPriority suspend: aBoolean [
	<category: 'private'>
	"It is important to retrieve this before we start the
	 process, because we want to choose whether to continue
	 running the new process based on the *old* activePriority,
	 not the one of the new process which is the maximum one."

	| closure activePriority |
	activePriority := Processor activePriority.
	closure :=
	    [[[
		"#priority: is inlined for two reasons.  First, to be able to
		 suspend the process, and second because we need to invert
		 the test on activePriority!  This because here we may want to
		 yield to the creator, while in #priority: we may want to yield
		 to the process whose priority was changed."
		priority := aPriority.
		aBoolean
		    ifTrue: [self suspend]
		    ifFalse: [
			aPriority < activePriority ifTrue: [ Processor yield ] ].
		aBlockClosure value]
			on: SystemExceptions.ProcessBeingTerminated
			do: 
			    [:sig | 
			    "If we terminate in the handler, the 'ensure' blocks are not
			     evaluated.  Instead, if the handler returns, the unwinding
			     is done properly."

			    sig return]] 
			ensure: [self primTerminate]].

	"Start the Process immediately so that we get into the
	 #on:do: handler.  Otherwise, we will not be able to
	 terminate the process with #terminate.  The #resume will
         preempt the forking process."
	suspendedContext := closure asContext: nil.
	priority := Processor unpreemptedPriority.
	self
	    addToBeFinalized;
	    resume
    ]

    isActive [
	"Answer whether the receiver is running"

	<category: 'private'>
	^self == Processor activeProcess
    ]

    isReady [
	"Answer whether the receiver is not suspended nor waiting on a
	 semaphore (maybe it is active, maybe it is not, though)"

	<category: 'private'>
	^myList == (Processor processesAt: priority)
    ]

    isSuspended [
	"Answer whether the receiver is suspended through #suspend"

	<category: 'private'>
	^myList isNil
    ]

    isTerminated [
	"Answer whether the receiver has already terminated"

	<category: 'private'>
	^suspendedContext isNil
    ]

    isWaiting [
	"Answer whether the receiver is wating on a semaphore"

	<category: 'private'>
	^self isReady not & self isSuspended not
    ]

    singleStepWaitingOn: aSemaphore [
	"Execute a limited amount of code (usually a bytecode, or up to the
	 next backward jump, or up to the next message send) of the receiver,
	 which must in a ready-to-run state (neither executing nor terminating
	 nor suspended), then restart running the current process.  aSemaphore
	 is used as a means to synchronize the execution of the current process
	 and the receiver and should have no signals on it.  The current process
	 should have higher priority than the receiver."

	<category: 'builtins'>
	<primitive: VMpr_Process_singleStepWaitingOn>
	SystemExceptions.InvalidProcessState signalOn: self
    ]

    resume [
	"Resume the receiver's execution"

	<category: 'builtins'>
	<primitive: VMpr_Process_resume>
	SystemExceptions.ProcessTerminated signalOn: self
    ]

    yield [
	"Yield control from the receiver to other processes"

	<category: 'builtins'>
	<primitive: VMpr_Process_yield>
	
    ]

    detach [
        "Do nothing, instances of Process are already detached."

        <category: 'debugging'>
    ]
]

