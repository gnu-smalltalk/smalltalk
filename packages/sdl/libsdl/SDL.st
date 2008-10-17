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

Object subclass: #Sdl
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

!Sdl class methodsFor: 'Constants'!

sdlInitTimer
    ^16r00000001!

sdlInitAudio
    ^16r00000010!

sdlInitVideo
    ^16r00000020!

sdlInitCdrom
    ^16r00000100!

sdlInitJoystick
    ^16r00000200!

sdlInitNoParachute
    ^16r00100000!

sdlInitEventThread
    ^16r01000000!

sdlInitEverything
    ^16r0000FFFF!

!Sdl class methodsFor: 'C call-outs'!

sdlForkEventLoop: aBlock
    "Execute aBlock within an SDL event loop.  Returns only when
     #sdlStopEventLoop is called, but forks aBlock in a separate Smalltalk
     process."

    | s |
    s := Semaphore new.
    self sdlStartEventLoop: [
	[aBlock ensure: [s signal]] fork].
    s wait!

sdlStartEventLoop: aBlock
    "Execute aBlock within an SDL event loop.  Returns only #sdlStopEventLoop
     is called, but calls aBlock."

    <cCall: 'SDL_StartEventLoop' returning: #void 
        args: #( #smalltalk )>!

sdlStopEventLoop
    "Tell SDL to stop the event loop."

    <cCall: 'SDL_StopEventLoop' returning: #void 
        args: #( )>!

sdlInit: aUint
    "I Initialize SDL. My c function call prototype:

    extern DECLSPEC int SDLCALL SDL_Init(Uint32 flags);"
    <cCall: 'SDL_Init' returning: #int 
        args: #( #uInt )>!

sdlInitSubSystem: aUint
    "I can initialize uninitialized subsystems My c function call
    prototype:

    extern DECLSPEC int SDLCALL SDL_InitSubSystem(Uint32 flags);"
    <cCall: 'SDL_InitSubSystem' returning: #int 
        args: #( #uInt )>!

sdlQuitSubSystem
    "I shut down a subsystem that has been previously initialized by
    SDL_Init or SDL_InitSubSystem. My c function call prototype is:

    extern DECLSPEC void SDLCALL SDL_QuitSubSystem(Uint32 flags);"
    <cCall: 'SDL_QuitSubSystem' returning: #void 
        args: #( #uInt )>!

sdlWasInit: aCobject0 
    "I answer which SDL subsytems have been initialized. My c function
    call prototype is:

     extern DECLSPEC Uint32 SDLCALL SDL_WasInit(Uint32 flags);"
    <cCall: 'SDL_WasInit' returning: #int 
        args: #( #uInt  )>!

sdlQuit
    "I shut down all SDL subsystems and free the resources allocated
    to them. My c function call prototype is:

     extern DECLSPEC void SDLCALL SDL_Quit(void);"
    <cCall: 'SDL_Quit' returning: #void 
        args: #( )>! !
