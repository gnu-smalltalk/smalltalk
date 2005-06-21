"======================================================================
|
|   Sample synchronization primitives
|
|
 ======================================================================"


"======================================================================
|
| Copyright (C) 2002 Free Software Foundation, Inc.
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

Object subclass: #Monitor
	instanceVariableNames: 'semaphore process count waitSemaphores '
	classVariableNames: 'Mutex'
	poolDictionaries: ''
	category: 'Examples-Processes'!

Monitor comment: '
A monitor provides process synchronization that is more highlevel than the
one provided by a Semaphore.  It is equivalent to the facility provided
by the Java language.

1) At any time, only one process can be executing code inside a critical
section of a monitor.

2) A monitor is reentrant, which means that the active process in a monitor
does never get blocked when it enters a (nested) critical section of the
same monitor.

3) Inside a critcal section, a process can stop to wait for events.
The process leaves the monitor temporarily (in order to let other
processes enter) and waits until another process notifies the event.
Then, the original process checks if the event is the desired one and
continues if it is.

4) The monitor is fair, which means that the process that is waiting on a
notified condition the longest gets activated first.'!

Semaphore subclass: #ConditionVariable
       instanceVariableNames: 'set'
       classVariableNames: ''
       poolDictionaries: ''
       category: 'Examples-Processes'
!

ConditionVariable comment:
'A ConditionVariable allows Processes to suspend execution until some
predicate on shared data is satisfied. The basic operations on conditions
are: notify the condition (when the predicate becomes true), clear it,
and wait for the condition.'!

Object subclass: #Barrier
       instanceVariableNames: 'countdown sema'
       classVariableNames: ''
       poolDictionaries: ''
       category: 'Examples-Processes'
!

Barrier comment:
'A Barrier has a threshold t and stops the first t-1 processes that
sends it #wait; when the t-th process says it has reached the barrier
(by sending it #wait) all the suspended processes are restarted and
further waits will be no-ops.'!

RecursionLock subclass: #ReadWriteLock
       instanceVariableNames: 'readMutex readers readLocked'
       classVariableNames: ''
       poolDictionaries: ''
       category: 'Examples-Processes'
!

ReadWriteLock comment:
'A read-write lock can be locked in two modes, read-only (with #readLockDuring:)
and read-write (with #critical:).  When the lock is only locked by other threads
in read-only mode, a read-only lock will not block and a read-write locking
attempt will wait for all the read-only locks to be released.  Instead, when one
thread holds a read-write lock, all locking attempts will suspend the current
thread until this lock is released again.'!

Object subclass: #Watchdog
       instanceVariableNames: 'actionBlock relax ok delay'
       classVariableNames: ''
       poolDictionaries: ''
       category: 'Examples-Processes'
!

Watchdog comment:
'I am used to watch for system hangups.  Until #terminate is
sent to an instance of me, I periodically check if during the
time you sent #notify and, if you did not, I evaluate a
user-supplied action block.'!

!Monitor class methodsFor: 'initialization'!

initialize
    Mutex := Semaphore forMutualExclusion! !

!Monitor class methodsFor: 'private'!

delayProcessFor: mils semaphore: s
    ^[
        (Delay forMilliseconds: mils) wait.
        s signal.
	Processor activeProcess suspend ]!

!Monitor class methodsFor: 'instance creation'!

new
    ^super new initialize!

!Monitor methodsFor: 'initialize-release'!

initialize
    count := 0.
    semaphore := Semaphore forMutualExclusion! !

!Monitor methodsFor: 'private'!

checkOwnerProcess
    self isOwnerProcess
	ifFalse: [self error: 'Monitor access violation']!

enter
    | activeProcess |
    activeProcess := Processor activeProcess.
    process == activeProcess
	ifFalse: [
	    semaphore wait.
	    process := activeProcess ].
    count := count + 1!

exit
    Mutex wait.
    (count := count - 1) == 0
	ifTrue: [ process := nil. semaphore signal ].
    Mutex signal!

unlock
    | oldCount |
    oldCount := count.
    count := 0.
    process := nil.
    semaphore signal.
    ^oldCount!

lock: saveCount
    | activeProcess |
    activeProcess := Processor activeProcess.
    process == activeProcess
	ifFalse: [
	    semaphore wait.
	    process := activeProcess ].
    count := count + saveCount! !

!Monitor methodsFor: 'control'!

critical: aBlock
    self enter.
    ^aBlock ensure: [ self exit ]!

signal
    self checkOwnerProcess.
    Mutex wait.
    waitSemaphores isNil ifTrue: [ Mutex signal. ^self ].
    waitSemaphores isEmpty ifFalse: [ waitSemaphores removeFirst signal ].
    Mutex signal!

signalAll
    self checkOwnerProcess.
    Mutex wait.
    waitSemaphores isNil ifTrue: [ Mutex signal. ^self ].
    waitSemaphores size timesRepeat: [ waitSemaphores removeFirst signal ].
    Mutex signal!

wait
    ^self wait: 0!

wait: msec
    | count process sema |
    self checkOwnerProcess.
    sema := Semaphore new.

    "Grab the monitor, unlock it and register the semaphore we'll wait on.
     Note that we unlock the monitor *before* relinquishing the mutex."
    Mutex wait.
    count := self unlock.
    waitSemaphores isNil ifTrue: [ waitSemaphores := OrderedCollection new ].
    waitSemaphores addLast: sema.
    Mutex signal.

    "If there's a timeout, start a process to exit the wait anticipatedly."
    msec > 0 ifTrue: [
	process := (self class delayProcessFor: msec semaphore: sema) fork ].

    sema wait.

    "Also if there's a timeout, ensure that the semaphore is removed from
     the list.  If there's no timeout we do not even need to reacquire the
     monitor afterwards (see also #exit:, which waits after getting the
     monitor and relinquishing the mutex)."
    process notNil ifTrue: [
        Mutex wait.
        waitSemaphores remove: sema ifAbsent: [].
        process terminate.
        Mutex signal ].

    self lock: count! !

!ConditionVariable methodsFor: 'all'!

initialize
    super initialize.
    set := false
!

wait
    [
        set ifFalse: [ super wait ]
    ] valueWithoutPreemption
!

reset
    [
	set := false.
    ] valueWithoutPreemption
!

pulse
    [
        set ifFalse: [ self notifyAll ]
    ] valueWithoutPreemption
!

broadcast
    [
	| wasSet |
	wasSet := set.
	set := true.
	wasSet ifFalse: [ self notifyAll ].
    ] valueWithoutPreemption
!

signal
    [
	| wasSet |
	wasSet := set.
	set := true.
	wasSet ifFalse: [ self notify ].
    ] valueWithoutPreemption
! !


!Barrier class methodsFor: 'all'!

new: threshold
    ^self new initialize: threshold; yourself
!

!Barrier methodsFor: 'all'!

initialize: count
    countdown := count.
    sema := Semaphore new
!

wait
    countdown < 0 ifTrue: [ ^self ].
    countdown := countdown - 1.
    countdown = 0 ifTrue: [ sema notifyAll ] ifFalse: [ sema wait ].
! !


!ReadWriteLock methodsFor: 'all'!

initialize
    super initialize.
    readMutex := Semaphore forMutualExclusion.
    readers := 0.
    readLocked := false.
!

readLocked
    ^readLocked
!

readLockDuring: aBlock
    readMutex wait.
    readers := readers + 1.

    "If readers was already >= 1, we don't have to wait for the write-lock to be
     freed and this is substantially equivalent to
	readMutex signal.
	aBlock value.
	readMutex wait.
	readers = readers - 1.
	readMutex signal.

    Instead if readers was zero we have to get the write lock:
	<acquire the write lock>
	readLocked := true.
	readMutex signal.
	aBlock value
	readMutex wait.
	readers = readers - 1.
	readLocked := false.
	readMutex signal
	<release the write lock>

    Note that actually the release of the lock might happen in a different process
    than the one that acquired the lock!  That's the reason why readers is an
    instance variable."

    self critical: [
	readMutex signal.
	aBlock value
    ]
!

wait
    readers > 1 ifTrue: [ ^self ].
    super wait.
    readLocked := readers > 0
!

signal
    readLocked ifTrue: [
        readMutex wait.
        readers := readers - 1.
        readLocked := (readers > 0).
	readLocked ifTrue: [ readMutex signal. ^self ].
	readMutex signal.
    ].
    super signal
! !


!Watchdog class methodsFor: 'all'!

defaultMillisecondsWatchdogTime
   ^60000
!

new
    ^self basicNew initialize: self defaultMillisecondsWatchdogTime
!

forSeconds: n
    ^self basicNew initialize: n * 1000
!

forMilliseconds: n
    ^self basicNew initialize: n
!

do: aBlock
    ^self new actionBlock: aBlock; start
! !

!Watchdog methodsFor: 'all'!

initialize: msec
    relax := true.
    delay := Delay forMilliseconds: msec.
    ok := true.
    actionBlock := ValueHolder null. 	"Anything that answers #value will do"
!

terminate
    relax := true.
!

actionBlock: aBlock
    actionBlock := aBlock.
!

signal
    ok := true.
!

start
    relax := false.
    ok := false.
    [ [ delay wait. relax ] whileFalse: [
	 ok ifFalse: [ actionBlock value ].
	 ok := false.
    ] ] forkAt: Processor lowIOPriority.
! !

Monitor initialize!
