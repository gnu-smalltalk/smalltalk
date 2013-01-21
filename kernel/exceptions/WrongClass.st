"======================================================================
|
|   ANSI exception handling classes
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2000, 2001, 2002, 2007, 2008, 2009 Free Software Foundation, Inc.
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



Namespace current: SystemExceptions [

InvalidValue subclass: WrongClass [
    | validClasses |
    
    <category: 'Language-Exceptions'>
    <comment: 'I am raised when an argument is constrained to be an instance of a determinate
class, and this constraint is not respected by the caller.'>

    WrongClass class >> signalOn: anObject mustBe: aClassOrArray [
	"Raise an exception.  The given object should have been an instance
	 of one of the classes indicated by aClassOrArray (which should be
	 a single class or an array of classes).  Whether instances of
	 subclasses are allowed should be clear from the context, though
	 in general (i.e. with the exception of a few system messages)
	 they should be."

	<category: 'signaling'>
	(aClassOrArray isKindOf: Collection) 
	    ifFalse: [^self signalOn: anObject mustBe: {aClassOrArray binding}].
	^(self new)
	    validClasses: aClassOrArray;
	    value: anObject;
	    signal
    ]

    description [
	"Answer a textual description of the exception."

	<category: 'accessing'>
	^'wrong argument type'
    ]

    messageText [
	"Answer an exception's message text."

	<category: 'accessing'>
	self validClasses isNil 
	    ifTrue: [^'Invalid argument ' , self value printString].
	^'Invalid argument %1: must be %2' % 
		{self value.
		self validClassesString}
    ]

    validClasses [
	"Answer the list of classes whose instances would have been valid."

	<category: 'accessing'>
	^validClasses
    ]

    validClassesString [
	"Answer the list of classes whose instances would have been valid,
	 formatted as a string."

	<category: 'accessing'>
	^String streamContents: 
		[:str | 
		validClasses keysAndValuesDo: 
			[:idx :classOrBinding | 
			| name class |
			idx > 1 
			    ifTrue: 
				[idx = validClasses size 
				    ifFalse: [str nextPutAll: ', ']
				    ifTrue: [str nextPutAll: ' or ']].
			class := classOrBinding isClass 
				    ifTrue: [classOrBinding]
				    ifFalse: [classOrBinding value].
			name := class nameIn: Namespace current.
			name first isVowel 
			    ifTrue: [str nextPutAll: 'an ']
			    ifFalse: [str nextPutAll: 'a '].
			str nextPutAll: name]]
    ]

    validClasses: aCollection [
	"Set the list of classes whose instances would have been valid."

	<category: 'accessing'>
	validClasses := aCollection
    ]
]

]

