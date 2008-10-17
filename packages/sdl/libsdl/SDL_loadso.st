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

Object subclass: #SdlLoadSo
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

!SdlLoadSo class methodsFor: 'C call-outs'!

sdlLoadObject: aString0 
    "I load a shared object and answer with the address for it.  My C
    function call prototype:

    extern DECLSPEC void * SDLCALL SDL_LoadObject(const char *sofile);"
    <cCall: 'SDL_LoadObject' returning: #cObject 
        args: #( #string )>!

sdlLoadFunction: aCobject name: aString1
    "I answer the address of the function whose name and shared object
    are given to me in.  My C function call prototype:

    extern DECLSPEC void * SDLCALL SDL_LoadFunction(void *handle, const char *name);"
    <cCall: 'SDL_LoadFunction' returning: #cObject 
        args: #( #cObject #string )>!

sdlUnloadObject: aCobject0
    "I unload a shared object from memory. My C function call
    prototype:

    extern DECLSPEC void SDLCALL SDL_UnloadObject(void *handle);"
    <cCall: 'SDL_UnloadObject' returning: #void 
        args: #( #cObject )>! !
