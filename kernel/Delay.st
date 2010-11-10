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
    | resumptionTime delayDuration delaySemaphore |
    
    <category: 'Kernel-Processes'>
    <comment: 'I am the ultimate agent for frustration in the world.  I cause things to wait 
(sometimes much more than is appropriate, but it is those losing operating
systems'' fault).  When a process sends one of my instances a wait message,
that process goes to sleep for the interval specified when the instance was
created.'>

    MutexSem := nil.
    ActiveDelay := nil.
    DelayRequestor := nil.
    Queue := nil.
    DelayProcess := nil.
    IdleProcess := nil.
    TimeoutSem := nil.

    Delay class >> forMilliseconds: millisecondCount [
        "Answer a Delay waiting for millisecondCount milliseconds"

        <category: 'instance creation'>
        ^self new initForMilliseconds: millisecondCount
    ]

    Delay class >> forSeconds: secondCount [
        "Answer a Delay waiting for secondCount seconds"

        <category: 'instance creation'>
        ^self forMilliseconds: secondCount * 1000
    ]

    Delay class >> untilMilliseconds: millisecondCount [
        "Answer a Delay waiting for millisecondCount milliseconds after startup"

        <category: 'instance creation'>
        ^self new initUntilMilliseconds: millisecondCount
    ]

    Delay class >> handleDelayRequestor [
	"Handle a timer event; which can be either:
	 - a schedule or unschedule request (DelayRequestor notNil)
	 - a timer signal (not explicitly specified)
	 We check for timer expiry every time we get a signal."

	<category: 'timer process'>

	| nextTick |

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
	[ActiveDelay notNil and: [Time millisecondClockValue >= ActiveDelay resumptionTime]] 
	    whileTrue: 
		[ActiveDelay signal.
		self unscheduleDelay: ActiveDelay].

	"Since we have processed all outstanding requests, reset the timing semaphore so
	 that only new work will wake us up again. Do this RIGHT BEFORE setting the next
	 wakeup call from the VM because it is only signaled once so we mustn't miss it."
	TimeoutSem initialize.

	"And signal when the next request is due."
	ActiveDelay isNil ifFalse: [
	    nextTick := ActiveDelay resumptionTime - Time millisecondClockValue.
	    Processor signal: TimeoutSem atMilliseconds: nextTick].
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
	ActiveDelay isNil
	    ifTrue: [ActiveDelay := aDelay]
	    ifFalse: 
		[aDelay resumptionTime < ActiveDelay resumptionTime 
		    ifTrue: 
			[Queue add: ActiveDelay.
			ActiveDelay := aDelay]
		    ifFalse: [Queue add: aDelay]]
    ]

    Delay class >> unscheduleDelay: aDelay [
	"Private. Unschedule this Delay.  Run in the timer process, which
	 is the only one that manipulates Queue."

	<category: 'timer process'>
	aDelay reset.
	ActiveDelay == aDelay 
	    ifTrue: 
		[Queue isEmpty 
		    ifTrue: [ActiveDelay := nil]
		    ifFalse: [ActiveDelay := Queue removeFirst]]
	    ifFalse: [Queue remove: aDelay ifAbsent: []].
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
		    sortBlock: [:d1 :d2 | d1 resumptionTime <= d2 resumptionTime].
	TimeoutSem := Semaphore new.
	DelayProcess := [self runDelayProcess] forkAt: Processor timingPriority.
	TimeoutSem signal	"get going"
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
        | sema |
        sema := delaySemaphore.
        delaySemaphore := nil.
        sema isNil ifFalse: [sema signal].
    ]

    isActive [
        "Answer whether this Delay is being waited on."
	<category: 'testing'>
        ^delaySemaphore notNil
    ]

    wait [
	"Schedule this Delay and wait on it. The current process will be
	 suspended for the amount of time specified when this Delay was created."

	<category: 'delaying'>
        self isActive ifTrue: [self error: 'delay already in use'].
	[delaySemaphore := Semaphore new.
	resumptionTime isNil
	    ifTrue: [ resumptionTime := Time millisecondClockValue + delayDuration ].
        self notifyChange.

        "This can already signal the semaphore!"
        delaySemaphore == nil ifFalse: [delaySemaphore wait]] ensure: [
            self isActive ifTrue: [delaySemaphore := nil. self notifyChange]]

        "#reset will have been called by #unscheduleDelay:, either through
         the second call to #notifyChange, or because the timeout fired."
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

    delayDuration [
	"Answer the time I have left to wait, in milliseconds."
	<category: 'accessing'>
	^resumptionTime isNil
	    ifTrue: [ delayDuration ]
	    ifFalse: [ (resumptionTime - Time millisecondClockValue) max: 0 ]
    ]

    basicDelayDuration [
	<category: 'private'>
	^delayDuration
    ]

    initForMilliseconds: value [
        "Initialize a Delay waiting for millisecondCount milliseconds"

        <category: 'initialization'>
        delayDuration := value
    ]

    initUntilMilliseconds: value [
        "Initialize a Delay waiting for millisecondCount milliseconds after startup"

        <category: 'instance creation'>
        resumptionTime := value.
    ]

]


Eval [
    Delay initialize
]
