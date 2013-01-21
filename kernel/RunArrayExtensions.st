"======================================================================
|
|   RunArray Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999, 2000, 2001, 2002, 2009 Free Software Foundation, Inc.
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

"Some of the methods I define (first, last, indexOf:startingAt:ifAbsent:,
 shallowCopy, deepCopy, =, hash) are here only for performance purposes (their
 inherited implementation works, but it is slow)"



Collection extend [

    asRunArray [
	"Answer the receiver converted to a RunArray. If the receiver is not
	 ordered the order of the elements in the RunArray might not be the #do:
	 order."

	<category: 'converting'>
	^(RunArray basicNew)
	    map: self asRunArrayMap;
	    initialize
    ]

    asRunArrayMap [
	"Private - Answer the receiver converted to an OrderedCollection of
	Associations whose keys are the actual objects and whose values are
	the number of consecutive copies of them"

	"Bags can be easily packed, because they are made of runs of unordered
	 elements like RunArrays. As the #do: order of non-sequenceable collections
	 is undefined, we choose the ordering which yields the best map."

	<category: 'private'>
	^self asBag asRunArrayMap
    ]

]



Bag extend [

    asRunArrayMap [
	"Private - Answer the receiver converted to an OrderedCollection of
	Associations whose keys are the actual objects and whose values are
	the number of consecutive copies of them"

	<category: 'private'>
	| map |
	map := OrderedCollection new: contents size.
	contents associationsDo: [:assoc | map addLast: assoc].
	^map
    ]

]



SequenceableCollection extend [

    asRunArrayMap [
	"Private - Answer the receiver converted to an OrderedCollection of
	Associations whose keys are the actual objects and whose values are
	the number of consecutive copies of them"

	<category: 'private'>
	| map prev startIndex |
	map := OrderedCollection new.
	prev := self at: 1.
	startIndex := 1.
	self 
	    from: 2
	    to: self size
	    keysAndValuesDo: 
		[:currIndex :each | 
		each = prev 
		    ifFalse: 
			[map addLast: (Association key: prev value: currIndex - startIndex).
			prev := each.
			startIndex := currIndex]].
	map addLast: (Association key: prev value: self size + 1 - startIndex).
	^map
    ]

]

