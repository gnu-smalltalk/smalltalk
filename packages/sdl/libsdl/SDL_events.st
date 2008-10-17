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

Object subclass: #SdlEvents
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

CStruct subclass: #SdlEvent
    declaration: #()
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

SdlEvent subclass: #SdlGenericEvent
    declaration: #(
        (#type #uchar)
        (#filler (#array #uchar 256)))
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

SdlEvent subclass: #SdlActiveEvent
    declaration: #(
        (#type #uChar)
        (#gain #uChar)
        (#state #uChar))
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

SdlEvent subclass: #SdlKeyBoardEvent
    declaration: #(
        (#type #uChar)
        (#which #uChar)
        (#state #uChar)
	(#unused #uChar)
        (#scanCode #uchar)
        (#sym #int)
        (#mod #int)
        (#unicode #uShort))
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

SdlEvent subclass: #SdlMouseMotionEvent
    declaration: #(
        (#type #uChar)
        (#which #uChar)
        (#state #uChar)
        (#x #uShort)
        (#y #uShort)
        (#xRel #uShort)
        (#yRel #uShort))
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

SdlEvent subclass: #SdlMouseButtonEvent
    declaration: #(
        (#type #uChar)
        (#which #uChar)
        (#button #uChar)
        (#state #uChar)
        (#x #uShort)
        (#y #uShort))
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

SdlEvent subclass: #SdlJoyAxisEvent
    declaration: #(
        (#type #uChar)
        (#which #uChar)
        (#axis #uChar)
        (#value #short))
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

SdlEvent subclass: #SdlJoyBallEvent
    declaration: #(
        (#type #uChar)
        (#which #uChar)
        (#ball #uChar)
        (#xrel #short)
        (#yrel #short))
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

SdlEvent subclass: #SdlJoyHatEvent
    declaration: #(
        (#type #uChar)
        (#which #uChar)
        (#hat #uChar)
        (#value #uChar))
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

SdlEvent subclass: #SdlJoyButtonEvent
    declaration: #(
        (#type #uChar)
        (#which #uChar)
        (#button #uChar)
        (#state #uChar))
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

SdlEvent subclass: #SdlResizeEvent
    declaration: #(
        (#type #uChar)
        (#w #int)
        (#h #int))
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

SdlEvent subclass: #SdlExposeEvent
    declaration: #(
        (#type #uChar))
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

SdlEvent subclass: #SdlQuitEvent
    declaration: #(
        (#type #uChar))
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

SdlEvent subclass: #SdlUserEvent
    declaration: #(
        (#type #uChar)
        (#code #int)
        (#data1 (#ptr #CObject))
        (#data2 (#ptr #CObject)))
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

SdlEvent subclass: #SdlSysWmEvent
    declaration: #(
        (#type #uChar)
        (#msg (#ptr #CObject)))
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

!SdlEvents class methodsFor: 'Constants'!

sdlNoEvent
    ^0!

sdlActiveEvent
    ^1!

sdlKeyDown
    ^2!

sdlKeyUp
    ^3!

sdlMouseMotion
    ^4!

sdlMouseButtonDown
    ^5!

sdlMouseButtonUp
    ^6!

sdlJoyAxisMotion
    ^7!

sdlJoyBallMotion
    ^8!

sdlJoyHatMotion
    ^9!

sdlJoyButtonDown
    ^10!

sdlJoyButtonUp
    ^11!

sdlQuit
    ^12!

sdlSysWMEvent
    ^13!

sdlEventReservedA
    ^14!

sdlEventReservedB
    ^15!

sdlVideoResize
    ^16!

sdlVideoExpose
    ^17!

sdlEventReserved2
    ^18!

sdlEventReserved3
    ^19!

sdlEventReserved4
    ^20!

sdlEventReserved5
    ^21!

sdlEventReserved6
    ^22!

sdlEventReserved7
    ^23!

sdlUserEvent
    ^24!

sdlNumEvents
    ^32!

sdlActiveEventMask
    ^(1 bitShift: 1)!

sdlKeyDownMask
    ^1 bitShift: 2!

sdlKeyUpMask
    ^1 bitShift: 3!

sdlMouseMotionMask
    ^1 bitShift: 4!

sdlMouseButtonDownMask
    ^1 bitShift: 5!

sdlMouseButtonUpMask
    ^1 bitShift: 6!

sdlMouseEventMask
    ^((1 bitShift: 4) bitOr: (1 bitShift: 5)) bitOr: (1 bitShift: 6)!

sdlJoyAxisMotionMask
    ^1 bitShift: 7!

sdlJoyBallMotionMask
    ^1 bitShift: 8!

sdlJoyHatMotionMask
    ^1 bitShift: 9!

sdlJoyButtonDownMask
    ^1 bitShift: 10!

sdlJoyButtonUpMask
    ^1 bitShift: 11!

sdlJoyEventMask
    ^((((1 bitShift: 7) bitOr: (1 bitShift: 8)) bitOr: (1 bitShift: 9)) bitOr: (1 bitShift: 10)) bitOr: (1 bitShift: 11)!

sdlVideoResizeMask
    ^1 bitShift: 16!

sdlVideoExposeMask
    ^1 bitShift: 17!

sdlUserMask
    ^1 bitShift: 24!

sdlQuitMask
    ^1 bitShift: 12!

sdlSysWMEventMask
    ^1 bitShift: 13!

sdlAllEvents
    ^16rFFFFFFFF!

sdlAddEvent
    ^0!

sdlPeekEvent
    ^1!

sdlGetEvent
    ^2!

sdlQuery
    ^-1!

sdlIgnore
    ^0!

sdlDisable
    ^0!

sdlEnable
    ^1!

!SdlEvents class methodsFor: 'C call-outs'!

sdlPumpEvents
    "I gather events from the input devices. My C function call
    prototype:

    extern DECLSPEC void SDLCALL SDL_PumpEvents(void);"
    <cCall: 'SDL_PumpEvents' returning: #void 
        args: #( )>!

sdlPeepEvents: aCobject0 numEvents: aInt1 action: aInt3 mask: aUint4
    "I check the event queue for messages. My C function call prototype:

    extern DECLSPEC int SDLCALL SDL_PeepEvents(SDL_Event *events, 
         int numevents, SDL_eventaction action, Uint32 mask);"
    <cCall: 'SDL_PeepEvents' returning: #int 
        args: #( #cObject #int #int #uInt )>!

sdlPollEvent: aCobject0
    "I poll for currently pending events, and answer whether or not
    there are. My C function call prototype:

    extern DECLSPEC int SDLCALL SDL_PollEvent(SDL_Event *event);"
    <cCall: 'SDL_PollEvent' returning: #int 
        args: #( #cObject )>!

sdlWaitEvent: aCobject0
    "I wait indefinitely for the next available event, and answer
    whether or not an error occured while waiting for it. My C
    function call prototype:

    extern DECLSPEC int SDLCALL SDL_WaitEvent(SDL_Event *event);"
    <cCall: 'SDL_WaitEvent' returning: #int 
        args: #( #cObject )>!

sdlPushEvent: aCobject0
    "I add an event to the event queue. My C function call prototype:

    extern DECLSPEC int SDLCALL SDL_PushEvent(SDL_Event *event);"
    <cCall: 'SDL_PushEvent' returning: #int 
        args: #( #cObject )>!

sdlSetEventFilter: aCobject0
    "I set up a an internal event queue filter to process all events. My
    C function call prototype:

    extern DECLSPEC void SDLCALL SDL_SetEventFilter(SDL_EventFilter filter);"
    <cCall: 'SDL_SetEventFilter' returning: #void 
        args: #( #cObject )>!

sdlGetEventFilter
    "I answer wituh the current event filter. My C function call
    prototype:

    extern DECLSPEC SDL_EventFilter SDLCALL SDL_GetEventFilter(void);"
    <cCall: 'SDL_GetEventFilter' returning: #cObject 
        args: #( )>!

sdlEventState: aCobject0 state: aInt1 
    "I configure how events will be presented. My C function call prototype:

    extern DECLSPEC Uint8 SDLCALL SDL_EventState(Uint8 type, int state);"
    <cCall: 'SDL_EventState' returning: #cObject 
        args: #( #cObject #int  )>! !
