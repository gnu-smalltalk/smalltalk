"======================================================================
|
|   Link Method Definitions
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



Object subclass: Link [
    | nextLink |
    
    <category: 'Collections-Sequenceable'>
    <comment: 'I represent simple linked lists.  Generally, I am not used by myself, but
rather a subclass adds other instance variables that hold the information
for each node, and I hold the glue that keeps them together.'>

    Link class >> nextLink: aLink [
	"Create an instance with the given next link"

	<category: 'instance creation'>
	^self new nextLink: aLink
    ]

    at: index [
	"Retrieve a node (instance of Link) that is at a distance of `index'
	 after the receiver."

	<category: 'iteration'>
	| i element |
	i := 1.
	element := self.
	
	[i = index ifTrue: [^element].
	i := i + 1.
	(element := element nextLink) isNil] 
		whileFalse.
	SystemExceptions.IndexOutOfRange signalOn: self withIndex: index
    ]

    at: index put: object [
	<category: 'iteration'>
	self shouldNotImplement
    ]

    do: aBlock [
	"Evaluate aBlock for each element in the list"

	<category: 'iteration'>
	| item |
	item := self.
	
	[aBlock value: item.
	(item := item nextLink) isNil] whileFalse
    ]

    size [
	"Answer the number of elements in the list. Warning: this is O(n)"

	<category: 'iteration'>
	| item count |
	item := self.
	count := 1.
	[(item := item nextLink) isNil] whileFalse: [count := count + 1].
	^count
    ]

    nextLink [
	"Answer the next item in the list"

	<category: 'basic'>
	^nextLink
    ]

    nextLink: aLink [
	"Set the next item in the list"

	<category: 'basic'>
	nextLink := aLink
    ]
]

