"======================================================================
|
|   SymLink Method Definitions
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



Link subclass: SymLink [
    | symbol |
    
    <category: 'Language-Implementation'>
    <comment: 'I am used to implement the Smalltalk symbol table.  My instances are
links that contain symbols, and the symbol table basically a hash table that
points to chains of my instances.'>

    SymLink class >> symbol: aSymbol nextLink: aSymLink [
	"Answer a new SymLink, which refers to aSymbol and points to
	 aSymLink as the next SymLink in the chain."

	<category: 'instance creation'>
	^(self nextLink: aSymLink)
	    symbol: aSymbol;
	    yourself
    ]

    do: aBlock [
	"Evaluate aBlock for each symbol in the list"

	<category: 'iteration'>
	| item |
	item := self.
	
	[aBlock value: item symbol.
	(item := item nextLink) isNil] whileFalse
    ]

    symbol [
	"Answer the Symbol that the receiver refers to in the symbol table."

	<category: 'accessing'>
	^symbol
    ]

    symbol: aSymbol [
	"Set the Symbol that the receiver refers to in the symbol table."

	<category: 'accessing'>
	symbol := aSymbol
    ]

    printOn: aStream [
	"Print a representation of the receiver on aStream."

	<category: 'printing'>
	aStream nextPut: $[.
	self do: 
		[:elt | 
		elt printOn: aStream.
		aStream nextPut: Character space].
	aStream nextPut: $]
    ]
]

