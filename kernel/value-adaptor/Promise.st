"======================================================================
|
|   ValueAdaptor hierarchy Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999, 2000, 2001, 2002, 2008, 2009 Free Software Foundation, Inc.
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



ValueHolder subclass: Promise [
    | sema error |
    
    <category: 'Language-Data types'>
    <comment: 'I store my value in a variable, and know whether I have been
initialized or not.  If you ask for my value and I have not been
initialized, I suspend the process until a value has been assigned.'>

    Promise class >> for: aBlock [
	"Invoke aBlock at an indeterminate time in an indeterminate
	 process before answering its value from #value sent to my
	 result."
	<category: 'creating instances'>
	| p |
	p := Promise new.
	[[ p value: aBlock value ]
	    on: Error
	    do: [ :ex | p errorValue: ex. ex return ]] fork.
	^p
    ]

    Promise class >> null [
	<category: 'creating instances'>
	self shouldNotImplement
    ]

    hasError [
	"Answer whether calling #value will raise an exception."

	<category: 'accessing'>
	^error notNil
    ]

    hasValue [
	"Answer whether we already have a value (or calling #value will
	 raise an error)."

	<category: 'accessing'>
	^sema isNil
    ]

    value: anObject [
	"Set the value of the receiver."

	<category: 'accessing'>

	super value: anObject.
	[sema notifyAll. sema := nil] valueWithoutPreemption
    ]

    errorValue: anException [
	"Private - Raise anException whenever #value is called."

	error := anException.
	[sema notifyAll. sema := nil] valueWithoutPreemption
    ]

    value [
	"Get the value of the receiver."

	<category: 'accessing'>
	
	"This is guaranteed to execute atomically by the VM!"
	sema == nil ifFalse: [sema wait].

	^error isNil
	    ifTrue: [ super value ]
	    ifFalse: [ error copy signal ]
    ]

    printOn: aStream [
	"Print a representation of the receiver"

	<category: 'printing'>
	aStream print: self class.
	self hasValue ifFalse: [ aStream nextPutAll: '(???)' ].
	self hasError ifTrue: [ aStream nextPutAll: '(Error!)' ].

	aStream
	    nextPut: $(;
	    print: self value;
	    nextPut: $)
    ]

    initialize [
	"Private - set the initial state of the receiver"

	<category: 'initializing'>
	super initialize.
	sema := Semaphore new
    ]
]
