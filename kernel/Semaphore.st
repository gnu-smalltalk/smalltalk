"======================================================================
|
|   Semaphore Method Definitions
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
| 330, Boston, MA 02111-1307, USA.  
|
 ======================================================================"


LinkedList subclass: #Semaphore
	   instanceVariableNames: 'signals name'
	   classVariableNames: ''
	   poolDictionaries: ''
	   category: 'Language-Processes'
!

Semaphore comment: 
'My instances represent counting semaphores.  I provide methods for signalling
the semaphore''s availability, and methods for waiting for its availability.
I also provide some methods for implementing critical sections.' !


!Semaphore class methodsFor: 'instance creation'!

new
    "Answer a new semaphore"
    ^self basicNew initialize
!

forMutualExclusion
    "Answer a new semaphore with a signal on it. These semaphores are a useful
     shortcut when you use semaphores as critical sections."
    ^self new
	signal;
	yourself
! !



!Semaphore methodsFor: 'mutual exclusion'!

critical: aBlock
    "Wait for the receiver to be free, execute aBlock and signal the receiver
     again. Return the result of evaluating aBlock."
    self wait.
    ^aBlock ensure: [ self signal ]
! !


!Semaphore methodsFor: 'accessing'!

name
    "Answer a user-friendly name for the receiver"
    ^name
!

name: aString
    "Answer a user-friendly name for the receiver"
    name := aString
!

waitingProcesses
    "Answer an Array of processes currently waiting on the receiver."
    ^self asArray
!

wouldBlock
    "Answer whether waiting on the receiver would suspend the current process."
    ^signals = 0
! !



!Semaphore methodsFor: 'printing'!

printOn: aStream
    "Print a human-readable represention of the receiver on aStream."
    aStream
        nextPutAll: self class name;
        nextPutAll: ('(%1: %<free|held>2, %3 %<available signals|waiting processes>2)'
	    bindWith: self name printString
	    with: self signals > 0
	    with: self signals abs)! !


!Semaphore methodsFor: 'private'!

initialize
    signals := 0
!

signals
    "Answer the number of processes that can be accomodated or (if negative
     the number of waiting processes."

    "signals never goes below 0, even if there are waiting process. So
     - if 0 and 0 processes are waiting, the signal count is 0
     - if 0 and k processes are waiting, the signal count is -k
     - if >0, no processes must be waiting and the signal count is signals"
    ^signals - self size
! !
