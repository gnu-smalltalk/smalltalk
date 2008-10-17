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

Object subclass: #SdlRWOps
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

!SdlRWOps class methodsFor: 'C call-outs'!

sdlRWFromFile: aString0 mode: aString1 
    "extern DECLSPEC SDL_RWops * SDLCALL SDL_RWFromFile(const char *file, 
         const char *mode);"
    <cCall: 'SDL_RWFromFile' returning: #cObject 
        args: #( #string #string  )>!

sdlRWFromFp: aCobject0 autoClose: aInt1 
    "extern DECLSPEC SDL_RWops * SDLCALL SDL_RWFromFP(FILE *fp, 
         int autoclose);"
    <cCall: 'SDL_RWFromFP' returning: #cObject 
        args: #( #cObject #int  )>!

sdlRWFromMem: aCobject0 size: aInt1 
    "extern DECLSPEC SDL_RWops * SDLCALL SDL_RWFromMem(void *mem, 
         int size);"
    <cCall: 'SDL_RWFromMem' returning: #cObject 
        args: #( #cObject #int  )>!

sdlRWFromConstMem: aCobject0 size: aInt1 
    "extern DECLSPEC SDL_RWops * SDLCALL SDL_RWFromConstMem(const void *mem, 
         int size);"
    <cCall: 'SDL_RWFromConstMem' returning: #cObject 
        args: #( #cObject #int  )>!

sdlAllocRW
    "extern DECLSPEC SDL_RWops * SDLCALL SDL_AllocRW(void);"
    <cCall: 'SDL_AllocRW' returning: #cObject 
        args: #( )>!

sdlFreeRW: aCobject0
    "extern DECLSPEC void SDLCALL SDL_FreeRW(SDL_RWops *area);"
    <cCall: 'SDL_FreeRW' returning: #void 
        args: #( #cObject )>! !
