"======================================================================
|
|   ProcessorScheduler Method Definitions
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1988,89,90,91,92,94,95,99,2000,2001,2002,2003
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


Object subclass: #ProcessorScheduler
       instanceVariableNames: 'processLists activeProcess idleTasks processTimeslice
			       gcSemaphore gcArray'
       classVariableNames: ''
       poolDictionaries: ''
       category: 'Language-Processes'
!

ProcessorScheduler comment: 
'I provide methods that control the execution of processes.' !


!ProcessorScheduler class methodsFor: 'instance creation'!
new
    "Error---new instances of ProcessorScheduler should not be created."

    self shouldNotImplement! !


!ProcessorScheduler methodsFor: 'basic'!

activeProcess
    "Answer the active process"
    ^activeProcess
!

activeDebugger
    "Answer the active process' debugger"
    ^self activeProcess debugger
!

activePriority
    "Answer the active process' priority"
    ^self activeProcess priority
!

changePriorityListOf: aProcess to: aPriority suspend: aBoolean
    "Private - Move aProcess to the execution list for aPriority,
     answer the new execution list"

    (processLists at: aProcess priority) remove: aProcess ifAbsent: [ ].
    ^aBoolean
	ifTrue: [ nil ]
	ifFalse: [ (processLists at: aPriority) addLast: aProcess; yourself ]
!

processesAt: aPriority
    "Answer a linked list of processes at the given priority"
    ^processLists at: aPriority
!

terminateActive
    "Terminate the active process"
    self activeProcess terminate
!

timeSlice: milliSeconds
    "Set the timeslice that is assigned to each Process before it is
     automatically preempted by the system.  Setting this to zero
     disables preemptive multitasking.  Note that the system by
     default is compiled with preemptive multitasking disabled, and
     that even if it is enabled it will surely work only under BSD
     derivatives (or, in general, systems that support ITIMER_VIRTUAL)."
    processTimeslice := milliSeconds
!

timeSlice
    "Answer the timeslice that is assigned to each Process before it
     is automatically preempted by the system (in milliseconds).  An
     answer of zero means that preemptive multitasking is disabled.
     Note that the system by default is compiled without preemptive
     multitasking, and that even if it is enabled it will work only
     under BSD derivatives (or, in general, systems that support
     ITIMER_VIRTUAL)."
    ^processTimeslice
!

yield
    "Let the active process yield control to other processes"
    self activeProcess yield
! !


!ProcessorScheduler methodsFor: 'priorities'!

priorityName: priority
    "Private - Answer a name for the given process priority"
    ^#('rockBottomPriority' 'systemBackgroundPriority' 'userBackgroundPriority'
       'userSchedulingPriority' 'userInterruptPriority' 'lowIOPriority'
       'highIOPriority' 'timingPriority' 'unpreemptedPriority') at: priority
!

highestPriority
    "Answer the highest valid priority"
    ^processLists size
!

unpreemptedPriority
    "Answer the highest priority avilable in the system; never
     create a process with this priority, instead use
     BlockClosure>>#valueWithoutPreemption."
    ^9
!

timingPriority
    "Answer the priority for system real-time processes."
    ^8
!

highIOPriority
    "Answer the priority for system high-priority I/O processes,
    such as a process handling input from a network."
    ^7
!

lowIOPriority
    "Answer the priority for system low-priority I/O processes.
    Examples are the process handling input from the user (keyboard, 
    pointing device, etc.) and the process distributing input from a
    network."
    ^6
!

userInterruptPriority
    "Answer the priority for user interrupt-priority processes.
    Processes run at this level will preempt the window scheduler
    and should, therefore, not consume the processor forever."
    ^5
!

userSchedulingPriority
    "Answer the priority for user standard-priority processes"
    ^4
!

userBackgroundPriority
    "Answer the priority for user background-priority processes"
    ^3
!

systemBackgroundPriority
    "Answer the priority for system background-priority processes.
    Examples are an incremental garbage collector or status checker."

    ^2
!

rockBottomPriority
    "Answer the lowest valid priority"
    ^1
!

lowestPriority
    "Answer the lowest valid priority"
    ^1
! !


!ProcessorScheduler methodsFor: 'idle tasks'!

idle
    "Private - Call the next idle task"
    | index |
    idleTasks size <= 1 ifTrue: [ ^self ].
    index := idleTasks at: 1.
    ObjectMemory incrementalGCStep.
    (idleTasks at: index + 2) value.
    idleTasks at: 1 put: (index + 1) \\ (idleTasks size - 1)
!

idleAdd: aBlock
    "Register aBlock to be executed when things are idle"
    idleTasks add: aBlock
!

initialize
    "Private - Start the finalization process."

    | finalizerProcess |
    idleTasks := OrderedCollection with: 0.
    ObjectMemory addDependent: self.
    finalizerProcess := [
        | local localFinalizerProcess |
	[
            gcSemaphore wait.
            local := gcArray.
            gcArray := nil.

	    "Fire a low-priority process to finalize the objects"
            localFinalizerProcess :=
		[ :array | array do: [ :each | each mourn ] ]
		    newProcessWith: { local }.

	    localFinalizerProcess name: 'finalization worker'.
	    localFinalizerProcess resume.
	] repeat.
    ] forkAt: Processor timingPriority.
    finalizerProcess name: 'finalization listener'.
!

update: aSymbol
    "If we left some work behind when the image was saved,
     do it now."

    aSymbol == #returnFromSnapshot ifFalse: [ ^self ].
    gcArray isNil ifFalse: [ gcSemaphore signal ].
! !


!ProcessorScheduler methodsFor: 'printing'!

printOn: aStream
    "Store onto aStream a printed representation of the receiver"
    aStream nextPutAll: 'Processor'
! !


!ProcessorScheduler methodsFor: 'storing'!

storeOn: aStream
    "Store onto aStream a Smalltalk expression which evaluates to the receiver"
    aStream nextPutAll: 'Processor'
! !


!ProcessorScheduler methodsFor: 'built ins'!

disableInterrupts
   "Disable interrupts caused by external events while the
    current process is executing.  Note that interrupts are
    disabled on a per-process basis, and that calling
    #disableInterrupts twice requires calling #enableInterrupts
    twice as well to re-enable interrupts."
   <primitive: VMpr_Processor_disableInterrupts>
!

enableInterrupts
   "Re-enable interrupts caused by external events while the
    current process is executing.  By default, interrupts are
    enabled."
   <primitive: VMpr_Processor_enableInterrupts>
!


!ProcessorScheduler methodsFor: 'timed invocation'!

isTimeoutProgrammed
    "Private - Answer whether there is a pending call to
    #signal:atMilliseconds:"
    <primitive: VMpr_Processor_isTimeoutProgrammed>
!

signal: aSemaphore atMilliseconds: millis
    "Private - signal 'aSemaphore' after 'millis' milliseconds have elapsed"
    <primitive: VMpr_Processor_signalAtMilliseconds>
    ^self primitiveFailed
!

signal: aSemaphore onInterrupt: anIntegerSignalNumber
    "Private - signal 'aSemaphore' when the given C signal occurs"
    <primitive: VMpr_Processor_signalOnInterrupt>
    ^self primitiveFailed
! !


