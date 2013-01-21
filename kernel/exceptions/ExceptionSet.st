"======================================================================
|
|   Core (instance-based) exception handling classes
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999, 2000, 2001, 2002, 2003, 2008, 2009
| Free Software Foundation, Inc.
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

"Create these symbols. AnsiExcept.st will assign values to them; Also create
 some classes"



Object subclass: ExceptionSet [
    | collection |
    
    <category: 'Language-Exceptions'>
    <comment: '
My instances are not real exceptions: they can only be used as arguments to
#on:do:... methods in BlockClosure. They act as shortcuts that allows you to
use the same handler for many exceptions without having to write duplicate
code'>

    ExceptionSet class >> new [
	"Private - Answer a new, empty ExceptionSet"

	<category: 'instance creation'>
	^self basicNew collection: Set new
    ]

    , aTrappableEvent [
	"Answer an ExceptionSet containing all the exceptions in the
	 receiver and all the exceptions in aTrappableEvent"

	<category: 'instance creation'>
	^(ExceptionSet new)
	    add: self;
	    add: aTrappableEvent;
	    yourself
    ]

    allExceptionsDo: aBlock [
	"Private - Evaluate aBlock for every exception in the receiver. Answer the
	 receiver"

	<category: 'enumerating'>
	collection do: aBlock
    ]

    goodness: exception [
	"Answer how good the receiver is at handling the given exception.  A
	 negative value indicates that the receiver is not able to handle
	 the exception."

	<category: 'enumerating'>
	^collection inject: -1
	    into: [:old :each | old max: (each goodness: exception)]
    ]

    handles: exception [
	"Answer whether the receiver handles `exception'."

	<category: 'enumerating'>
	^collection anySatisfy: [:someItem | someItem handles: exception]
    ]

    add: aTrappableEvent [
	"Private - Add aTrappableEvent to the receiver and answer aTrappableEvent"

	<category: 'private - accessing'>
	aTrappableEvent allExceptionsDo: [:exc | collection add: exc].
	^aTrappableEvent
    ]

    collection: aSet [
	"Private - Set the collection of exception included in the receiver to
	 aSet"

	<category: 'private - accessing'>
	collection := aSet.
	^self
    ]
]

