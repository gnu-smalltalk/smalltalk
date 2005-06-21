"======================================================================
|
|   Memory definitions
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


Object variableWordSubclass: #Memory
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: 'Language-Implementation'
!

Memory comment:
'I provide access to actual machine addresses of OOPs and objects.  I
have no instances; you send messages to my class to map between an object
and the address of its OOP or object. In addition I provide direct
memory access with different C types (ints, chars, OOPs, floats,...).'  !



!Memory class methodsFor: 'accessing'!

"Note that the types could be given symbolic names and installed in a 
class variable, or could be methods that return the proper values (such as
the priorities for processes)."

at: anAddress
    "Access the Smalltalk object (OOP) at the given address."
    ^self type: 9 at: anAddress
!

bigEndian
    "Answer whether we're running on a big- or little-endian system."
    ^Bigendian
!

charAt: anAddress
    "Access the C char at the given address. The value is
     returned as a Smalltalk Character."
    ^self type: 0 at: anAddress
!

unsignedCharAt: anAddress
    "Access the C unsigned char at the given address.
     The value is returned as a Smalltalk Character."
    ^self type: 1 at: anAddress
!

shortAt: anAddress
    "Access the C short int at the given address."
    ^self type: 2 at: anAddress
!

unsignedShortAt: anAddress
    "Access the C unsigned short int at the given address."
    ^self type: 3 at: anAddress
!

longAt: anAddress
    "Access the C long int at the given address."
    ^self type: 4 at: anAddress
!

unsignedLongAt: anAddress
    "Access the C unsigned long int at the given address."
    ^self type: 5 at: anAddress
!

intAt: anAddress
    "Access the C int at the given address."
    ^self type: 10 at: anAddress
!

unsignedIntAt: anAddress
    "Access the C unsigned int at the given address."
    ^self type: 11 at: anAddress
!

floatAt: anAddress
    "Access the C float at the given address."
    ^self type: 6 at: anAddress
!

doubleAt: anAddress
    "Access the C double at the given address."
    ^self type: 7 at: anAddress
!

stringAt: anAddress
    "Access the string pointed by the C `char *' at the given given address."
    ^self type: 8 at: anAddress
!

deref: anAddress
    "Access the C int pointed by the given address"
    ^self intAt: anAddress
! 


"Storing methods"

at: anAddress put: aValue
    "Store a pointer (OOP) to the Smalltalk object identified by `value'
     at the given address."
    ^self type: 9 at: anAddress put: aValue
!

intAt: anAddress put: aValue
    "Store the Smalltalk Integer object identified by `value', at the
     given address, using sizeof(int) bytes."
    ^self type: 10 at: anAddress put: aValue
!

unsignedIntAt: anAddress put: aValue
    "Store the Smalltalk Integer object identified by `value', at the
     given address, using sizeof(int) bytes."
    ^self type: 11 at: anAddress put: aValue
!

uintAt: anAddress put: aValue
    "Store the Smalltalk Integer object identified by `value', at the
     given address, using sizeof(int) bytes."
    ^self type: 11 at: anAddress put: aValue
!

charAt: anAddress put: aValue
    "Store as a C char the Smalltalk Character or Integer object
     identified by `value', at the given address, using sizeof(char)
     bytes - i.e. 1 byte."
    ^self type: 0 at: anAddress put: aValue
!

unsignedCharAt: anAddress put: aValue
    "Store as a C char the Smalltalk Character or Integer object
     identified by `value', at the given address, using sizeof(char)
     bytes - i.e. 1 byte."
    ^self type: 1 at: anAddress put: aValue
!

ucharAt: anAddress put: aValue
    "Store as a C char the Smalltalk Character or Integer object
     identified by `value', at the given address, using sizeof(char)
     bytes - i.e. 1 byte."
    ^self type: 1 at: anAddress put: aValue
!

shortAt: anAddress put: aValue
    "Store the Smalltalk Integer object identified by `value', at the
     given address, using sizeof(short) bytes."
    ^self type: 2 at: anAddress put: aValue
!

unsignedShortAt: anAddress put: aValue
    "Store the Smalltalk Integer object identified by `value', at the
     given address, using sizeof(short) bytes."
    ^self type: 3 at: anAddress put: aValue
!

ushortAt: anAddress put: aValue
    "Store the Smalltalk Integer object identified by `value', at the
     given address, using sizeof(short) bytes."
    ^self type: 3 at: anAddress put: aValue
!

longAt: anAddress put: aValue
    "Store the Smalltalk Integer object identified by `value', at the
     given address, using sizeof(long) bytes."
    ^self type: 4 at: anAddress put: aValue
!

unsignedLongAt: anAddress put: aValue
    "Store the Smalltalk Integer object identified by `value', at the
     given address, using sizeof(long) bytes."
    ^self type: 5 at: anAddress put: aValue
!

ulongAt: anAddress put: aValue
    "Store the Smalltalk Integer object identified by `value', at the
     given address, using sizeof(long) bytes."
    ^self type: 5 at: anAddress put: aValue
!

floatAt: anAddress put: aValue
    "Store the Smalltalk Float object identified by `value', at the
     given address, writing it like a C float."
    ^self type: 6 at: anAddress put: aValue
!

doubleAt: anAddress put: aValue
    "Store the Smalltalk Float object identified by `value', at the
     given address, writing it like a C double."
    ^self type: 7 at: anAddress put: aValue
!

stringAt: anAddress put: aValue
    "Store the Smalltalk String object identified by `value', at the
     given address in memory, writing it like a *FRESHLY ALLOCATED*
     C string. It is the caller's responsibility to free it if
     necessary."
    ^self type: 8 at: anAddress put: aValue
! !


