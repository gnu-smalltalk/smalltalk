"======================================================================
|
|   LinkedList Method Definitions
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



SequenceableCollection subclass: LinkedList [
    | firstLink lastLink |
    
    <category: 'Collections-Sequenceable'>
    <comment: 'I provide methods that access and manipulate linked lists.  I assume that 
the elements of the linked list are subclasses of Link, because I use 
the methods that class Link supplies to implement my methods.'>

    at: index [
	"Return the element that is index into the linked list."

	<category: 'accessing'>
        self isEmpty ifTrue: [
            ^SystemExceptions.IndexOutOfRange signalOn: self withIndex: index ].
	^firstLink at: index
    ]

    at: index put: object [
	<category: 'accessing'>
	self shouldNotImplement
    ]

    add: aLink [
	"Add aLink at the end of the list; return aLink."

	<category: 'adding'>
	self addLast: aLink.
	^aLink
    ]

    addFirst: aLink [
	"Add aLink at the head of the list; return aLink."

	<category: 'adding'>
	lastLink isNil ifTrue: [lastLink := aLink].
	aLink nextLink: firstLink.
	^firstLink := aLink
    ]

    addLast: aLink [
	"Add aLink at then end of the list; return aLink."

	<category: 'adding'>
	firstLink isNil ifTrue: [firstLink := aLink].
	lastLink notNil ifTrue: [lastLink nextLink: aLink].
	^lastLink := aLink
    ]

    first [
        "Retrieve the first element of the list and return it, or error if the
         list is empty."

        <category: 'iteration'>
        self isEmpty ifTrue: [
            ^SystemExceptions.IndexOutOfRange signalOn: self withIndex: 1 ].
        ^firstLink
    ]

    last [
        "Retrieve the last element of the list and return it, or error if the
         list is empty."

        <category: 'iteration'>
        self isEmpty ifTrue: [
            ^SystemExceptions.IndexOutOfRange signalOn: self withIndex: 0 ].
        ^lastLink
    ]

    removeFirst [
	"Remove the first element from the list and return it, or error if the
	 list is empty."

	<category: 'adding'>
	^self remove: firstLink
	    ifAbsent: [SystemExceptions.EmptyCollection signalOn: self]
    ]

    removeLast [
	"Remove the final element from the list and return it, or error if the
	 list is empty."

	<category: 'adding'>
	^self remove: lastLink
	    ifAbsent: [SystemExceptions.EmptyCollection signalOn: self]
    ]

    remove: aLink ifAbsent: aBlock [
	"Remove aLink from the list and return it, or invoke aBlock if it's not
	 found in the list."

	<category: 'adding'>
	| prev |
	aLink == firstLink 
	    ifTrue: 
		[firstLink isNil ifTrue: [^aBlock value].
		firstLink := firstLink nextLink.
		firstLink isNil ifTrue: [lastLink := nil].
		aLink nextLink: nil.
		^aLink].
	prev := firstLink.
	
	[prev isNil ifTrue: [^aBlock value].
	prev nextLink == aLink] 
		whileFalse: [prev := prev nextLink].
	prev nextLink: aLink nextLink.
	aLink == lastLink ifTrue: [lastLink := prev].
	aLink nextLink: nil.
	^aLink
    ]

    do: aBlock [
	"Enumerate each object in the list, passing it to aBlock (actual
	 behavior might depend on the subclass of Link that is being used)."

	<category: 'enumerating'>
	self isEmpty ifFalse: [firstLink do: aBlock]
    ]

    includes: anObject [
	"Answer whether we include anObject"

	"Blah, this is roughly the same implementation as in Collection."

	<category: 'enumerating'>
	self isEmpty ifTrue: [^false].
	firstLink do: [:element | anObject = element ifTrue: [^true]].
	^false
    ]

    identityIncludes: anObject [
	"Answer whether we include the anObject object"

	"Blah, this is roughly the same implementation as in Collection."

	<category: 'enumerating'>
	self isEmpty ifTrue: [^false].
	firstLink do: [:element | anObject == element ifTrue: [^true]].
	^false
    ]

    isEmpty [
	"Returns true if the list contains no members"

	<category: 'testing'>
	^firstLink isNil
    ]

    notEmpty [
	"Returns true if the list contains at least a member"

	<category: 'testing'>
	^firstLink notNil
    ]

    size [
	"Answer the number of elements in the list. Warning: this is O(n)"

	<category: 'testing'>
	^self isEmpty ifTrue: [0] ifFalse: [firstLink size]
    ]
]

