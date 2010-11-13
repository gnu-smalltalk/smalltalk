"======================================================================
|
|   Semaphore Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2002,2008,2009
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



LinkedList subclass: Semaphore [
    | signals name |
    
    <category: 'Language-Processes'>
    <comment: 'My instances represent counting semaphores.  I provide methods for signalling
the semaphore''s availability, and methods for waiting for its availability.
I also provide some methods for implementing critical sections.'>

    Semaphore class >> new [
	"Answer a new semaphore"

	<category: 'instance creation'>
	^self basicNew initialize
    ]

    Semaphore class >> forMutualExclusion [
	"Answer a new semaphore with a signal on it. These semaphores are a useful
	 shortcut when you use semaphores as critical sections."

	<category: 'instance creation'>
	^(self new)
	    signal;
	    yourself
    ]

    critical: aBlock [
	"Wait for the receiver to be free, execute aBlock and signal the receiver
	 again. Return the result of evaluating aBlock."

	"Look out for race conditions!"

	<category: 'mutual exclusion'>
	| ownedSem c |
	^[
	    "With a little help from the VM we can easily ascertain
             whether we did get a signal.  It is still necessary to
             trap process termination however, because if we did
             simply `ownedSem := self wait' we might be terminated
             after the wait has ended, and yet before the variable
             is assigned.  Pushing self and sending #wait is atomic
             thanks to superoperators."
            c := #(nil).
            ownedSem := [c := thisContext. self wait]
                on: ProcessBeingTerminated
                do: [:ex | ownedSem := c at: 1. ex pass].
            ownedSem == self ifTrue: [aBlock value]]
		ensure: [ownedSem == self ifTrue: [self signal]]
    ]

    name [
	"Answer a user-friendly name for the receiver"

	<category: 'accessing'>
	^name
    ]

    name: aString [
	"Answer a user-friendly name for the receiver"

	<category: 'accessing'>
	name := aString
    ]

    waitingProcesses [
	"Answer an Array of processes currently waiting on the receiver."

	<category: 'accessing'>
	^self asArray
    ]

    wouldBlock [
	"Answer whether waiting on the receiver would suspend the current process."

	<category: 'accessing'>
	^signals <= 0
    ]

    printOn: aStream [
	"Print a human-readable represention of the receiver on aStream."

	<category: 'printing'>
	aStream
	    nextPutAll: self class name;
	    nextPutAll: '(%1: %<free|held>2, %3 %<available signals|waiting processes>2)' 
			% 
			    {self name printString.
			    self signals > 0.
			    self signals abs}
    ]

    initialize [
	<category: 'private'>
	signals := 0
    ]

    signals [
	"Answer the number of processes that can be accomodated or (if negative
	 the number of waiting processes."

	"If <= 0 the value of signals does not have a relationship to the number
	 of waiting processes (currently it never goes at all below zero). So
	 - if 0 and 0 processes are waiting, the signal count is 0
	 - if 0 and k processes are waiting, the signal count is -k
	 - if >0, no processes must be waiting and the signal count is signals"

	<category: 'private'>
	^(signals max: 0) - self size
    ]

    notify [
	"Resume one of the processes that were waiting on the semaphore if
	 there were any.  Do not leave a signal on the semaphore if no
	 process is waiting."

	<category: 'builtins'>
	<primitive: VMpr_Semaphore_notify>
	^self primitiveFailed
    ]

    notifyAll [
	"Resume all the processes that were waiting on the semaphore if there
	 were any.  Do not leave a signal on the semaphore if no process is
	 waiting."

	<category: 'builtins'>
	<primitive: VMpr_Semaphore_notifyAll>
	^self primitiveFailed
    ]

    signal [
	"Signal the receiver, resuming a waiting process' if there is one"

	<category: 'builtins'>
	<primitive: VMpr_Semaphore_signal>
	^self primitiveFailed
    ]

    wait [
	"Wait for the receiver to be signalled, suspending the executing process
	 if it is not yet.  Return nil if the wait was interrupted, the
         receiver otherwise."

	<category: 'builtins'>
	<primitive: VMpr_Semaphore_wait>
	^self primitiveFailed
    ]

    waitAfterSignalling: aSemaphore [
	"Signal aSemaphore then, atomically, wait for the receiver to be
	 signalled, suspending the executing process if it is not yet.  This
	 is needed to avoid race conditions when the #notify and #notifyAll
	 are used before waiting on receiver: otherwise, if a process sends
	 any of the two between the time aSemaphore is signaled and the time
	 the process starts waiting on the receiver, the notification is lost."

	<category: 'builtins'>
	<primitive: VMpr_Semaphore_waitAfterSignalling>
	^self primitiveFailed
    ]

    lock [
	"Without putting the receiver to sleep, force processes that try to wait
	 on the semaphore to block.  Answer whether this was the case even before."

	<category: 'builtins'>
	<primitive: VMpr_Semaphore_lock>
	^self primitiveFailed
    ]
]

