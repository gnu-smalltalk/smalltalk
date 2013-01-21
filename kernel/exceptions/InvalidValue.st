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

Error subclass: InvalidValue [
    | value |
    
    <category: 'Language-Exceptions'>
    <comment: 'I am raised when one invokes a method with an invalid receiver or argument.'>

    InvalidValue class >> signalOn: value [
	"Answer an exception reporting the parameter as invalid."

	<category: 'signaling'>
	^(self new)
	    value: value;
	    signal
    ]

    InvalidValue class >> signalOn: value reason: reason [
	"Answer an exception reporting `value' as invalid, for the given
	 reason."

	<category: 'signaling'>
	^(self new)
	    value: value;
	    signal: reason
    ]

    description [
	"Answer a textual description of the exception."

	<category: 'accessing'>
	^'unknown error'
    ]

    messageText [
	"Answer an exception's message text."

	<category: 'accessing'>
	^'Invalid value %1: %2' % 
		{self value.
		self basicMessageText}
    ]

    value [
	"Answer the object that was found to be invalid."

	<category: 'accessing'>
	^value
    ]

    value: anObject [
	"Set the object that was found to be invalid."

	<category: 'accessing'>
	value := anObject
    ]
]

]

