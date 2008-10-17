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

Object subclass: #SdlThread
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

!SdlThread class methodsFor: 'C call-outs'!

sdlCreateThread: aCobject0 data: aCobject1 
    "I create a thread. My C function call prototype:

    extern DECLSPEC SDL_Thread * SDLCALL SDL_CreateThread(int (SDLCALL *fn)(void *), 
         void *data);"
    <cCall: 'SDL_CreateThread' returning: #cObject 
        args: #( #cObject #cObject  )>!

sdlThreadId
    "I answer the 32-bit thread identifier for the current thread. My
    C function call prototype:

    extern DECLSPEC Uint32 SDLCALL SDL_ThreadID(void);"
    <cCall: 'SDL_ThreadID' returning: #uInt
        args: #( )>!

sdlGetThreadId: aCobject0 
    "I answer the 32-bit thread identifier for the thread given to
    me. My C function call prototype:

    extern DECLSPEC Uint32 SDLCALL SDL_GetThreadID(SDL_Thread *thread);"
    <cCall: 'SDL_GetThreadID' returning: #uInt 
        args: #( #cObject  )>!

sdlWaitThread: aCobject0 status: aCobject1
    "I wait for the thread given to me to finish. My C function call
    prototype:

    extern DECLSPEC void SDLCALL SDL_WaitThread(SDL_Thread *thread, 
         int *status);"
    <cCall: 'SDL_WaitThread' retuning: #void 
        args: #( #cObject #cObject )>!

sdlKillThread: aCobject0
    "I kill a thread. My C function call prototype:

    extern DECLSPEC void SDLCALL SDL_KillThread(SDL_Thread *thread);"
    <cCall: 'SDL_KillThread' returning: #void 
        args: #( #cObject )>! !
