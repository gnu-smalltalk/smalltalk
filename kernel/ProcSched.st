"======================================================================
|
|   ProcessorScheduler Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1988,89,90,91,92,94,95,99,2000,2001,2002,2003,2008,2009
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



Object subclass: ProcessorScheduler [
    | processLists activeProcess idleTasks processTimeslice gcSemaphore gcArray
      eventSemaphore |
    
    <category: 'Language-Processes'>
    <comment: 'I provide methods that control the execution of processes.'>

    ProcessorScheduler class >> new [
	"Error---new instances of ProcessorScheduler should not be created."

	<category: 'instance creation'>
	self shouldNotImplement
    ]

    processEnvironment [
	"Answer another singleton object hosting thread-local variables
	 for the Smalltalk processes.  This acts like a normal Dictionary
	 with a couple of differences: a) using #associationAt: will
	 return special associations that retrieve a thread-local value;
	 b) requesting missing keys will return nil, and removing them
	 will be a nop."

	<category: 'basic'>
	^ProcessEnvironment uniqueInstance
    ]

    activeProcess [
	"Answer the active process"

	<category: 'basic'>
	^activeProcess
    ]

    activeDebugger [
	"Answer the active process' debugger"

	<category: 'basic'>
	^self activeProcess debugger
    ]

    activePriority [
	"Answer the active process' priority"

	<category: 'basic'>
	^self activeProcess priority
    ]

    processesAt: aPriority [
	"Answer a linked list of processes at the given priority"

	<category: 'basic'>
	^processLists at: aPriority
    ]

    terminateActive [
	"Terminate the active process"

	<category: 'basic'>
	self activeProcess terminate
    ]

    timeSlice: milliSeconds [
	"Set the timeslice that is assigned to each Process before it is
	 automatically preempted by the system.  Setting this to zero
	 disables preemptive multitasking.  Note that the system by
	 default is compiled with preemptive multitasking disabled, and
	 that even if it is enabled it will surely work only under BSD
	 derivatives (or, in general, systems that support ITIMER_VIRTUAL)."

	<category: 'basic'>
	processTimeslice := milliSeconds
    ]

    timeSlice [
	"Answer the timeslice that is assigned to each Process before it
	 is automatically preempted by the system (in milliseconds).  An
	 answer of zero means that preemptive multitasking is disabled.
	 Note that the system by default is compiled without preemptive
	 multitasking, and that even if it is enabled it will work only
	 under BSD derivatives (or, in general, systems that support
	 ITIMER_VIRTUAL)."

	<category: 'basic'>
	^processTimeslice
    ]

    yield [
	"Let the active process yield control to other processes"

	<category: 'basic'>
	self activeProcess yield
    ]

    priorityName: priority [
	"Private - Answer a name for the given process priority"

	<category: 'priorities'>
	^#('idlePriority' 'systemBackgroundPriority' 'userBackgroundPriority' 'userSchedulingPriority' 'userInterruptPriority' 'lowIOPriority' 'highIOPriority' 'timingPriority' 'unpreemptedPriority') 
	    at: priority
    ]

    highestPriority [
	"Answer the highest valid priority"

	<category: 'priorities'>
	^processLists size
    ]

    unpreemptedPriority [
	"Answer the highest priority avilable in the system; never
	 create a process with this priority, instead use
	 BlockClosure>>#valueWithoutPreemption."

	<category: 'priorities'>
	^9
    ]

    timingPriority [
	"Answer the priority for system real-time processes."

	<category: 'priorities'>
	^8
    ]

    highIOPriority [
	"Answer the priority for system high-priority I/O processes,
	 such as a process handling input from a network."

	<category: 'priorities'>
	^7
    ]

    lowIOPriority [
	"Answer the priority for system low-priority I/O processes.
	 Examples are the process handling input from the user (keyboard,
	 pointing device, etc.) and the process distributing input from a
	 network."

	<category: 'priorities'>
	^6
    ]

    userInterruptPriority [
	"Answer the priority for user interrupt-priority processes.
	 Processes run at this level will preempt the window scheduler
	 and should, therefore, not consume the processor forever."

	<category: 'priorities'>
	^5
    ]

    userSchedulingPriority [
	"Answer the priority for user standard-priority processes"

	<category: 'priorities'>
	^4
    ]

    userBackgroundPriority [
	"Answer the priority for user background-priority processes"

	<category: 'priorities'>
	^3
    ]

    systemBackgroundPriority [
	"Answer the priority for system background-priority processes.  An
	 incremental garbage collector could run at this level but now
	 it runs at idlePriority instead."

	<category: 'priorities'>
	^2
    ]

    idlePriority [
	"Answer the priority of idle processes."

	<category: 'priorities'>
	^1
    ]

    lowestPriority [
	"Answer the lowest valid priority"

	<category: 'priorities'>
	^1
    ]

    pause: aBoolean [
	"Private - Pause for some time if aBoolean is false, or until a signal
	 if it is true."

	<category: 'idle tasks'>
	<primitive: VMpr_Processor_pause>
    ]

    dispatchEvents [
	"Private - Main body of the event loop."

	<category: 'idle tasks'>
	<primitive: VMpr_Processor_dispatchEvents>
    ]

    forkEventLoop [
        eventSemaphore isNil ifTrue: [^self].
        eventSemaphore := Semaphore new.
        ^[[Processor dispatchEvents] repeat] newProcess
            priority: Processor userSchedulingPriority;
            name: 'event dispatcher';
            resume;
            yourself
    ]

    idle [
	"Private - Call the next idle task.  Return whether GNU Smalltalk
	 should pause until the next OS signal."

	<category: 'idle tasks'>
	| gcDone index |
	gcDone := ObjectMemory incrementalGCStep.
	idleTasks size <= 1 ifTrue: [ ^gcDone ].

	index := idleTasks at: 1.
	(idleTasks at: index + 2) value.
	idleTasks at: 1 put: (index + 1) \\ (idleTasks size - 1).
	^false
    ]

    idleAdd: aBlock [
	"Register aBlock to be executed when things are idle"

	<category: 'idle tasks'>
	idleTasks add: aBlock
    ]

    startFinalizers [
	"Private - Fire a low-priority process to finalize the objects"
	<category: 'idle tasks'>
	| local localFinalizerProcess |
	local := gcArray.
	gcArray := nil.

	localFinalizerProcess := [:array | array do: [:each | each mourn]] 
		    newProcessWith: {local}.
	localFinalizerProcess priority: Processor userSchedulingPriority.
	localFinalizerProcess name: 'finalization worker'.
	localFinalizerProcess resume
    ]

    initialize [
	"Private - Start the finalization process."

	<category: 'idle tasks'>
	| finalizerProcess |
	idleTasks := OrderedCollection with: 0.
	gcSemaphore := Semaphore new.
	eventSemaphore := Semaphore new.
	ObjectMemory addDependent: self.
	finalizerProcess := 
		[[gcSemaphore wait.  self startFinalizers] repeat]
			forkAt: Processor timingPriority.
	finalizerProcess name: 'finalization listener'
    ]

    update: aSymbol [
	"If we left some work behind when the image was saved,
	 do it now."

	<category: 'idle tasks'>
	aSymbol == #returnFromSnapshot ifFalse: [^self].
	gcArray isNil ifFalse: [self startFinalizers]
    ]

    printOn: aStream [
	"Store onto aStream a printed representation of the receiver"

	<category: 'printing'>
	aStream nextPutAll: 'Processor'
    ]

    storeOn: aStream [
	"Store onto aStream a Smalltalk expression which evaluates to the receiver"

	<category: 'storing'>
	aStream nextPutAll: 'Processor'
    ]

    disableInterrupts [
	"Disable interrupts caused by external events while the
	 current process is executing.  Note that interrupts are
	 disabled on a per-process basis, and that calling
	 #disableInterrupts twice requires calling #enableInterrupts
	 twice as well to re-enable interrupts."

	<category: 'built ins'>
	<primitive: VMpr_Processor_disableInterrupts>
	
    ]

    enableInterrupts [
	"Re-enable interrupts caused by external events while the
	 current process is executing.  By default, interrupts are
	 enabled."

	<category: 'built ins'>
	<primitive: VMpr_Processor_enableInterrupts>
	
    ]

    isTimeoutProgrammed [
	"Private - Answer whether there is a pending call to
	 #signal:atMilliseconds:"

	<category: 'timed invocation'>
	<primitive: VMpr_Processor_isTimeoutProgrammed>
	
    ]

    signal: aSemaphore atNanosecondClockValue: ns [
	"Private - signal 'aSemaphore' when the nanosecond clock reaches
         'ns' nanoseconds."

	<category: 'timed invocation'>
	<primitive: VMpr_Processor_signalAtNanosecondClockValue>
	^self primitiveFailed
    ]

    signal: aSemaphore onInterrupt: anIntegerSignalNumber [
	"Signal 'aSemaphore' when the given C signal occurs."

	<category: 'timed invocation'>
	<primitive: VMpr_Processor_signalOnInterrupt>
	^self primitiveFailed
    ]
]

