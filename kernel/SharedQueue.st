"======================================================================
|
|   SharedQueue Method Definitions
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



Object subclass: SharedQueue [
    | queueSem valueReady queue |
    
    <category: 'Language-Processes'>
    <comment: 'My instances provide a guaranteed safe mechanism to allow for communication
between processes.  All access to the underlying data structures is
controlled with critical sections so that things proceed smoothly.'>

    SharedQueue class >> new [
	"Create a new instance of the receiver"

	<category: 'instance creation'>
	^self basicNew init: (OrderedCollection new: 10)
    ]

    SharedQueue class >> sortBlock: sortBlock [
	"Create a new instance of the receiver which implements a
	 priority queue with the given sort block"

	<category: 'instance creation'>
	^self basicNew init: (SortedCollection sortBlock: sortBlock)
    ]

    isEmpty [
	"Answer whether there is an object on the queue"

	<category: 'accessing'>
	^queue isEmpty
    ]

    next [
	"Wait for an object to be on the queue, then remove it and answer it"

	<category: 'accessing'>
	| result |
	valueReady wait.
	queueSem critical: [result := queue removeFirst].
	^result
    ]

    nextPut: value [
	"Put value on the queue and answer it"

	<category: 'accessing'>
	queueSem critical: [queue add: value].
	valueReady signal.
	^value
    ]

    peek [
	"Wait for an object to be on the queue if necessary, then answer the
	 same object that #next would answer without removing it."

	<category: 'accessing'>
	| result |
	valueReady wait.
	queueSem critical: [result := queue first].
	valueReady signal.
	^result
    ]

    init: aCollection [
	<category: 'private'>
	queue := aCollection.
	valueReady := Semaphore new.
	queueSem := Semaphore forMutualExclusion
    ]
]

