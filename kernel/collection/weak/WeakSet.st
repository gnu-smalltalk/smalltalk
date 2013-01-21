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



Set subclass: WeakSet [
    
    <shape: #pointer>
    <category: 'Collections-Weak'>
    <comment: '
I am similar to a plain set, but my items are stored in a weak array;
I track which of them are garbage collected and, as soon as I encounter
one of them, I swiftly remove all.'>

    add: newObject [
	"Add newObject to the set, if and only if the set doesn't already contain
	 an occurrence of it. Don't fail if a duplicate is found. Answer newObject"

	<category: 'accessing'>
	| index |
	index := self findIndex: newObject.
	(self primAt: index) isNil ifTrue: [
	    self incrementTally ifTrue: [index := self findIndex: newObject].
	    self primAt: index put: (self newAssociation: newObject)].
	^newObject
    ]

    do: aBlock [
	"Enumerate all the non-nil members of the set"

	<category: 'accessing'>
	1 to: self primSize
	    do: [:i | (self primAt: i) notNil ifTrue: [aBlock value: (self primAt: i) key]]
    ]

    postLoad [
	"Called after loading an object; must restore it to the state before
	 `preStore' was called.  Make it weak again"

	<category: 'loading'>
	1 to: self primSize
	    do: [:i | (self primAt: i) notNil ifTrue: [(self primAt: i) makeEphemeron]]
    ]

    shallowCopy [
	"Returns a shallow copy of the receiver (the instance variables are
	 not copied)"

	<category: 'copying'>
	| copy |
	copy := self copyEmpty: self capacity.
	self do: [:each | copy addWhileGrowing: (copy newAssociation: each)].
	^copy
    ]

    deepCopy [
	"Returns a deep copy of the receiver (the instance variables are
	 copies of the receiver's instance variables)"

	<category: 'copying'>
	| copy |
	copy := self copyEmpty: self capacity.
	self do: [:each | copy addWhileGrowing: (copy newAssociation: each copy)].
	^copy
    ]

    newAssociation: key [
	<category: 'private'>
	^(HomedAssociation 
	    key: key
	    value: nil
	    environment: self)
	    makeEphemeron;
	    yourself
    ]

    mourn: anObject [
	"Private - anObject has been found to have a weak key, remove it."

	"What has to be passed to #remove: is the key, not the whole object."

	<category: 'private'>
	super mourn: anObject key
    ]

    findElementIndex: anObject [
        "Tries to see if anObject exists as an indexed variable. As soon as nil
         is found, the index of that slot is answered"

        <category: 'private methods'>
        | index size element |
        "Sorry for the lack of readability, but I want speed... :-)"
        index := (anObject key hash scramble bitAnd: (size := self primSize) - 1) + 1.
   
        [(element := self primAt: index) isNil
            ifTrue: [^index].
        index == size ifTrue: [index := 1] ifFalse: [index := index + 1]]
                repeat
    ]

    findIndex: anObject [
	"Tries to see if anObject exists as an indexed variable. As soon as nil
	 or anObject is found, the index of that slot is answered"

	<category: 'private'>
	| index size element |
	"Sorry for the lack of readability, but I want speed... :-)"
	index := (anObject identityHash scramble 
		    bitAnd: (size := self primSize) - 1) + 1.
	
	[((element := self primAt: index) isNil or: [element key = anObject]) 
	    ifTrue: [^index].
	index == size ifTrue: [index := 1] ifFalse: [index := index + 1]] 
		repeat
    ]
]
