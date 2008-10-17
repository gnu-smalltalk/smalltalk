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

Object subclass: #SdlKeyboard
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

CStruct subclass: #SdlKeysym
    declaration: #(
        (#scanCode #char)
        (#sym #int)
        (#mod #int)
        (#unicode #short))
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

!SdlKeyboard class methodsFor: 'Constants'!

sdlAllHotkeys
    ^16rFFFFFFFF!

sdlDefaultRepeatDelay
    ^500!

sdlDefaultRepeatInterval
    ^30!

!SdlKeyboard class methodsFor: 'C call-outs'!

sdlEnableUnicode: aInt0
    "I enable or disable UNICODE translation of keyboard input. My C
    function call prototype:

    extern DECLSPEC int SDLCALL SDL_EnableUNICODE(int enable);"
    <cCall: 'SDL_EnableUNICODE' returning: #int 
        args: #( #int )>!

sdlEnableKeyRepeat: aInt0 interval: aInt1
    "I enable or disable keyboard repeat. My C function call
    prototype:

    extern DECLSPEC int SDLCALL SDL_EnableKeyRepeat(int delay, int interval);"
    <cCall: 'SDL_EnableKeyRepeat' returning: #int 
        args: #( #int #int )>!

sdlGetKeyState: aCobject0
    "I answer the current state of the keyboard. My C function call
    prototype:

    extern DECLSPEC Uint8 * SDLCALL SDL_GetKeyState(int *numkeys);"
    <cCall: 'SDL_GetKeyState' returning: #string 
        args: #( #cObject )>!

sdlGetModState 
    "I answer the current key modifier state. My C function call prototype:

    extern DECLSPEC SDLMod SDLCALL SDL_GetModState(void);"
    <cCall: 'SDL_GetModState' returning: #cObject 
        args: #( #void )>!

sdlGetKeyName: aInt0 "needs a c wrapper"
    "I answer the name of an SDL virtual keysym. My C function call prototype:

    extern DECLSPEC char * SDLCALL SDL_GetKeyName(SDLKey key);"
    <cCall: 'SDL_GetKeyName' returning: #string 
        args: #( #int )>! !
