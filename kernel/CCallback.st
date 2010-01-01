"======================================================================
|
|   CCallbackDescriptor Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2008, 2009 Free Software Foundation, Inc.
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



CCallable subclass: CCallbackDescriptor [
    | block |
    
    <shape: #inherit>
    <category: 'Language-C interface'>
    <comment: 'I am not part of the Smalltalk definition.  My instances are
able to convert blocks into C functions that can be passed to C.'>

    CCallbackDescriptor class >> for: aBlock returning: returnTypeSymbol withArgs: argsArray [
	"Answer a CCallbackDescriptor with the given block, return type and
	 arguments."

	<category: 'instance creation'>
	^(super for: nil returning: returnTypeSymbol withArgs: argsArray)
	    block: aBlock;
	    link;
	    yourself
    ]

    block [
	"Answer the block of the function represented by the receiver."

	<category: 'accessing'>
	^block
    ]

    block: aBlock [
	"Set the block of the function represented by the receiver."

	<category: 'accessing'>
	block := aBlock
    ]

    link [
	"Make the address of the function point to the registered address."

	<category: 'restoring'>
	<primitive: VMpr_CCallbackDescriptor_link>

	"Always executed."
	self addToBeFinalized
    ]
]
