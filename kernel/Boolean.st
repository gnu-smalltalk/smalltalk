"======================================================================
|
|   Boolean Method Definitions
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



Object subclass: Boolean [
    
    <category: 'Language-Data types'>
    <comment: 'I have two instances in the Smalltalk system: true and false.  I provide
methods that are conditional on boolean values, such as conditional
execution and loops, and conditional testing, such as conditional and and
conditional or.  I should say that I appear to provide those operations; 
my subclasses True and False actually provide those operations.'>

    Boolean class >> isIdentity [
	"Answer whether x = y implies x == y for instances of the receiver"

	<category: 'testing'>
	^true
    ]

    Boolean class >> isImmediate [
	"Answer whether, if x is an instance of the receiver, x copy == x"

	<category: 'testing'>
	^true
    ]

    shallowCopy [
	<category: 'overriding'>
	^self	"We only have one instance"
    ]

    deepCopy [
	<category: 'overriding'>
	^self	"it's about as deep as we need to get"
    ]

    isLiteralObject [
	"Answer whether the receiver is expressible as a Smalltalk literal."

	<category: 'storing'>
	^true
    ]

    storeLiteralOn: aStream [
	"Store on aStream some Smalltalk code which compiles to the receiver"

	<category: 'storing'>
	self storeOn: aStream
    ]

    storeOn: aStream [
	"Store on aStream some Smalltalk code which compiles to the receiver"

	<category: 'storing'>
	self printOn: aStream	"representation is the same"
    ]

    asCBooleanValue [
	<category: 'C hacks'>
	self subclassResponsibility
    ]

    ifTrue: trueBlock ifFalse: falseBlock [
	<category: 'basic'>
	self subclassResponsibility
    ]

    ifFalse: falseBlock ifTrue: trueBlock [
	<category: 'basic'>
	self subclassResponsibility
    ]

    ifTrue: trueBlock [
	<category: 'basic'>
	self subclassResponsibility
    ]

    ifFalse: falseBlock [
	<category: 'basic'>
	self subclassResponsibility
    ]

    not [
	<category: 'basic'>
	self subclassResponsibility
    ]

    & aBoolean [
	<category: 'basic'>
	self subclassResponsibility
    ]

    | aBoolean [
	<category: 'basic'>
	self subclassResponsibility
    ]

    eqv: aBoolean [
	<category: 'basic'>
	self subclassResponsibility
    ]

    xor: aBoolean [
	<category: 'basic'>
	self subclassResponsibility
    ]

    and: aBlock [
	<category: 'basic'>
	self subclassResponsibility
    ]

    or: aBlock [
	<category: 'basic'>
	self subclassResponsibility
    ]
]

