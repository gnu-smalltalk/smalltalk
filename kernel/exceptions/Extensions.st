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



Number extend [

    arithmeticError: msg [
	"Raise an ArithmeticError exception having msg as its message text."

	<category: 'error raising'>
	^ArithmeticError new signal: msg
    ]

    zeroDivide [
	"Raise a division-by-zero (ZeroDivide) exception whose dividend
	 is the receiver."

	<category: 'error raising'>
	^(ZeroDivide dividend: self) signal
    ]

]



Object extend [

    doesNotUnderstand: aMessage [
	"Called by the system when a selector was not found. message is a
	 Message containing information on the receiver"

	"aMessage inspect."

	"thisContext parentContext method inspect."

	"ObjectMemory abort."

	<category: 'error raising'>
	^(MessageNotUnderstood new)
	    message: aMessage receiver: self;
	    signal
    ]

    error: message [
	"Display a walkback for the receiver, with the given error message.
	 Signal an `Error' exception."

	<category: 'error raising'>
	^Error new signal: message
    ]

    halt: message [
	"Display a walkback for the receiver, with the given error message.
	 Signal an `Halt' exception."

	<category: 'error raising'>
	^Halt new signal: message
    ]

]

