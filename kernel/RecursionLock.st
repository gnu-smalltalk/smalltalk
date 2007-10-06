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



Object subclass: RecursionLock [
    | owner sema |
    
    <category: 'Language-Processes'>
    <comment: nil>

    RecursionLock class >> new [
	"Answer a new semaphore"

	<category: 'instance creation'>
	^self basicNew initialize
    ]

    printOn: aStream [
	"Print a human-readable represention of the receiver on aStream."

	<category: 'printing'>
	aStream
	    nextPutAll: self class name;
	    nextPut: $(;
	    print: self name;
	    nextPut: $:;
	    nextPutAll: (sema signals = 1 ifTrue: ['free'] ifFalse: ['held']);
	    nextPut: $)
    ]

    isOwnerProcess [
	"Answer whether the receiver is the owner of the lock."

	<category: 'accessing'>
	^owner == Processor activeProcess
    ]

    name [
	"Answer a user-defined name for the lock."

	<category: 'accessing'>
	^sema name
    ]

    name: aString [
	"Set to aString the user-defined name for the lock."

	<category: 'accessing'>
	sema name: aString
    ]

    waitingProcesses [
	"Answer the set of processes that are waiting on the semaphore."

	<category: 'accessing'>
	^sema asArray
    ]

    wouldBlock [
	"Answer whether sending #wait to the receiver would suspend the
	 active process."

	<category: 'accessing'>
	^sema wouldBlock and: [owner ~~ Processor activeProcess]
    ]

    critical: aBlock [
	"Wait for the receiver to be free, execute aBlock and signal the receiver
	 again. Return the result of evaluating aBlock."

	<category: 'mutual exclusion'>
	self isOwnerProcess ifTrue: [^aBlock value].

	"Look out for race conditions!"
	sema critical: [
	    [owner := Processor activeProcess.
	    aBlock value]
		ensure: [owner := nil]].
    ]

    initialize [
	<category: 'private'>
	sema := Semaphore forMutualExclusion
    ]
]

