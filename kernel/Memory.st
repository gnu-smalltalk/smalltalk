"======================================================================
|
|   Memory definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2003
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



Object subclass: Memory [
    
    <category: 'Language-Implementation'>
    <comment: 'I provide access to actual machine addresses of OOPs and objects.  I
have no instances; you send messages to my class to map between an object
and the address of its OOP or object. In addition I provide direct
memory access with different C types (ints, chars, OOPs, floats,...).'>

    Memory class >> at: anAddress [
	"Access the Smalltalk object (OOP) at the given address."

	<category: 'accessing'>
	^self type: 9 at: anAddress
    ]

    Memory class >> bigEndian [
	"Answer whether we're running on a big- or little-endian system."

	<category: 'accessing'>
	^Bigendian
    ]

    Memory class >> charAt: anAddress [
	"Access the C char at the given address. The value is
	 returned as a Smalltalk Character."

	<category: 'accessing'>
	^self type: 0 at: anAddress
    ]

    Memory class >> unsignedCharAt: anAddress [
	"Access the C unsigned char at the given address.
	 The value is returned as a Smalltalk Character."

	<category: 'accessing'>
	^self type: 1 at: anAddress
    ]

    Memory class >> shortAt: anAddress [
	"Access the C short int at the given address."

	<category: 'accessing'>
	^self type: 2 at: anAddress
    ]

    Memory class >> unsignedShortAt: anAddress [
	"Access the C unsigned short int at the given address."

	<category: 'accessing'>
	^self type: 3 at: anAddress
    ]

    Memory class >> longAt: anAddress [
	"Access the C long int at the given address."

	<category: 'accessing'>
	^self type: 4 at: anAddress
    ]

    Memory class >> unsignedLongAt: anAddress [
	"Access the C unsigned long int at the given address."

	<category: 'accessing'>
	^self type: 5 at: anAddress
    ]

    Memory class >> intAt: anAddress [
	"Access the C int at the given address."

	<category: 'accessing'>
	^self type: 10 at: anAddress
    ]

    Memory class >> unsignedIntAt: anAddress [
	"Access the C unsigned int at the given address."

	<category: 'accessing'>
	^self type: 11 at: anAddress
    ]

    Memory class >> floatAt: anAddress [
	"Access the C float at the given address."

	<category: 'accessing'>
	^self type: 6 at: anAddress
    ]

    Memory class >> doubleAt: anAddress [
	"Access the C double at the given address."

	<category: 'accessing'>
	^self type: 7 at: anAddress
    ]

    Memory class >> longDoubleAt: anAddress [
	"Access the C long double at the given address."

	<category: 'accessing'>
	^self type: 12 at: anAddress
    ]

    Memory class >> stringAt: anAddress [
	"Access the string pointed by the C `char *' at the given given address."

	<category: 'accessing'>
	^self type: 8 at: anAddress
    ]

    Memory class >> deref: anAddress [
	"Access the C int pointed by the given address"

	<category: 'accessing'>
	^self intAt: anAddress
    ]

    Memory class >> at: anAddress put: aValue [
	"Store a pointer (OOP) to the Smalltalk object identified by `value'
	 at the given address."

	<category: 'accessing'>
	^self 
	    type: 9
	    at: anAddress
	    put: aValue
    ]

    Memory class >> intAt: anAddress put: aValue [
	"Store the Smalltalk Integer object identified by `value', at the
	 given address, using sizeof(int) bytes."

	<category: 'accessing'>
	^self 
	    type: 10
	    at: anAddress
	    put: aValue
    ]

    Memory class >> unsignedIntAt: anAddress put: aValue [
	"Store the Smalltalk Integer object identified by `value', at the
	 given address, using sizeof(int) bytes."

	<category: 'accessing'>
	^self 
	    type: 11
	    at: anAddress
	    put: aValue
    ]

    Memory class >> uintAt: anAddress put: aValue [
	"Store the Smalltalk Integer object identified by `value', at the
	 given address, using sizeof(int) bytes."

	<category: 'accessing'>
	^self 
	    type: 11
	    at: anAddress
	    put: aValue
    ]

    Memory class >> charAt: anAddress put: aValue [
	"Store as a C char the Smalltalk Character or Integer object
	 identified by `value', at the given address, using sizeof(char)
	 bytes - i.e. 1 byte."

	<category: 'accessing'>
	^self 
	    type: 0
	    at: anAddress
	    put: aValue
    ]

    Memory class >> unsignedCharAt: anAddress put: aValue [
	"Store as a C char the Smalltalk Character or Integer object
	 identified by `value', at the given address, using sizeof(char)
	 bytes - i.e. 1 byte."

	<category: 'accessing'>
	^self 
	    type: 1
	    at: anAddress
	    put: aValue
    ]

    Memory class >> ucharAt: anAddress put: aValue [
	"Store as a C char the Smalltalk Character or Integer object
	 identified by `value', at the given address, using sizeof(char)
	 bytes - i.e. 1 byte."

	<category: 'accessing'>
	^self 
	    type: 1
	    at: anAddress
	    put: aValue
    ]

    Memory class >> shortAt: anAddress put: aValue [
	"Store the Smalltalk Integer object identified by `value', at the
	 given address, using sizeof(short) bytes."

	<category: 'accessing'>
	^self 
	    type: 2
	    at: anAddress
	    put: aValue
    ]

    Memory class >> unsignedShortAt: anAddress put: aValue [
	"Store the Smalltalk Integer object identified by `value', at the
	 given address, using sizeof(short) bytes."

	<category: 'accessing'>
	^self 
	    type: 3
	    at: anAddress
	    put: aValue
    ]

    Memory class >> ushortAt: anAddress put: aValue [
	"Store the Smalltalk Integer object identified by `value', at the
	 given address, using sizeof(short) bytes."

	<category: 'accessing'>
	^self 
	    type: 3
	    at: anAddress
	    put: aValue
    ]

    Memory class >> longAt: anAddress put: aValue [
	"Store the Smalltalk Integer object identified by `value', at the
	 given address, using sizeof(long) bytes."

	<category: 'accessing'>
	^self 
	    type: 4
	    at: anAddress
	    put: aValue
    ]

    Memory class >> unsignedLongAt: anAddress put: aValue [
	"Store the Smalltalk Integer object identified by `value', at the
	 given address, using sizeof(long) bytes."

	<category: 'accessing'>
	^self 
	    type: 5
	    at: anAddress
	    put: aValue
    ]

    Memory class >> ulongAt: anAddress put: aValue [
	"Store the Smalltalk Integer object identified by `value', at the
	 given address, using sizeof(long) bytes."

	<category: 'accessing'>
	^self 
	    type: 5
	    at: anAddress
	    put: aValue
    ]

    Memory class >> floatAt: anAddress put: aValue [
	"Store the Smalltalk Float object identified by `value', at the
	 given address, writing it like a C float."

	<category: 'accessing'>
	^self 
	    type: 6
	    at: anAddress
	    put: aValue
    ]

    Memory class >> doubleAt: anAddress put: aValue [
	"Store the Smalltalk Float object identified by `value', at the
	 given address, writing it like a C double."

	<category: 'accessing'>
	^self 
	    type: 7
	    at: anAddress
	    put: aValue
    ]

    Memory class >> longDoubleAt: anAddress put: aValue [
	"Store the Smalltalk Float object identified by `value', at the
	 given address, writing it like a C long double."

	<category: 'accessing'>
	^self 
	    type: 12
	    at: anAddress
	    put: aValue
    ]

    Memory class >> stringAt: anAddress put: aValue [
	"Store the Smalltalk String object identified by `value', at the
	 given address in memory, writing it like a *FRESHLY ALLOCATED*
	 C string. It is the caller's responsibility to free it if
	 necessary."

	<category: 'accessing'>
	^self 
	    type: 8
	    at: anAddress
	    put: aValue
    ]

    Memory class >> type: aType at: anAddress [
	"Returns a particular type object from memory at anAddress"

	<category: 'private'>
	<primitive: VMpr_Memory_at>
	^self primitiveFailed
    ]

    Memory class >> type: aType at: anAddress put: aValue [
	"Sets the memory location anAddress to aValue"

	<category: 'private'>
	<primitive: VMpr_Memory_atPut>
	^self primitiveFailed
    ]
]

