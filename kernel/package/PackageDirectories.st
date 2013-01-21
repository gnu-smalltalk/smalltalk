"======================================================================
|
|   PackageLoader Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999,2000,2001,2002,2003,2004,2005,2007,2008,2009
| Free Software Foundation, Inc.
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



Namespace current: Kernel [

PackageGroup subclass: PackageDirectories [
    | dirs |
    
    <category: 'Language-Packaging'>
    <comment: 'I am not part of a standard Smalltalk system. I store internally the
information on a Smalltalk package, and can output my description in
XML.'>

    PackageDirectories class >> new [
	<category: 'instance creation'>
	^super new initialize
    ]

    postCopy [
	<category: 'copying'>
	dirs := dirs copy
    ]

    add: aDirectory [
	<category: 'accessing'>
	^dirs add: aDirectory
    ]

    at: aString ifAbsent: aBlock [
	<category: 'accessing'>
	dirs do: 
		[:each | 
		| package |
		package := each at: aString ifAbsent: [nil].
		package isNil ifFalse: [^package]].
	^aBlock value
    ]

    keys [
	<category: 'accessing'>
	| keys |
	keys := Set new.
	dirs do: [:each | keys addAll: each keys].
	^keys
    ]

    includesKey: aString [
	<category: 'accessing'>
	^dirs anySatisfy: [:each | each includesKey: aString]
    ]

    refresh: aLoadDate [
	<category: 'accessing'>
	dirs do: [:each | each refresh: aLoadDate]
    ]

    initialize [
	<category: 'initializing'>
	dirs := OrderedCollection new
    ]
]

]

