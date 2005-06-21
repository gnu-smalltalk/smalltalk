"======================================================================
|
|   RecursionLock Method Definitions
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2002 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
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


Object subclass: #RecursionLock
	   instanceVariableNames: 'owner sema'
	   classVariableNames: ''
	   poolDictionaries: ''
	   category: 'Language-Processes'
!


!RecursionLock class methodsFor: 'instance creation'!

new
    "Answer a new semaphore"
    ^self basicNew initialize
! !



!RecursionLock methodsFor: 'printing'!

printOn: aStream
    "Print a human-readable represention of the receiver on aStream."
    aStream
	nextPutAll: self class name;
	nextPut: $(;
	print: self name;
	nextPut: $:;
	nextPutAll: (sema signals = 1 ifTrue: [ 'free' ] ifFalse: [ 'held' ]);
	nextPut: $)
! !
	

!RecursionLock methodsFor: 'accessing'!

isOwnerProcess
    "Answer whether the receiver is the owner of the lock."
    ^owner == Processor activeProcess
!

name
    "Answer a user-defined name for the lock."
    ^sema name
!

name: aString
    "Set to aString the user-defined name for the lock."
    sema name: aString
!

waitingProcesses
    "Answer the set of processes that are waiting on the semaphore."
    ^sema asArray
!

wouldBlock
    "Answer whether sending #wait to the receiver would suspend the
     active process."
    ^sema wouldBlock and: [ owner ~~ Processor activeProcess ]
! !


!RecursionLock methodsFor: 'mutual exclusion'!

critical: aBlock
    "Wait for the receiver to be free, execute aBlock and signal the receiver
     again. Return the result of evaluating aBlock."
    self isOwnerProcess ifTrue: [ ^aBlock value ].

    "Look out for race conditions!"
    self enter.
    ^aBlock ensure: [ self exit ]
! !



!RecursionLock methodsFor: 'private'!

enter
    [ sema wait. owner := Processor activeProcess ]
	valueWithoutPreemption
!

exit
    [ owner := nil. sema signal ]
	valueWithoutPreemption
!

initialize
    sema := Semaphore forMutualExclusion.
! !

