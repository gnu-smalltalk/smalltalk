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

Object subclass: #SdlJoystick
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

!SdlJoystick class methodsFor: 'Constants'!

sdlHatCentered
    ^16r00!

sdlHatUp
    ^16r01!

sdlHatRight
    ^16r02!

sdlHatDown
    ^16r04!

sdlHatLeft
    ^16r08!

sdlHatRightUp
    ^16r03!

sdlHatRightDown
    ^16r06!

sdlHatLeftUp
    ^16r09!

sdlHatLeftDown
    ^16r0c!

!SdlJoystick class methodsFor: 'C call-outs'!

sdlNumJoysticks
    "I answer the number of joysticks attached to the system. My C
    function prototype:

    extern DECLSPEC int SDLCALL SDL_NumJoysticks(void);"
    <cCall: 'SDL_NumJoysticks' returning: #int 
        args: #( )>!

sdlJoystickName: aInt0
    "I answer the name of a joystick. My C function call prototype:

    extern DECLSPEC const char * SDLCALL SDL_JoystickName(int device_index);"
    <cCall: 'SDL_JoystickName' returning: #string 
        args: #( #int )>!

sdlJoystickOpen: aInt0 
    "I open the the system joystick instance given to me. My C
    function call prototype:

    extern DECLSPEC SDL_Joystick * SDLCALL SDL_JoystickOpen(int device_index);"
    <cCall: 'SDL_JoystickOpen' returning: #cObject 
        args: #( #int  )>!

sdlJoystickOpened: aInt0
    "I answer whether or not the system joystick instance given to me
    is open. My C function call prototype:

    extern DECLSPEC int SDLCALL SDL_JoystickOpened(int device_index);"
    <cCall: 'SDL_JoystickOpened' returning: #int 
        args: #( #int )>!

sdlJoystickIndex: aCobject0
    "I answer the device index of an opened joystick. My C function
    call prototype:

    extern DECLSPEC int SDLCALL SDL_JoystickIndex(SDL_Joystick *joystick);"
    <cCall: 'SDL_JoystickIndex' returning: #int 
        args: #( #cObject )>!

sdlJoystickNumAxes: cObject
    "I answer the number of general axis controls on a joystick. My C
    function call prototype:

    extern DECLSPEC int SDLCALL SDL_JoystickNumAxes(SDL_Joystick *joystick);"
    <cCall: 'SDL_JoystickNumAxes' returning: #int 
        args: #( #cObject )>!

sdlJoystickNumBalls: aCobject0
    "I answer the number of balls on a joystick. My C function call
    prototype:

    extern DECLSPEC int SDLCALL SDL_JoystickNumBalls(SDL_Joystick *joystick);"
    <cCall: 'SDL_JoystickNumBalls' returning: #int 
        args: #( #cObject )>!

sdlJoystickNumHats: aCobject0
    "I answer the number of hats on a joystick. My C function call
    prototype:

    extern DECLSPEC int SDLCALL SDL_JoystickNumHats(SDL_Joystick *joystick);"
    <cCall: 'SDL_JoystickNumHats' returning: #int 
        args: #( #cObject )>!

sdlJoystickNumButtons: aCobject0
    "I answer the number of buttonss on a joystick. My C function call
    prototype:

    extern DECLSPEC int SDLCALL SDL_JoystickNumButtons(SDL_Joystick *joystick);"
    <cCall: 'SDL_JoystickNumButtons' returning: #int 
        args: #( #cObject )>!

sdlJoystickUpdate
    "I update the current state of the open joysticks. My C function
    call prototype:

    extern DECLSPEC void SDLCALL SDL_JoystickUpdate(void);"
    <cCall: 'SDL_JoystickUpdate' returning: #void 
        args: #( #void)>!

sdlJoystickEventState: aInt0
    "I enable or disable joystick event polling. My C function call
    prototype:

    extern DECLSPEC int SDLCALL SDL_JoystickEventState(int state);"
    <cCall: 'SDL_JoystickEventState' returning: #int 
        args: #( #int )>!

sdlJoystickGetAxis: aCobject0 axis: aInt1 
    "I answer the current state of an axis control on a joystick. My C function call prototype:

    extern DECLSPEC Sint16 SDLCALL SDL_JoystickGetAxis(SDL_Joystick *joystick, int axis);"
    <cCall: 'SDL_JoystickGetAxis' returning: #int
        args: #( #cObject #int  )>!

sdlJoystickGetHat: aCobject0 hat: aInt1 
    "I answer the current state of the hat on a joystick. My C function call prototype:

    extern DECLSPEC Uint8 SDLCALL SDL_JoystickGetHat(SDL_Joystick *joystick, int hat);"
    <cCall: 'SDL_JoystickGetHat' returning: #char 
        args: #( #cObject #int  )>!

sdlJoystickGetBall: aCobject0 ball: aInt1 dx: aCobject2 dy: aCobject3
    "I answer the ball axis change since the last poll. My C function call prototype:

    extern DECLSPEC int SDLCALL SDL_JoystickGetBall(SDL_Joystick *joystick, int ball, int *dx, int *dy);"
    <cCall: 'SDL_JoystickGetBall' returning: #int 
        args: #( #cObject #int #cObject #cObject )>!

sdlJoystickGetButton: aCobject0 button: aInt1 
    "I answer the current state of a button on a joystick. My C function call prototype:

    extern DECLSPEC Uint8 SDLCALL SDL_JoystickGetButton(SDL_Joystick *joystick, int button);"
    <cCall: 'SDL_JoystickGetButton' returning: #char
        args: #( #cObject #int  )>!

sdlJoystickClose: aCobject0
   "I close a previously opened joystick. My C function call prototype: 

    extern DECLSPEC void SDLCALL SDL_JoystickClose(SDL_Joystick *joystick);"
    <cCall: 'SDL_JoystickClose' returning: #void 
        args: #( #cObject )>! !
