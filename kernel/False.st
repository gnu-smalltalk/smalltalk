"======================================================================
|
|   False Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001
| Free Software Foundation, Inc.
| Written by Steve Byrne.
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



Boolean subclass: False [
    | truthValue |
    
    <category: 'Language-Data types'>
    <comment: 'I always tell lies. 
I have a single instance in the system, which represents the value false.'>

    asCBooleanValue [
	<category: 'C hacks'>
	^0
    ]

    ifTrue: trueBlock ifFalse: falseBlock [
	"We are false -- evaluate the falseBlock"

	<category: 'basic'>
	^falseBlock value
    ]

    ifFalse: falseBlock ifTrue: trueBlock [
	"We are false -- evaluate the falseBlock"

	<category: 'basic'>
	^falseBlock value
    ]

    ifTrue: trueBlock [
	"We are false -- answer nil"

	<category: 'basic'>
	^nil
    ]

    ifFalse: falseBlock [
	"We are false -- evaluate the falseBlock"

	<category: 'basic'>
	^falseBlock value
    ]

    not [
	"We are false -- answer true"

	<category: 'basic'>
	^true
    ]

    & aBoolean [
	"We are false -- anded with anything, we always answer false"

	<category: 'basic'>
	^false
    ]

    | aBoolean [
	"We are false -- ored with anything, we always answer the other operand"

	<category: 'basic'>
	^aBoolean
    ]

    eqv: aBoolean [
	"Answer whether the receiver and aBoolean represent the
	 same boolean value"

	<category: 'basic'>
	^aBoolean not
    ]

    xor: aBoolean [
	"Answer whether the receiver and aBoolean represent different
	 boolean values"

	<category: 'basic'>
	^aBoolean
    ]

    and: aBlock [
	"We are false -- anded with anything, we always answer false"

	<category: 'basic'>
	^false
    ]

    or: aBlock [
	"We are false -- ored with anything, we always answer the other operand,
	 so evaluate aBlock"

	<category: 'basic'>
	^aBlock value
    ]

    printOn: aStream [
	"Print a representation of the receiver on aStream"

	<category: 'printing'>
	aStream nextPutAll: 'false'
    ]
]

