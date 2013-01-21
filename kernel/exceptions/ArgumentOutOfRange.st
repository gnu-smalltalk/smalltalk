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

InvalidArgument subclass: ArgumentOutOfRange [
    | low high |
    
    <category: 'Language-Exceptions'>
    <comment: 'I am raised when one invokes a method with an argument outside of its
valid range.'>

    ArgumentOutOfRange class >> signalOn: value mustBeBetween: low and: high [
	"Raise the exception.  The given value was not between low and high."

	<category: 'signaling'>
	| errorString |
	errorString := RegressionTesting 
		    ifTrue: ['argument out of range']
		    ifFalse: 
			['argument must be between ' , low printString , ' and ' , high printString].
	^(self new)
	    value: value;
	    low: low;
	    high: high;
	    signal: errorString
    ]

    description [
	"Answer a textual description of the exception."

	<category: 'accessing'>
	^'argument out of range'
    ]

    low [
	"Answer the lowest value that was permitted."

	<category: 'accessing'>
	^low
    ]

    low: aMagnitude [
	"Set the lowest value that was permitted."

	<category: 'accessing'>
	low := aMagnitude
    ]

    high [
	"Answer the highest value that was permitted."

	<category: 'accessing'>
	^high
    ]

    high: aMagnitude [
	"Set the highest value that was permitted."

	<category: 'accessing'>
	high := aMagnitude
    ]
]

]
