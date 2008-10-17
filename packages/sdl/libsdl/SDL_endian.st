"======================================================================
|
|   SDL declarations 
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2006, 2008 Free Software Foundation, Inc.
| Written by Brad Watson
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


"======================================================================
|
|   Notes: implemented without callbacks.  
|  
 ======================================================================"

Object subclass: #SdlEndian
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

!SdlEndian class methodsFor: 'C call-outs'!

sdlReadLE16: aCobject0 
    "I read an item of the specified endianness and answer in native
    format. My C function call prototype:

    extern DECLSPEC Uint16 SDLCALL SDL_ReadLE16(SDL_RWops *src);"
    <cCall: 'SDL_ReadLE16' returning: #uInt
        args: #( #cObject  )>!

sdlReadBE16: aCobject0 
    "I read an item of the specified endianness and answer in native
    format. My C function call prototype:

     extern DECLSPEC Uint16 SDLCALL SDL_ReadBE16(SDL_RWops *src);"
    <cCall: 'SDL_ReadBE16' returning: #uInt
        args: #( #cObject  )>!

sdlReadLE32: aCobject0 
    "I read an item of the specified endianness and answer in native
    format. My C function call prototype:

     extern DECLSPEC Uint32 SDLCALL SDL_ReadLE32(SDL_RWops *src);"
    <cCall: 'SDL_ReadLE32' returning: #uInt
        args: #( #cObject  )>!

sdlReadBE32: aCobject0 
    "I read an item of the specified endianness and answer in native
    format. My C function call prototype:

     extern DECLSPEC Uint32 SDLCALL SDL_ReadBE32(SDL_RWops *src);"
    <cCall: 'SDL_ReadBE32' returning: #uInt
        args: #( #cObject  )>!

sdlReadLE64: aCobject0 
    "I read an item of the specified endianness and answer in native
    format. My C function call prototype:

     extern DECLSPEC Uint64 SDLCALL SDL_ReadLE64(SDL_RWops *src);"
    <cCall: 'SDL_ReadLE64' returning: #uLong
        args: #( #cObject  )>!

sdlReadBE64: aCobject0 
    "I read an item of the specified endianness and answer in native
    format. My C function call prototype:

     extern DECLSPEC Uint64 SDLCALL SDL_ReadBE64(SDL_RWops *src);"
    <cCall: 'SDL_ReadBE64' returning: #uLong
        args: #( #cObject  )>!

sdlWriteLE16: aCobject0 value: aUshort
    "I write an item of native format to the specified endianness. My
    C function call prototype:

    extern DECLSPEC int SDLCALL SDL_WriteLE16(SDL_RWops *dst, Uint16 value);"
    <cCall: 'SDL_WriteLE16' returning: #int 
        args: #( #cObject #uInt )>!

sdlWriteBE16: aCobject0 value: aUshort
    "I write an item of native format to the specified endianness. My
    C function call prototype:

     extern DECLSPEC int SDLCALL SDL_WriteBE16(SDL_RWops *dst, Uint16 value);"
    <cCall: 'SDL_WriteBE16' returning: #int 
        args: #( #cObject #uInt )>!

sdlWriteLE32: aCobject0 value: aUint
    "I write an item of native format to the specified endianness. My
    C function call prototype:

    extern DECLSPEC int SDLCALL SDL_WriteLE32(SDL_RWops *dst, Uint32 value);"
    <cCall: 'SDL_WriteLE32' returning: #int 
        args: #( #cObject #uInt )>!

sdlWriteBE32: aCobject0 value: aUint
    "I write an item of native format to the specified endianness. My
    C function call prototype:

    extern DECLSPEC int SDLCALL SDL_WriteBE32(SDL_RWops *dst, Uint32 value);"
    <cCall: 'SDL_WriteBE32' returning: #int 
        args: #( #cObject #uInt )>!

sdlWriteLE64: aCobject0 value: aUlong
    "I write an item of native format to the specified endianness. My
    C function call prototype:

    extern DECLSPEC int SDLCALL SDL_WriteLE64(SDL_RWops *dst, Uint64 value);"
    <cCall: 'SDL_WriteLE64' returning: #int 
       args: #( #cObject #uLong )>!

sdlWriteBE64: aCobject0 value: aUlong
    "I write an item of native format to the specified endianness. My
    C function call prototype:

    extern DECLSPEC int SDLCALL SDL_WriteBE64(SDL_RWops *dst, Uint64 value);"
    <cCall: 'SDL_WriteBE64' returning: #int 
        args: #( #cObject #uLong )>! !
