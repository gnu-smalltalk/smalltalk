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
| Foundation, 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.  
|
 ======================================================================"

RecursionLock subclass: #Monitor
	instanceVariableNames: 'defaultLock lockDict '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Kernel-Processes'!

Monitor comment: '
A monitor provides process synchronization that is more highlevel than the
one provided by a Semaphore. Similar to the classical definition of a
Monitor, and an extension of the facility provided by the Java
language it has the following properties:

1) At any time, only one process can be executing code inside a critical
section of a monitor.

2) A monitor is reentrant, which means that the active process in a monitor
does never get blocked when it enters a (nested) critical section of the
same monitor.

3) Inside a critcal section, a process can wait for an event that maybe
coupled to a certain condition. If the condition is not fulfilled, the
process leaves the monitor temporarily (in order to let other processes
enter) and waits until another process notifys the event. Then, the 
original process checks the condition again (this often necessary because
the state of the monitor could have changed in the meantime) and continues 
if it is fulfilled.

4) The monitor is fair, which means that the process that is waiting on a
notifyed condition the longest gets activated first.'!

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


!Monitor methodsFor: 'waiting-specific'!

waitFor: aSymbolOrNil
    "Unconditional waiting for the non-default event represented by the
    argument symbol.  Same as Monitor>>wait, but the process gets only
    reactivated by the specific event and not the default event."

    self checkOwnerProcess.
    self waitOnLock: (self requestLockFor: aSymbolOrNil)!

waitUntil: aBlock for: aSymbolOrNil
    "Conditional waiting for the non-default event represented by the
    argument symbol.  See Monitor>>waitWhile:for: aBlock."

    ^self waitWhile: [aBlock value not] for: aSymbolOrNil!

waitWhile: aBlock for: aSymbolOrNil
    "Conditional waiting for the non-default event represented by
    the argument symbol.  Same as Monitor>>waitWhile:for:, but the
    process gets only reactivated by the specific event and not the
    default event."

    self checkOwnerProcess.
    self waitWhile: aBlock onLock: (self requestLockFor: aSymbolOrNil).! !

!Monitor methodsFor: 'waiting-default'!

wait
    "Unconditional waiting for the default event.  The current process
    gets blocked and leaves the monitor, which means that the monitor
    allows another process to execute critical code. When the default
    event is notifyed, the original process is resumed."

    ^self waitFor: nil!

waitUntil: aBlock
	"Conditional waiting for the default event.
	See Monitor>>waitWhile: aBlock."

    ^self waitUntil: aBlock for: nil!

waitWhile: aBlock
    "Conditional waiting for the default event.
    The current process gets blocked and leaves the monitor only if
    the argument block evaluates to true. This means that another
    process can enter the monitor. When the default event is notifyed,
    the original process is resumed, which means that the condition
    (argument block) is checked again. Only if it evaluates to false,
    execution proceeds. Otherwise, the process gets blocked and leaves
    the monitor again..."

    ^self waitWhile: aBlock for: nil! !

!Monitor methodsFor: 'notifying-default'!

notify
    "One process waiting for the default event is woken up."
    ^self notify: nil!

notifyAll
    "All processes waiting for the default event are woken up."
    ^self notifyAll: nil! !

!Monitor methodsFor: 'notifying-specific'!

notify: aSymbolOrNil
    "One process waiting for the given event is woken up. If there
    is no process waiting for this specific event, a process waiting
    for the default event gets resumed."

    | lock |
    self checkOwnerProcess.
    lock := self lockFor: aSymbolOrNil.
    lock isNil ifTrue: [ lock := self defaultLock ].
    lock notify!

notifyAll: aSymbolOrNil
    "All process waiting for the given event or the default event
    are woken up."

    | lock |
    self checkOwnerProcess.
    self defaultLock notifyAll.
    lock := self lockFor: aSymbolOrNil.
    lock isNil ifTrue: [ ^self ].
    lock notifyAll!

notifyReallyAll
    "All processes waiting for any events (default or specific) are
    woken up."

    self checkOwnerProcess.
    self defaultLock notifyAll.
    self lockDict valuesDo: [:lock |
    	lock notifyAll]! !

!Monitor methodsFor: 'accessing'!


cleanup
    self checkOwnerProcess.
    self defaultLock isEmpty ifTrue: [defaultLock := nil].
    lockDict ifNotNil: [
	lockDict copy keysAndValuesDo: [:id :lock | 
	    lock isEmpty ifTrue: [lockDict removeKey: id]].
	lockDict isEmpty ifTrue: [lockDict := nil]]!

!Monitor methodsFor: 'private'!

checkOwnerProcess
    self isOwnerProcess
	ifFalse: [self error: 'Monitor access violation']!

defaultLock
    defaultLock isNil ifTrue: [defaultLock := Semaphore new].
    ^defaultLock!

waitOnLock: aSemaphore
    self exit.
    aSemaphore wait.
    self enter!

lockDict
    lockDict isNil ifTrue: [lockDict := IdentityDictionary new].
    ^lockDict!

requestLockFor: aSymbol
    aSymbol isNil ifTrue: [ ^self defaultLock ].
    ^self lockDict at: aSymbol ifAbsentPut: [Semaphore new]!

lockFor: aSymbol
    aSymbol isNil ifTrue: [ ^self defaultLock ].
    ^self lockDict at: aSymbol ifAbsent: [nil]!

waitWhile: aBlock onLock: aSemaphore
    [aBlock value] whileTrue: [self waitOnLock: aSemaphore]!

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
