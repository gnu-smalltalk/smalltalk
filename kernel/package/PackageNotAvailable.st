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



Namespace current: SystemExceptions [

NotFound subclass: PackageNotAvailable [
    
    <category: 'Language-Packaging'>
    <comment: nil>

    PackageNotAvailable class >> signal: aString [
	"Signal an exception saying that the package named aString
	 can't be found."
	^super signalOn: aString what: 'package'
    ]

    PackageNotAvailable class >> signal: package reason: reason [
	"Signal an exception saying that be package named package
	 can't be found because the reason named reason."
	^super signalOn: package reason: reason
    ]

    isResumable [
        "Answer true.  Package unavailability is resumable, because the
	 package files might just lie elsewhere."

        <category: 'description'>
        ^true
    ]
]

]

