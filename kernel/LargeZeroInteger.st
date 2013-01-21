"======================================================================
|
|   LargeInteger hierarchy Method Definitions
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



LargePositiveInteger subclass: LargeZeroInteger [
    
    <shape: #byte>
    <category: 'Language-Data types'>
    <comment: '
I am quite a strange class. Indeed, the concept of a "large integer"
that is zero is a weird one. Actually my only instance is zero but
is represented like LargeIntegers, has the same generality as
LargeIntegers, and so on. That only instance is stored in the class
variable Zero, and is used in arithmetical methods, when we have to
coerce a parameter that is zero.'>

    size [
	<category: 'accessing'>
	^0
    ]

    hash [
	<category: 'accessing'>
	^0
    ]

    at: anIndex [
	<category: 'accessing'>
	^0
    ]

    strictlyPositive [
	"Answer whether the receiver is > 0"

	<category: 'numeric testing'>
	^false
    ]

    sign [
	"Answer the receiver's sign"

	<category: 'numeric testing'>
	^0
    ]

    + aNumber [
	"Sum the receiver and aNumber, answer the result"

	<category: 'arithmetic'>
	^aNumber
    ]

    - aNumber [
	"Subtract aNumber from the receiver, answer the result"

	<category: 'arithmetic'>
	^aNumber negated
    ]

    * aNumber [
	"Multiply aNumber and the receiver, answer the result"

	<category: 'arithmetic'>
	^0
    ]

    / aNumber [
	"Divide aNumber and the receiver, answer the result (an Integer or
	 Fraction)"

	<category: 'arithmetic'>
	^0
    ]

    // aNumber [
	"Divide aNumber and the receiver, answer the result truncated towards
	 -infinity"

	<category: 'arithmetic'>
	^0
    ]

    rem: aNumber [
	"Divide aNumber and the receiver, answer the remainder truncated
	 towards 0"

	<category: 'arithmetic'>
	^0
    ]

    quo: aNumber [
	"Divide aNumber and the receiver, answer the result truncated
	 towards 0"

	<category: 'arithmetic'>
	^0
    ]

    \\ aNumber [
	"Divide aNumber and the receiver, answer the remainder truncated
	 towards -infinity"

	<category: 'arithmetic'>
	^0
    ]

    replace: str withStringBase: radix [
	"Return in a string the base radix representation of the receiver."

	<category: 'printing'>
	str at: str size put: $0.
	^str
    ]
]

