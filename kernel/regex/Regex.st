"======================================================================
|
|   String manipulation and regular expression resolver
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2001, 2003, 2005, 2006, 2007, 2008, 2009
| Free Software Foundation, Inc.
| Written by Dragomir Milevojevic, Paolo Bonzini, Mike Anderson.
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
| along with the GNU Smalltalk class library; see the file COPYING.LESSER.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"



Object subclass: Regex [
    
    <shape: #character>
    <category: 'Collections-Text'>
    <comment: '
A Regex is a read-only string for which the regular expression matcher
can cache a compiled representation, thus speeding up matching.  Regex
objects are constructed automatically by methods that expect to match many
times the same regular expression, but can also be constructed explicitly
sending #asRegex to a String or Symbol.

Creation of Regex objects inside a loop is of course slower than creating
them outside the loop, but special care is taken so that the same Regex
object is used whenever possible (when converting Strings to Regex, the
cache is sought for an equivalent, already constructed Regex).'>

    Regex class >> fromString: aString [
	"Like `aString asRegex'."
	<category: 'instance creation'>
	<cCall: 'reh_make_cacheable' returning: #smalltalk args: #(#smalltalk)>
	
    ]

    Regex class >> new [
	"Do not send this message."
	<category: 'instance creation'>
	self error: 'please use #fromString: to create instances'
    ]

    at: anIndex put: anObject [
	"Fail.  Regex objects are read-only."

	<category: 'basic'>
	self shouldNotImplement
    ]

    copy [
	"Answer the receiver; instances of Regex are identity objects because
	 their only purpose is to ease caching, and we obtain better caching
	 if we avoid copying Regex objects"

	<category: 'basic'>
	^self
    ]

    asRegex [
	"Answer the receiver, which *is* a Regex!"

	<category: 'conversion'>
	^self
    ]

    asString [
	"Answer the receiver, converted back to a String"

	<category: 'conversion'>
	^(String new: self size)
	    replaceFrom: 1
		to: self size
		with: self
		startingAt: 1;
	    yourself
    ]

    species [
	<category: 'conversion'>
	^String
    ]

    displayString [
	"Answer a String representing the receiver. For most objects
	 this is simply its #printString, but for strings and characters,
	 superfluous dollars or extra pair of quotes are stripped."

	<category: 'printing'>
	| stream |
	stream := WriteStream on: (String new: 0).
	self displayOn: stream.
	^stream contents
    ]

    displayOn: aStream [
	"Print a represention of the receiver on aStream. For most objects
	 this is simply its #printOn: representation, but for strings and
	 characters, superfluous dollars or extra pairs of quotes are stripped."

	<category: 'printing'>
	self printOn: aStream
    ]

    printOn: aStream [
	"Print a represention of the receiver on aStream."

	<category: 'printing'>
	aStream nextPut: $/.
	self asString do: 
		[:each | 
		each = $/ ifTrue: [ aStream nextPut: $\ ].
		aStream nextPut: each].
	aStream nextPut: $/
    ]
]

