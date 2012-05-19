"======================================================================
|
|   Delay Method Definitions
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2002,2007,2008,2009
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


Object subclass: Delay [
    | resumptionTime delayDuration delaySemaphore waitingProcess |
    
    <category: 'Kernel-Processes'>
    <comment: 'I am the ultimate agent for frustration in the world.  I cause things to wait 
(sometimes much more than is appropriate, but it is those losing operating
systems'' fault).  When a process sends one of my instances a wait message,
that process goes to sleep for the interval specified when the instance was
created.'>

    MutexSem := nil.
    DelayRequestor := nil.
    Queue := nil.
    DelayProcess := nil.
    IdleProcess := nil.
    TimeoutSem := nil.

    Delay class >> forNanoseconds: nanosecondCount [
        "Answer a Delay waiting for nanosecondCount nanoseconds"

        <category: 'instance creation'>
        ^self new initForNanoseconds: nanosecondCount
    ]

    Delay class >> forMilliseconds: millisecondCount [
        "Answer a Delay waiting for millisecondCount milliseconds"

        <category: 'instance creation'>
        ^self forNanoseconds: millisecondCount * 1000000
    ]

    Delay class >> forSeconds: secondCount [
        "Answer a Delay waiting for secondCount seconds"

        <category: 'instance creation'>
        ^self forNanoseconds: secondCount * 1000000000
    ]

    Delay class >> untilNanoseconds: nanosecondCount [
        "Answer a Delay waiting until nanosecondCount nanoseconds after startup"

        <category: 'instance creation'>
        ^self new initUntilNanoseconds: nanosecondCount
    ]

    Delay class >> untilMilliseconds: millisecondCount [
        "Answer a Delay waiting until millisecondCount milliseconds after startup"

        <category: 'instance creation'>
        ^self untilMilliseconds: millisecondCount * 1000000
    ]

    Delay class >> activeDelay [
        "Return the delay at the head of the queue."
	<category: 'timer process'>

        Queue isEmpty ifTrue: [^nil].
        ^Queue last
    ]

    Delay class >> handleDelayRequestor [
	"Handle a timer event; which can be either:
	 - a schedule or unschedule request (DelayRequestor notNil)
	 - a timer signal (not explicitly specified)
	 We check for timer expiry every time we get a signal."

	<category: 'timer process'>

	| nextTick activeDelay |

	"Wait until there is work to do."
	TimeoutSem wait.

	"Process any schedule/unschedule requests"
	DelayRequestor isNil ifFalse: 
		["Schedule the given delay"
		DelayRequestor isActive
		    ifTrue: [ self scheduleDelay: DelayRequestor ]
		    ifFalse: [ self unscheduleDelay: DelayRequestor ].
		DelayRequestor := nil].

	"Signal any expired delays"
	[activeDelay := self activeDelay.
        activeDelay notNil and: [Time nanosecondClockValue >= activeDelay resumptionTime]] 
	    whileTrue: 
		[activeDelay signal.
		self unscheduleDelay: activeDelay].

	"Since we have processed all outstanding requests, reset the timing semaphore so
	 that only new work will wake us up again. Do this RIGHT BEFORE setting the next
	 wakeup call from the VM because it is only signaled once so we mustn't miss it."
	TimeoutSem initialize.

	"And signal when the next request is due."
        activeDelay isNil ifFalse: [
	    nextTick := activeDelay resumptionTime + Time.ClockOnStartup.
	    Processor signal: TimeoutSem atNanosecondClockValue: nextTick].
    ]

    Delay class >> runDelayProcess [
	"Run the timer event loop."

	<category: 'timer process'>
	[[self handleDelayRequestor] repeat]
	    ifCurtailed: 
		[DelayProcess := nil.
		Delay startDelayLoop]
    ]

    Delay class >> scheduleDelay: aDelay [
	"Private - Schedule this Delay.  Run in the timer process, which
	 is the only one that manipulates Queue."

	<category: 'timer process'>
	Queue add: aDelay
    ]

    Delay class >> unscheduleDelay: aDelay [
	"Private - Unschedule this Delay.  Run in the timer process, which
	 is the only one that manipulates Queue."

	<category: 'timer process'>
        | activeDelay |
	activeDelay := self activeDelay.
	activeDelay isNil ifTrue: [^self].
	activeDelay == aDelay
	    ifTrue: [Queue removeLast]
	    ifFalse: [Queue identityRemove: aDelay ifAbsent: []].
	aDelay reset.
    ]

    Delay class >> startDelayLoop [
	"Start the timer event loop."

	"Delay startDelayLoop"

	<category: 'timer process'>
	DelayProcess isNil ifFalse: [ DelayProcess terminate ].

	"This semaphore does not protect Queue (which is only manipulated within
	 one process for thread-safety, but rather DelayRequestor)."
	MutexSem := Semaphore forMutualExclusion.
	DelayRequestor := nil.

	"A sorted collection of delay->semaphore associations."
	Queue := SortedCollection
		    sortBlock: [:d1 :d2 | d1 resumptionTime >= d2 resumptionTime].
	TimeoutSem := Semaphore new.
	DelayProcess := [self runDelayProcess] forkAt: Processor timingPriority.
        ObjectMemory addDependent: self.
        self update: #returnFromSnapshot
    ]

    Delay class >> update: aspect [
	"Prime the timer event loop when the image starts running."
	aspect == #returnFromSnapshot ifTrue: [TimeoutSem signal]
    ]

    Delay class >> initialize [
	<category: 'private-class initialization'>
        IdleProcess := [[Processor pause: Processor idle] repeat]
                    forkAt: Processor idlePriority.
        IdleProcess name: 'idle'.
	self startDelayLoop
    ]

    = aDelay [
        "Answer whether the receiver and aDelay denote the same delay"

        <category: 'comparing'>
        self class == aDelay class ifFalse: [^false].
	^delayDuration isNil
            ifFalse: [delayDuration = aDelay basicDelayDuration]
	    ifTrue: [resumptionTime = aDelay resumptionTime]
    ]

    hash [
        "Answer an hash value for the receiver"

        <category: 'comparing'>
        ^resumptionTime hash bitXor: delayDuration hash
    ]

    notifyChange [
	"Private - Notify the Delay process of a change in the active/inactive
         state of this Delay.  Return immediately."

	<category: 'private'>
	MutexSem critical: 
		[DelayRequestor := self.
		TimeoutSem signal].
    ]

    signal [
        "Wake the process that is waiting on this delay."
	<category: 'private'>
        | sema process |
        waitingProcess isNil
            ifTrue: [
	        sema := delaySemaphore.
	        delaySemaphore := nil.
                sema isNil ifFalse: [sema signal]]
            ifFalse: [
                process := waitingProcess.
                waitingProcess := nil.
                process isNil ifFalse: [process suspend; resume]].
    ]

    isActive [
        "Answer whether this Delay is being waited on."
	<category: 'testing'>
        ^delaySemaphore notNil or: [waitingProcess notNil]
    ]

    timedWaitOn: aSemaphore [
	"Schedule this Delay and wait on it. The current process will be
	 suspended for the amount of time specified when this Delay was created,
         or until aSemaphore is signaled."

	<category: 'delaying'>
        | expired |
        self isActive ifTrue: [self error: 'delay already in use'].
	[self start.
        waitingProcess := Processor activeProcess.
        self notifyChange.

        "This can already signal the semaphore!"
        waitingProcess == nil ifFalse: [expired := aSemaphore wait]] ensure: [
            waitingProcess == nil ifFalse: [waitingProcess := nil. self notifyChange]].

        "#reset will have been called by #unscheduleDelay:, either through
         the second call to #notifyChange, or because the timeout fired.
         If the suspend/resume pair in #signal was executed, expired will
         be nil, otherwise it will be the semaphore.  This is guaranteed
         by the VM.  Use this fact to return the correct value."
        ^expired == nil
    ]

    wait [
	"Schedule this Delay and wait on it. The current process will be
	 suspended for the amount of time specified when this Delay was created."

	<category: 'delaying'>
        self isActive ifTrue: [self error: 'delay already in use'].
	[self start.
        delaySemaphore := Semaphore new.
        self notifyChange.

        "This can already signal the semaphore!"
        delaySemaphore == nil ifFalse: [delaySemaphore wait]] ensure: [
            delaySemaphore == nil ifFalse: [delaySemaphore := nil. self notifyChange]].

        "#reset will have been called by #unscheduleDelay:, either through
         the second call to #notifyChange, or because the timeout fired."
    ]

    value: aBlock onTimeoutDo: aTimeoutBlock [
        "Execute aBlock for up to the time of my own delay; in case the code
         did not finish abort the execution, unwind the block and then
         evaluate aTimeoutBlock."
        <category: 'timeout'>
        | value timeout |
        timeout := false.
        value := [ | sem proc |
            "Use the semaphore to signal that we executed everything"
            sem := Semaphore new.
            "Remember the current process"
            proc := Processor activeProcess.

            "Start a process to wait in and then signal"
            [
                "Wait and see if it is timed out. If so send a signal."
                (self timedWaitOn: sem) ifTrue: [
                   proc signalInterrupt: (Kernel.TimeoutNotification on: self).
                ].
            ] fork.

            aBlock ensure: [sem signal].
        ] on: Kernel.TimeoutNotification do: [:e |
            e delay = self
                ifTrue:  [timeout := true]
                ifFalse: [e pass].
        ].

        "Make sure we call the #ensure:/#ifCurtailed: blocks first."
        ^ timeout
            ifTrue:  [aTimeoutBlock value]
            ifFalse: [value].
    ]

    start [
        "Prepare to wait on the delay."
	<category: 'private'>
	resumptionTime isNil
	    ifTrue: [ resumptionTime := Time nanosecondClockValue + delayDuration ].
    ]

    reset [
        "Prepare to wait again on the delay."
	<category: 'private'>
	delayDuration isNil ifFalse: [resumptionTime := nil].
    ]

    resumptionTime [
	<category: 'accessing'>
	^resumptionTime
    ]

    isAbsolute [
	"Answer whether the receiver waits until an absolute time on the
         millisecond clock."
	<category: 'accessing'>
	^delayDuration isNil
    ]

    asAbsolute [
	"Answer a delay that waits until the current delay's resumptionTime,
         or delayDuration milliseconds from now if that would be nil.  May
         answer the receiver if it is already waiting until an absolute time."
	<category: 'accessing'>
	self isAbsolute ifTrue: [ ^self ].
        ^Delay untilNanoseconds: Time nanosecondClockValue + delayDuration.
    ]

    postCopy [
        "Adjust the current delay so that it behaves as if it had just been
         created."
	<category: 'copying'>
        self isAbsolute ifFalse: [ resumptionTime := nil ].
        delaySemaphore := nil.
        waitingProcess := nil
    ]

    delayDuration [
	"Answer the time I have left to wait, in milliseconds."
	<category: 'accessing'>
	^resumptionTime isNil
	    ifTrue: [ delayDuration ]
	    ifFalse: [ (resumptionTime - Time nanosecondClockValue) max: 0 ]
    ]

    basicDelayDuration [
	<category: 'private'>
	^delayDuration
    ]

    initForNanoseconds: value [
        "Initialize a Delay waiting for millisecondCount milliseconds"

        <category: 'initialization'>
        delayDuration := value
    ]

    initUntilNanoseconds: value [
        "Initialize a Delay waiting for millisecondCount milliseconds after startup"

        <category: 'instance creation'>
        resumptionTime := value.
    ]

]


Eval [
    Delay initialize
]
