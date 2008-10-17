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

Object subclass: #SdlTimer
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

!SdlTimer class methodsFor: 'Constants'!

sdlTimeSlice
    ^10!

timerResolution
    ^10!

!SdlTimer class methodsFor: 'C call-outs'!

sdlGetTicks
    "I answer the number of milliseconds since the SDL library
    initialization. My C function call prototype:

    extern DECLSPEC Uint32 SDLCALL SDL_GetTicks(void);"
    <cCall: 'SDL_GetTicks' returning: #uInt
        args: #( )>!

sdlDelay: aUint
    "I wait a specified number of milliseconds. My C function call
    prototype:

    extern DECLSPEC void SDLCALL SDL_Delay(Uint32 ms);"
    <cCall: 'SDL_Delay' returning: #void 
        args: #( #uInt )>!

sdlSetTimer: aUint callback: aCobject2
    "I set a callback to run after the specified number of
    milliseconds has elapsed. My C function call prototype:

    extern DECLSPEC int SDLCALL SDL_SetTimer(Uint32 interval, 
         SDL_TimerCallback callback);"
    <cCall: 'SDL_SetTimer' returning: #int 
        args: #( #int #cObject )>!

sdlAddTimer: aUint0 callback: aCobject1 param: aCobject2 
    "I add a new timer to the pool of timers already running. My C
    function call prototype:

    extern DECLSPEC SDL_TimerID SDLCALL SDL_AddTimer(Uint32 interval, 
         SDL_NewTimerCallback callback, void *param);"
    <cCall: 'SDL_AddTimer' returning: #cObject 
        args: #( #uInt #cObject #cObject  )>!

sdlRemoveTimer: aCobject0 
    "I remove the timer with the ID given to me. My C function call
    prototype:

    extern DECLSPEC SDL_bool SDLCALL SDL_RemoveTimer(SDL_TimerID t);"
    <cCall: 'SDL_RemoveTimer' returning: #boolean
        args: #( #cObject  )>! !
