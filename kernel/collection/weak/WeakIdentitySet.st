"=====================================================================
|
|   Weak collections
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999,2000,2001,2002,2007,2008,2009 Free Software Foundation, Inc.
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



WeakSet subclass: WeakIdentitySet [
    
    <shape: #pointer>
    <category: 'Collections-Weak'>
    <comment: '
I am similar to a plain identity set, but my keys are stored in a weak
array; I track which of them are garbage collected and, as soon as I
encounter one of them, I swiftly remove all the garbage collected keys'>

    identityIncludes: anObject [
	"Answer whether I include anObject exactly.  As I am an
	 identity-set, this is the same as #includes:."

	<category: 'accessing'>
	^self includes: anObject
    ]

    findIndex: anObject [
	"Tries to see if anObject exists as an indexed variable. As soon as nil
	 or anObject is found, the index of that slot is answered"

	<category: 'private methods'>
	| index size element |
	"Sorry for the lack of readability, but I want speed... :-)"
	index := (anObject identityHash scramble 
		    bitAnd: (size := self primSize) - 1) + 1.
	
	[((element := self primAt: index) isNil or: [element key == anObject]) 
	    ifTrue: [^index].
	index == size ifTrue: [index := 1] ifFalse: [index := index + 1]] 
		repeat
    ]
]
