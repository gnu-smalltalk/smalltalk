"======================================================================
|
|   ReadStream Method Definitions
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001
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


PositionableStream subclass: #ReadStream
		   instanceVariableNames: ''
		   classVariableNames: ''
		   poolDictionaries: ''
		   category: 'Streams-Collections'
!

ReadStream comment: 
'I implement the set of read-only stream objects.  You may read from
my objects, but you may not write to them.' !


!ReadStream class methodsFor: 'instance creation'!

on: aCollection
    "Answer a new stream working on aCollection from its start."
    ^(self basicNew initCollection: aCollection) beReadOnly
! !



!ReadStream methodsFor: 'accessing-reading'!

size
    "Answer the receiver's size."
    ^collection size
!

reverseContents
    "May be faster than generic stream reverseContents."
    | aCollection i numElts |
    numElts := collection size.
    aCollection := collection copyEmpty: numElts.
    i := 0.
    [ i := i + 1. 
      i <= endPtr ] whileTrue:
    	[ aCollection at: numElts - i + 1
	    	      put: (collection at: i) ].
    ^aCollection
! !



!ReadStream methodsFor: 'private methods'!

initCollection: aCollection
    collection := aCollection.
    ptr := 1.
    endPtr := collection size
! !
