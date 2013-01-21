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

ShouldNotImplement subclass: WrongMessageSent [
    | selector suggestedSelector |
    
    <category: 'Language-Exceptions'>
    <comment: 'I am raised when a method is called that a class wishes that is not
called.  This exception also includes a suggestion on which message
should be sent instead'>

    WrongMessageSent class >> signalOn: selector useInstead: aSymbol [
	"Raise an exception, signaling which selector was sent and suggesting
	 a valid alternative."

	<category: 'signaling'>
	^(self new)
	    selector: selector;
	    suggestedSelector: aSymbol;
	    signal
    ]

    messageText [
	"Answer an exception's message text."

	<category: 'accessing'>
	^'%1, use %2 instead' % 
		{self basicMessageText.
		self suggestedSelector storeString}
    ]

    selector [
	"Answer which selector was sent."

	<category: 'accessing'>
	^selector
    ]

    selector: aSymbol [
	"Set which selector was sent."

	<category: 'accessing'>
	selector := aSymbol
    ]

    suggestedSelector [
	"Answer a valid alternative to the selector that was used."

	<category: 'accessing'>
	^suggestedSelector
    ]

    suggestedSelector: aSymbol [
	"Set a valid alternative to the selector that was used."

	<category: 'accessing'>
	suggestedSelector := aSymbol
    ]
]

]
