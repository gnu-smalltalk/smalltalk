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

Object subclass: #SdlMouse
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

CStruct subclass: #SdlCursor
    declaration: #(
        (#area (#ptr #CObject))
        (#hotX #short)
        (#hotY #short)
        (#data (#ptr #CObject))
        (#mask (#ptr #CObject))
        (#save (#ptr #CObject))
        (#wmCursor (#ptr #CObject)))
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

!SdlMouse class methodsFor: 'Constants'!

sdlButtonLeft
    ^1!

sdlButtonMiddle
    ^2!

sdlButtonRight
    ^3!

sdlButtonWheelUp
    ^4!

sdlButtonWheelDown
    ^5!

sdlButtonLMask
    ^16r01!

sdlButtonMMask
    ^16r02!

sdlButtonRMask
    ^16r04!

!SdlMouse class methodsFor: 'C call-outs'!

sdlGetMouseState: aCobject0 y: aCobject1 
    "I answer the current state of the mouse. The C function call
    prototype:

    extern DECLSPEC Uint8 SDLCALL SDL_GetMouseState(int *x, int *y);"
    <cCall: 'SDL_GetMouseState' returning: #char 
        args: #( #cObject #cObject  )>!

sdlGetRelativeMouseState: aCobject0 y: aCobject1 
    "I answer the current state of the mouse. The C function call
    prototype:

    extern DECLSPEC Uint8 SDLCALL SDL_GetRelativeMouseState(int *x, int *y);"
    <cCall: 'SDL_GetRelativeMouseState' returning: #char
        args: #( #cObject #cObject  )>!

sdlWarpMouse: aInt0 y: aInt1
    "I set the position of the mouse cursor. My C function call
    prototype:

    extern DECLSPEC void SDLCALL SDL_WarpMouse(Uint16 x, Uint16 y);"
    <cCall: 'SDL_WarpMouse' returning: #void 
        args: #( #int #int )>!

sdlCreateCursor: aCobject0 mask: aCobject1 w: aInt2 h: aInt3 hotX: aInt4 hotY: aInt5 
    "I create a cursor using the data and mask given to me. My C
    function call prototype:

    extern DECLSPEC SDL_Cursor * SDLCALL SDL_CreateCursor (Uint8 *data, Uint8 *mask, int w, int h, int hot_x, int hot_y);"
    <cCall: 'SDL_CreateCursor' returning: #cObject 
        args: #( #cObject #cObject #int #int #int #int  )>!

sdlSetCursor: aCobject0
    "I set the currently active cursor to the one given to me. My C
    function call prototype:

    extern DECLSPEC void SDLCALL SDL_SetCursor(SDL_Cursor *cursor);"
    <cCall: 'SDL_SetCursor' returning: #void 
        args: #( #cObject )>!

sdlGetCursor
    "I answer the currently active cursor. My C function call
    prototype:

    extern DECLSPEC SDL_Cursor * SDLCALL SDL_GetCursor(void);"
    <cCall: 'SDL_GetCursor' returning: #cObject 
        args: #( )>!

sdlFreeCursor: aCobject0
    "I deallocate a cursor created with SDL_CreateCursor(). My C
    function call prototype:

    extern DECLSPEC void SDLCALL SDL_FreeCursor(SDL_Cursor *cursor);"
    <cCall: 'SDL_FreeCursor' returning: #void 
        args: #( #cObject )>!

sdlShowCursor: aInt0
    "I toggle whether or not the cursor is shown on the screen. My C
    function call prototype:

    extern DECLSPEC int SDLCALL SDL_ShowCursor(int toggle);"
    <cCall: 'SDL_ShowCursor' returning: #int 
        args: #( #int )>! !
