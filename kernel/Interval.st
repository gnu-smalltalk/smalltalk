"======================================================================
|
|   Interval Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2002,2005,2008,2009
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



ArrayedCollection subclass: Interval [
    | start stop step |
    
    <category: 'Collections-Sequenceable'>
    <comment: 'My instances represent ranges of objects, typically Number type
objects.  I provide iteration/enumeration messages for producing all the
members that my instance represents.'>

    Interval class >> from: startInteger to: stopInteger by: stepInteger [
	"Answer an Interval going from startInteger to the
	 stopInteger, with a step of stepInteger"

	<category: 'instance creation'>
	^self basicNew 
	    initializeFrom: startInteger
	    to: stopInteger
	    by: stepInteger
    ]

    Interval class >> from: startInteger to: stopInteger [
	"Answer an Interval going from startInteger to the
	 stopInteger, with a step of 1"

	<category: 'instance creation'>
	^self 
	    from: startInteger
	    to: stopInteger
	    by: 1
    ]

    Interval class >> withAll: aCollection [
	"Answer an Interval containing the same elements as aCollection.
	 Fail if it is not possible to create one."

	<category: 'instance creation'>
	| newInterval last delta |
	aCollection keysAndValuesDo: 
		[:index :each | 
		index > 2 
		    ifTrue: 
			[last - each = delta 
			    ifFalse: 
				[SystemExceptions.InvalidArgument signalOn: aCollection
				    reason: 'argument not an arithmetic progression']]
		    ifFalse: [last isNil ifFalse: [delta := last - each]].
		last := each].
	^self 
	    from: aCollection first
	    to: aCollection last
	    by: (aCollection last - aCollection first) // (aCollection size - 1)
    ]

    do: aBlock [
	"Evaluate the receiver for each element in aBlock"

	<category: 'basic'>
	| i |
	i := start.
	step > 0 
	    ifTrue: [[i <= stop] whileTrue: 
			[aBlock value: i.
			i := i + step]]
	    ifFalse: [[i >= stop] whileTrue: 
			[aBlock value: i.
			i := i + step]]
    ]

    collect: aBlock [
	"Evaluate the receiver for each element in aBlock,
	 collect in an array the result of the evaluations."

	<category: 'basic'>
	| i result j |
	result := self copyEmpty: self size.
	i := 1.
	j := start.
	step > 0 
	    ifTrue: 
		[[j <= stop] whileTrue: 
			[result at: i put: (aBlock value: j).
			j := j + step.
			i := i + 1]]
	    ifFalse: 
		[[j >= stop] whileTrue: 
			[result at: i put: (aBlock value: j).
			j := j + step.
			i := i + 1]].
	^result
    ]

    isExact [
	"Answer whether elements of the receiver are computed using exact
         arithmetic.  This is true as long as the start and step value
	 are exact (i.e. not floating-point)."

	<category: 'testing'>
	^start isExact and: [step isExact]
    ]

    isEmpty [
	"Answer whether the receiver is empty."

	<category: 'basic'>
	^(step > 0) == (stop < start)
    ]

    size [
	"Answer the number of elements in the receiver."

	<category: 'basic'>
	step > 0 
	    ifTrue: [stop >= start ifTrue: [^(stop - start) // step + 1] ifFalse: [^0]]
	    ifFalse: [start >= stop ifTrue: [^(stop - start) // step + 1] ifFalse: [^0]]
    ]

    reverse [
	"Answer a copy of the receiver with all of its items reversed"

	<category: 'basic'>
	^Interval 
	    from: (self at: self size)
	    to: (self at: 1)
	    by: step negated
    ]

    species [
	<category: 'basic'>
	^Array
    ]

    at: index [
	"Answer the index-th element of the receiver."

	<category: 'basic'>
	(index >= 1 and: [index <= self size]) 
	    ifTrue: [^start + (step * (index - 1))]
	    ifFalse: [SystemExceptions.IndexOutOfRange signalOn: self withIndex: index]
    ]

    at: index put: anObject [
	<category: 'basic'>
	self shouldNotImplement
    ]

    = anInterval [
	"Answer whether anInterval is the same interval as the receiver"

	<category: 'testing'>
	self class == anInterval class ifFalse: [^false].
        self isEmpty ifTrue: [ ^anInterval isEmpty ].
        anInterval isEmpty ifTrue: [ ^false ].
	^self first = anInterval first and: [self last = anInterval last
	    and: [self increment = anInterval increment]]
    ]

    hash [
	"Answer an hash value for the receiver"

	<category: 'testing'>
	^(start + stop + stop) * step bitAnd: 1073741823
    ]

    copyFrom: startIndex to: stopIndex [
	<category: 'basic'>
        | last |
        stopIndex < startIndex
            ifTrue:
                [stopIndex = (startIndex - 1)
                    ifTrue: [^Interval from: start to: start - step by: step].

                ^SystemExceptions.ArgumentOutOfRange
                    signalOn: stopIndex
                    mustBeBetween: startIndex - 1
                    and: self size].

        last := self at: stopIndex.
        self isExact ifFalse: [ last := last + (step / 2) ].
	^Interval
            from: (self at: startIndex)
            to: last
            by: step
    ]

    printOn: aStream [
	"Print a representation for the receiver on aStream"

	<category: 'printing'>
	| size |
	aStream
	    nextPutAll: self class storeString;
	    nextPut: $(.
	size := self size.
	size > 0 ifTrue: [aStream print: start].
	size > 1 
	    ifTrue: 
		[aStream
		    space;
		    print: start + step].
	size > 2 
	    ifTrue: 
		[(self at: 3) = stop ifFalse: [aStream nextPutAll: ' ...'].
		aStream
		    space;
		    print: stop].
	aStream nextPut: $)
    ]

    first [
	<category: 'printing'>
	^self isEmpty
	    ifTrue: [SystemExceptions.IndexOutOfRange signalOn: self withIndex: 1]
	    ifFalse: [start]
    ]

    last [
	"Answer the last value."
	<category: 'printing'>
	^self isEmpty
	    ifTrue: [SystemExceptions.IndexOutOfRange signalOn: self withIndex: 0]
	    ifFalse: [stop - ((stop - start) \\ step)]
    ]

    increment [
	<category: 'printing'>
	^step
    ]

    storeOn: aStream [
	"Store Smalltalk code compiling to the receiver on aStream"

	<category: 'storing'>
	aStream nextPut: $(.
	aStream nextPutAll: self class storeString.
	aStream nextPutAll: ' from: '.
	start storeOn: aStream.
	aStream nextPutAll: ' to: '.
	stop storeOn: aStream.
	aStream nextPutAll: ' by: '.
	step storeOn: aStream.
	aStream nextPut: $)
    ]

    copyEmpty [
	"Answer an empty copy of the receiver, with the class answered by the
	 collect: method."

	<category: 'private methods'>
	^self species new: self size
    ]

    initializeFrom: startInteger to: stopInteger by: stepInteger [
	<category: 'private methods'>
	start := startInteger.
	stop := stopInteger.
	step := stepInteger
    ]
]

