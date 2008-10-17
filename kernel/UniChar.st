"======================================================================
|
|   UnicodeCharacter Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2006, 2008 Free Software Foundation, Inc.
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



Character subclass: UnicodeCharacter [
    
    <category: 'Language-Data types'>
    <comment: 'My instances represent the over one million characters of the Unicode
character set.  It provides messages to translate between integers and
character objects.

UnicodeCharacter objects are created when accessing UnicodeStrings,
or with Character class>>#codePoint:.'>

    UnicodeCharacter class >> value: anInteger [
	"Returns the character object, possibly a Character, corresponding
	 to anInteger.  Error if anInteger is not an integer, or not in
	 0..16r10FFFF.
	 
	 This is only a primitive for speed.  UnicodeCharacter's #value:
	 method is equivalent to #codePoint: (which is the same for
	 Character and UnicodeCharacter)."

	<category: 'built ins'>
	<primitive: VMpr_UnicodeCharacter_create>
	anInteger isInteger 
	    ifFalse: 
		[SystemExceptions.WrongClass signalOn: anInteger mustBe: SmallInteger]
	    ifTrue: 
		[SystemExceptions.ArgumentOutOfRange 
		    signalOn: anInteger
		    mustBeBetween: 0
		    and: 1114111]
    ]

    * aNumber [
	"Returns a String with aNumber occurrences of the receiver."

	<category: 'coercion methods'>
	^UnicodeString new: aNumber withAll: self
    ]
]

