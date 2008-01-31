"======================================================================
|
|   C type declaration scalar data types, part of the C header parser.
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1993, 1999, 2008 Free Software Foundation, Inc.
| Written by Steve Byrne.
|
| This file is part of GNU Smalltalk.
|
| GNU Smalltalk is free software; you can redistribute it and/or modify it
| under the terms of the GNU General Public License as published by the Free
| Software Foundation; either version 2, or (at your option) any later version.
| 
| GNU Smalltalk is distributed in the hope that it will be useful, but WITHOUT
| ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
| FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
| details.
| 
| You should have received a copy of the GNU General Public License along with
| GNU Smalltalk; see the file COPYING.  If not, write to the Free Software
| Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
|
 ======================================================================"

"Base class for C symbol table entries"

Object subclass: #CSymbol
       instanceVariableNames: 'name type scope'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

"Not clear at the moment how these are created, so we will leave the creation
out for a while."

" See CSymbolTable for the right approach (enum name space, struct name space, etc. "

!CSymbol methodsFor: 'accessing'!

name
    ^name
!

name: aName
    name _ aName
!

type
    ^type
!

type: aType
    type _ aType
!

scope
    ^scope
!

scope: scopeType
    scope _ scopeType
! !





"base data types are

int, float, short, char, double, unsigned

struct, union (class) are types too?

aggregators are

ptr (to type)
array (of type, lengty)
function (returning type) (arg types)

Additional modifiers
const, volatile

why bother differentiating?  It's a CLangType instance, some of which may
be more complicated, some of which are not.
"


Object subclass: #CLangType
       instanceVariableNames: 'qualifier'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

!CLangType methodsFor: 'accessing'!

qualifier
    ^qualifier
!

qualifier: aSymbol
    qualifier _ aSymbol
! !


!CLangType methodsFor: 'declaring'!

declareInto: symbolTable
    "scalar data types do not store themselves in the symbol table"
    ^self
! !


!CLangType methodsFor: 'printing'!

printOn: aStream
    aStream nextPutAll: self class name.
!

storeOn: aStream
    aStream nextPutAll: self class name; nextPutAll: ' new'.
! !


CLangType subclass: #CLangChar
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

CLangType subclass: #CLangUnsignedChar
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

CLangType subclass: #CLangShort
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

CLangType subclass: #CLangUnsignedShort
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 


CLangType subclass: #CLangInt
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

CLangType subclass: #CLangUnsignedInt
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 


CLangType subclass: #CLangLong
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

CLangType subclass: #CLangUnsignedLong
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

CLangType subclass: #CLangFloat
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

CLangType subclass: #CLangDouble
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

CLangType subclass: #CLangBitfield
       instanceVariableNames: 'baseType length'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

!CLangBitfield class methodsFor: 'instance creation'!

type: aBaseType length: anInteger
    ^self new init: aBaseType length: anInteger
! !

!CLangBitfield methodsFor: 'private'!

init: aBaseType length: anInteger
    baseType _ aBaseType.
    length _ anInteger
! !


CLangType subclass: #CLangStruct
       instanceVariableNames: 'typeName members'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

!CLangStruct methodsFor: 'accessing'!

typeName
    ^typeName
!

typeName: aName
    typeName _ aName
!

members
    ^members
!

members: aCollection
    members _ aCollection	"should this be 'a symbol table?'"
! !


CLangType subclass: #CLangArray
       instanceVariableNames: 'subType length'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

!CLangArray methodsFor: 'accessing'!

subType
    ^subType
!

subType: aType
    subType _ aType
!

length
    ^length
!

length: anInteger
    length _ anInteger
! !


CLangType subclass: #CLangPtr
       instanceVariableNames: 'subType'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

!CLangPtr methodsFor: 'accessing'!

subType
    ^subType
!

subType: aType
    subType _ aType
! !


CLangType subclass: #CLangFunction
       instanceVariableNames: 'returnType argTypes'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

!CLangFunction class methodsFor: 'instance creation'!

returnType: aType argList: argTypeList
    ^self new init: aType argList: argTypeList
! !


!CLangFunction methodsFor: 'accessing'!

returnType
    ^returnType
!

argTypes
    ^argTypes
! !

!CLangFunction methodsFor: 'private'!

init: aType argList: argTypeList
    returnType _ aType.
    argTypes _ argTypeList.
! !


CLangType subclass: #CLangEnum
       instanceVariableNames: 'literals' "counter?"
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

!CLangEnum methodsFor: 'accessing'!

literals
    ^literals
!

literals: anOrderedCollection
    literals _ anOrderedCollection
! !


CLangType subclass: #CLangEnumLiteral
       instanceVariableNames: 'name value'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

!CLangEnumLiteral methodsFor: 'accessing'!

name
    ^name
!

name: aName
    name _ aName
!

value
    ^value
!

value: anInteger
    value _ anInteger
! !


CLangType subclass: #CLangVoid
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 


