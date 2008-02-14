"=====================================================================
|
|   MySQL DBI driver - Base class extensions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2002 Josh Miller
| Written by Josh Miller, ported by Markus Fritsche,
| refactored/rewritten by Paolo Bonzini
|
| Copyright 2003, 2007, 2008 Free Software Foundation, Inc.
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




ByteArray extend [

    asInteger [
	<category: 'accessing'>
	| shiftAmount anInteger |
	shiftAmount := 0.
	anInteger := 0.
	1 to: self size
	    do: 
		[:index | 
		anInteger := anInteger bitOr: ((self at: index) bitShift: shiftAmount).
		shiftAmount := shiftAmount + 8].
	^anInteger
    ]

    asByteString [
	<category: 'accessing'>
	| stream |
	stream := WriteStream on: String new.
	1 to: self size
	    do: [:x | stream nextPut: (Character value: (self basicAt: x))].
	^stream contents
    ]

]

