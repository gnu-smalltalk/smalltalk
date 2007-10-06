"======================================================================
|
|   Delay Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2002
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
    | resumptionTime isRelative |
    
    <category: 'Language-Processes'>
    <comment: 'I am the ultimate agent for frustration in the world.  I cause things to wait 
(sometimes much more than is appropriate, but it is those losing operating
systems'' fault).  When a process sends one of my instances a wait message,
that process goes to sleep for the interval specified when the instance was
created.'>

    Queue := nil.
    TimeoutSem := nil.
    MutexSem := nil.
    DelayProcess := nil.
    IdleProcess := nil.

    Delay class >> forMilliseconds: millisecondCount [
	"Answer a Delay waiting for millisecondCount milliseconds"

	<category: 'instance creation'>
	^self new init: millisecondCount isRelative: true
    ]

    Delay class >> forSeconds: secondCount [
	"Answer a Delay waiting for secondCount seconds"

	<category: 'instance creation'>
	^self forMilliseconds: secondCount * 1000
    ]

    Delay class >> untilMilliseconds: millisecondCount [
	"Answer a Delay waiting for millisecondCount milliseconds after midnight"

	<category: 'instance creation'>
	^self new init: millisecondCount isRelative: false
    ]

    Delay class >> millisecondClockValue [
	"Private - Answer the number of milliseconds since midnight"

	<category: 'general inquiries'>
	^Time primMillisecondClock
    ]

    Delay class >> initialize [
	"Private - Initialize the receiver and the associated process"

	"'initalizing Delays' printNl."

	<category: 'initialization'>
	| queue |
	Queue := SharedQueue sortBlock: [:a :b | a key <= b key].
	MutexSem := Semaphore forMutualExclusion.
	TimeoutSem := Semaphore new.
	IdleProcess := [
		[Processor
		    idle;
		    yield] repeat] 
		    forkAt: Processor systemBackgroundPriority.
	IdleProcess name: 'idle'.
	Delay startDelayLoop
    ]

    Delay class >> startDelayLoop [
	"Private - Start the processes for Delays"

	<category: 'private'>
	DelayProcess := 
		[
		[TimeoutSem wait.
		MutexSem critical: 
			[Queue next value signal.
			Queue isEmpty ifFalse: [self timeout: Queue peek key]]] 
			repeat] 
			forkAt: Processor timingPriority.
	DelayProcess name: 'timeout'
    ]

    Delay class >> timeout: milliseconds [
	"Private - Signal the TimeoutSem after the given number of milliseconds.
	 Delays across midnight are gracefully handled."

	<category: 'private'>
	| resumeMillis |
	resumeMillis := milliseconds - Delay millisecondClockValue.
	resumeMillis <= 0 
	    ifTrue: 
		[TimeoutSem signal.
		^self].
	resumeMillis := (resumeMillis \\ Time millisecondsPerDay) asInteger.
	Processor signal: TimeoutSem atMilliseconds: resumeMillis
    ]

    resumptionTime [
	"Answer the time when a process waiting on a Delay will resume"

	<category: 'accessing'>
	isRelative 
	    ifTrue: [^Delay millisecondClockValue + resumptionTime]
	    ifFalse: [^resumptionTime]
    ]

    wait [
	"Wait until the amount of time represented by the instance of Delay
	 elapses"

	<category: 'process delay'>
	| elt sem |
	sem := Semaphore new.
	elt := Association key: self resumptionTime value: sem.
	MutexSem critical: 
		[Queue nextPut: elt.
		"If we've become the head of the list, we need to
		 alter the interrupt time"
		Queue peek == elt ifTrue: [Delay timeout: elt key]].
	sem wait
    ]

    = aDelay [
	"Answer whether the receiver and aDelay denote the same delay"

	<category: 'comparing'>
	self class == aDelay class ifFalse: [^false].
	^isRelative = aDelay isRelative 
	    and: [resumptionTime = aDelay basicResumptionTime]
    ]

    hash [
	"Answer an hash value for the receiver"

	<category: 'comparing'>
	^resumptionTime
    ]

    basicResumptionTime [
	<category: 'private'>
	^resumptionTime
    ]

    init: milliseconds isRelative: aBoolean [
	<category: 'private'>
	isRelative := aBoolean.
	resumptionTime := milliseconds
    ]

    isRelative [
	<category: 'private'>
	^isRelative
    ]
]

