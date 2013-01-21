"======================================================================
|
|   ValueAdaptor hierarchy Method Definitions
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



ValueAdaptor subclass: PluggableAdaptor [
    | getBlock putBlock |
    
    <category: 'Language-Data types'>
    <comment: 'I mediate between complex get/set behavior and the #value/#value:
protocol used by ValueAdaptors. The get/set behavior can be implemented
by two blocks, or can be delegated to another object with messages 
such as #someProperty to get and #someProperty: to set.'>

    PluggableAdaptor class >> getBlock: getBlock putBlock: putBlock [
	"Answer a PluggableAdaptor using the given blocks to implement
	 #value and #value:"

	<category: 'creating instances'>
	^self basicNew getBlock: getBlock putBlock: putBlock
    ]

    PluggableAdaptor class >> on: anObject getSelector: getSelector putSelector: putSelector [
	"Answer a PluggableAdaptor using anObject's getSelector message to
	 implement #value, and anObject's putSelector message to implement
	 #value:"

	<category: 'creating instances'>
	^self basicNew getBlock: [anObject perform: getSelector]
	    putBlock: [:value | anObject perform: putSelector with: value]
    ]

    PluggableAdaptor class >> on: anObject aspect: aSymbol [
	"Answer a PluggableAdaptor using anObject's aSymbol message to
	 implement #value, and anObject's aSymbol: message (aSymbol
	 followed by a colon) to implement #value:"

	<category: 'creating instances'>
	^self 
	    on: anObject
	    getSelector: aSymbol
	    putSelector: (aSymbol , ':') asSymbol
    ]

    PluggableAdaptor class >> on: anObject index: anIndex [
	"Answer a PluggableAdaptor using anObject's #at: and #at:put:
	 message to implement #value and #value:; the first parameter
	 of #at: and #at:put: is anIndex"

	<category: 'creating instances'>
	^self getBlock: [anObject at: anIndex]
	    putBlock: [:value | anObject at: anIndex put: value]
    ]

    PluggableAdaptor class >> on: aDictionary key: aKey [
	"Same as #on:index:. Provided for clarity and completeness."

	<category: 'creating instances'>
	^self on: aDictionary index: aKey
    ]

    value: anObject [
	"Set the value of the receiver."

	<category: 'accessing'>
	putBlock value: anObject
    ]

    value [
	"Get the value of the receiver."

	<category: 'accessing'>
	^getBlock value
    ]

    getBlock: get putBlock: put [
	<category: 'private'>
	getBlock := get.
	putBlock := put.
	^self
    ]
]
