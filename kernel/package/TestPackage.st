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

Smalltalk.Package subclass: TestPackage [
    | owner |
    
    <category: 'Language-Packaging'>
    <comment: 'I am not part of a standard Smalltalk system.  I am an unnamed
subpackage of a regular package, representing an SUnit test suite for
that package.

    owner
	The Package I provide tests for; initialized by the owner.'>

    owner: aPackage [
	"Set the Package I test."

	<category: 'accessing'>
	owner := aPackage
    ]

    url [
	"Answer the URL at which the package repository can be found."

	<category: 'accessing'>
	^super url ifNil: [owner url]
    ]

    namespace [
	"Answer the namespace in which the package is loaded."

	<category: 'accessing'>
	^super namespace ifNil: [owner namespace]
    ]

    baseDirectories [
	"Answer the directories in which package files are sought."

	<category: 'accessing'>
	^super baseDirectories ifNil: 
		[owner baseDirectories 
		    collect: [:each | each / owner relativeDirectory]]
    ]
]

]

