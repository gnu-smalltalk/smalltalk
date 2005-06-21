"======================================================================
|
|   Interval Method Definitions
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


ArrayedCollection subclass: #Interval
		  instanceVariableNames: 'start stop step'
		  classVariableNames: ''
		  poolDictionaries: ''
		  category: 'Collections-Sequenceable'
!

Interval comment: 
'My instances represent ranges of objects, typically Number type
objects.  I provide iteration/enumeration messages for producing all the
members that my instance represents.' !


!Interval class methodsFor: 'instance creation'!

from: startInteger to: stopInteger by: stepInteger
    "Answer an Interval going from startInteger to the
    stopInteger, with a step of stepInteger"
    ^self basicNew initializeFrom: startInteger to: stopInteger by: stepInteger
!

from: startInteger to: stopInteger    
    "Answer an Interval going from startInteger to the
    stopInteger, with a step of 1"
    ^self from: startInteger to: stopInteger by: 1
!

withAll: aCollection 
     "Answer an Interval containing the same elements as aCollection.
     Fail if it is not possible to create one."

    | newInterval last delta |
    aCollection keysAndValuesDo: [ :index :each |
	index > 2
	    ifTrue: [
	        last - each = delta ifFalse: [
		    SystemExceptions.InvalidArgument
			signalOn: aCollection
			reason: 'argument not an arithmetic progression' ].
	    ]
	    ifFalse: [
		last isNil ifFalse: [ delta := last - each ]
	    ].

	last := each.
    ].
	
    ^self
	from: aCollection first
	to: aCollection last
	by: (aCollection last - aCollection first) // (aCollection size - 1).
! !


!Interval methodsFor: 'basic'!

"Note to the reader: these two methods (do: and collect:) are implemented
in this expanded way, instead of just making the whileTrue: condition be a
block that's conditionally assigned based on the sign of step and then
invoking a single whileTrue: loop.  However, in this form, the compiler
can optimize these while loops into direct byte codes and not have to bother
with expensive (relatively) block and method context creation and sending
messages to blocks. "

do: aBlock
    "Evaluate the receiver for each element in aBlock"
    | i |
    i := start.
    step > 0
    	ifTrue: [
    	    [ i <= stop ] whileTrue:
    	    	[ aBlock value: i.
    	    	  i := i + step ]
    	]
    	ifFalse: [
	    [ i >= stop ] whileTrue:
    	    	[ aBlock value: i.
    	    	  i := i + step ]
    	]
!

collect: aBlock
    "Evaluate the receiver for each element in aBlock,
     collect in an array the result of the evaluations."
    | i result j |
    result := self copyEmpty: self size.
    i := 1.
    j := start.
    step > 0
    	ifTrue: [
	    [ j <= stop ]
	    	whileTrue:
		    [ result at: i put: (aBlock value: j).
		    	j := j + step.
			i := i + 1 ]
    	]
	ifFalse: [
	    [ j >= stop ]
	    	whileTrue:
		    [ result at: i put: (aBlock value: j).
		      j := j + step.
		      i := i + 1 ]
    	].
    ^result
!    

size
    "Answer the number of elements in the receiver."
    step > 0
    	ifTrue: [
	    stop >= start ifTrue: [ ^(stop - start) // step + 1 ]
	    	    	  ifFalse: [ ^0 ]
	]
	ifFalse: [
    	    start >= stop ifTrue: [ ^(stop - start) // step + 1 ]
	    	    	  ifFalse: [ ^0 ]
	]
!

reverse
    "Answer a copy of the receiver with all of its items reversed"
    ^Interval
	from: (self at: self size)
	to: (self at: 1)
	by: self step negated
!

species
    ^Array
!


at: index
    "Answer the index-th element of the receiver."
    (index >= 1 and: [index <= self size])
    	ifTrue: [ ^start + (step * (index - 1)) ]
	ifFalse: [ SystemExceptions.IndexOutOfRange signalOn: self withIndex: index ]
!

at: index put: anObject
    self shouldNotImplement
! !



!Interval methodsFor: 'testing'!

= anInterval
    "Answer whether anInterval is the same interval as the receiver"
    self class == anInterval class ifFalse: [ ^false ].
    ^(start = anInterval start) &
	(stop = anInterval stop) &
	(step = anInterval step)
!

hash
    "Answer an hash value for the receiver"
    ^((start + stop + stop) * step) bitAnd: 16r3FFFFFFF
! !



!Interval methodsFor: 'printing'!

printOn: aStream
    "Print a representation for the receiver on aStream"
    | size |
    aStream
	nextPutAll: self classNameString;
	nextPut: $(.

    size := self size.
    size > 0 ifTrue: [
	aStream print: start
    ].
    size > 1 ifTrue: [
	aStream
	    space;
	    print: start + step
    ].
    size > 2 ifTrue: [
	size > 3 ifTrue: [ aStream nextPutAll: ' ...' ].
	aStream
	    space;
	    print: stop
    ].
    aStream nextPut: $)
! !



!Interval methodsFor: 'storing'!

storeOn: aStream
    "Store Smalltalk code compiling to the receiver on aStream"
    aStream nextPut: $(.
    aStream nextPutAll: self classNameString.
    aStream nextPutAll: ' from: '.
    start storeOn: aStream.
    aStream nextPutAll: ' to: '.
    stop storeOn: aStream.
    aStream nextPutAll: ' by: '.
    step storeOn: aStream.
    aStream nextPut: $)
! !



!Interval methodsFor: 'private methods'!

copyEmpty
    "Answer an empty copy of the receiver, with the class answered by the
     collect: method."
    ^self species new: self size
!

initializeFrom: startInteger to: stopInteger by: stepInteger
    start := startInteger.
    stop := stopInteger.
    step := stepInteger
!

start
    ^start
!

stop
    ^stop
!

step
    ^step
! !

