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
| 330, Boston, MA 02111-1307, USA.  
|
 ======================================================================"


Object subclass: #Link
       instanceVariableNames: 'nextLink'
       classVariableNames: ''
       poolDictionaries: ''
       category: 'Collections-Sequenceable'
!

Link comment: 
'I represent simple linked lists.  Generally, I am not used by myself, but
rather a subclass adds other instance variables that hold the information
for each node, and I hold the glue that keeps them together.' !


!Link class methodsFor: 'instance creation'!

nextLink: aLink
    "Create an instance with the given next link"
    ^self new nextLink: aLink

! !


!Link methodsFor: 'iteration'!

at: index
    "Retrieve a node (instance of Link) that is at a distance of `index'
     after the receiver."
    | i element |
    i := 1.
    element := self.
    [
	i = index ifTrue: [ ^element ].
	i := i + 1.
	(element := element nextLink) isNil
    ] whileFalse.
    SystemExceptions.IndexOutOfRange signalOn: self withIndex: index
!

at: index put: object
    self shouldNotImplement
!

do: aBlock
    "Evaluate aBlock for each element in the list"
    | item |
    item := self.
    [ aBlock value: item. (item := item nextLink) isNil ] whileFalse
!

size
    "Answer the number of elements in the list. Warning: this is O(n)"
    | item count |
    item := self.
    count := 1.
    [ (item := item nextLink) isNil ] whileFalse: [ count := count + 1 ].
    ^count
! !


!Link methodsFor: 'basic'!

nextLink
    "Answer the next item in the list"
    ^nextLink
!

nextLink: aLink
    "Set the next item in the list"
    nextLink := aLink
! !

