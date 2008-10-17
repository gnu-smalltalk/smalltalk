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

Object subclass: #SdlError
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

!SdlError class methodsFor: 'Constants'!

sdlEnoMem
    ^0!

sdlEfRead
    ^1!

sdlEfWrite
    ^2!

sdlEfSeek
    ^3!

sdlLastError
    ^4!

sdlSetError: aString0 args1: aVariadic1
    "extern DECLSPEC void SDLCALL SDL_SetError(const char *fmt, ...);"
    <cCall: 'SDL_SetError' returning: #void 
        args: #( #string #variadic )>!

sdlGetError
    "extern DECLSPEC char * SDLCALL SDL_GetError(void);"
    <cCall: 'SDL_GetError' returning: #string 
        args: #( )>!

sdlClearError
    "extern DECLSPEC void SDLCALL SDL_ClearError(void);"
    <cCall: 'SDL_ClearError' returning: #void 
        args: #( )>!

sdlError: aInt0
    "extern DECLSPEC void SDLCALL SDL_Error(SDL_errorcode code);"
    <cCall: 'SDL_Error' returning: #void 
        args: #( #int )>! !
