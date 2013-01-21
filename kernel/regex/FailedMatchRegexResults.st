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



Namespace current: Kernel [

RegexResults subclass: FailedMatchRegexResults [
    
    <category: 'Collections-Text'>
    <comment: nil>

    FailedMatchRegexResults class [
	| uniqueInstance |
	
    ]

    FailedMatchRegexResults class >> uniqueInstance [
	<category: 'private'>
	^uniqueInstance isNil 
	    ifTrue: [uniqueInstance := self new]
	    ifFalse: [uniqueInstance]
    ]

    matched [
	<category: 'testing'>
	^false
    ]

    ifMatched: oneArgBlock ifNotMatched: zeroArgBlock [
	<category: 'testing'>
	^zeroArgBlock cull: self
    ]

    ifNotMatched: zeroArgBlock ifMatched: oneArgBlock [
	<category: 'testing'>
	^zeroArgBlock cull: self
    ]

    size [
	<category: 'accessing'>
	self shouldNotImplement
    ]

    subject [
	<category: 'accessing'>
	self shouldNotImplement
    ]

    from [
	<category: 'accessing'>
	self shouldNotImplement
    ]

    fromAt: anIndex [
	<category: 'accessing'>
	self shouldNotImplement
    ]

    to [
	<category: 'accessing'>
	self shouldNotImplement
    ]

    toAt: anIndex [
	<category: 'accessing'>
	self shouldNotImplement
    ]

    match [
	<category: 'accessing'>
	self shouldNotImplement
    ]

    matchInterval [
	<category: 'accessing'>
	self shouldNotImplement
    ]

    at: anIndex [
	<category: 'accessing'>
	self shouldNotImplement
    ]

    intervalAt: anIndex [
	<category: 'accessing'>
	self shouldNotImplement
    ]
]

]
