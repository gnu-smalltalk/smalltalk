"======================================================================
|
|   SdlEventSource and related classes
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2006, 2008 Free Software Foundation, Inc.
| Written by Tony Garnock-Jones and Michael Bridgen.
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


Notification subclass: SdlEventLoopStop [
    <category: 'LibSDL-Wrappers'>
    <comment: 'This exception is used internally to stop the SDL event loop.'>
]

Object subclass: SdlEventHandler [
    <category: 'LibSDL-Wrappers'>
    <comment: 'This is a basic class for SDL event handlers.  It declares
all event handlers as no-ops, guaranteeing backwards compatibility in
case future versions add more event handlers.'>

    handleMouseMotion: which state: state at: aPoint rel: relPoint [
	<category: 'event handlers'>
    ]

    handleMouseButton: which button: button state: state at: aPoint [
	<category: 'event handlers'>
    ]

    handleFocusLoss [
	<category: 'event handlers'>
    ]

    handleFocusGain [
	<category: 'event handlers'>
    ]

    handleKey: key state: aBoolean scanCode: scanCode sym: symCharacter mod: anInteger unicode: aCharacter [
	<category: 'event handlers'>
    ]

    handleExpose [
	<category: 'event handlers'>
    ]

    handleResize: sizePoint [
	"Unlike other handlers, this one by default tells the display to
	 resize itself."
	<category: 'event handlers'>
	SdlDisplay current resize: sizePoint
    ]

    handleQuit [
	<category: 'event handlers'>
	ObjectMemory quit
    ]

    eventMask [
	^ #(#{SdlActiveEvent} #{SdlKeyBoardEvent} #{SdlMouseMotionEvent}
	    #{SdlMouseButtonEvent} #{SdlResizeEvent} #{SdlExposeEvent}
	    #{SdlQuitEvent})
    ]
]

SdlEvent extend [
    EventTypeMap := nil.

    SdlEvent class >> initialize [
	EventTypeMap := Dictionary new.
	EventTypeMap at: SdlEvents sdlActiveEvent put: SdlActiveEvent.
	EventTypeMap at: SdlEvents sdlKeyDown put: SdlKeyBoardEvent.
	EventTypeMap at: SdlEvents sdlKeyUp put: SdlKeyBoardEvent.
	EventTypeMap at: SdlEvents sdlMouseMotion put: SdlMouseMotionEvent.
	EventTypeMap at: SdlEvents sdlMouseButtonDown put: SdlMouseButtonEvent.
	EventTypeMap at: SdlEvents sdlMouseButtonUp put: SdlMouseButtonEvent.
	EventTypeMap at: SdlEvents sdlJoyAxisMotion put: SdlJoyAxisEvent.
	EventTypeMap at: SdlEvents sdlJoyBallMotion put: SdlJoyBallEvent.
	EventTypeMap at: SdlEvents sdlJoyHatMotion put: SdlJoyHatEvent.
	EventTypeMap at: SdlEvents sdlJoyButtonDown put: SdlJoyButtonEvent.
	EventTypeMap at: SdlEvents sdlJoyButtonUp put: SdlJoyButtonEvent.
	EventTypeMap at: SdlEvents sdlQuit put: SdlQuitEvent.
	EventTypeMap at: SdlEvents sdlSysWMEvent put: SdlSysWmEvent.
	EventTypeMap at: SdlEvents sdlVideoResize put: SdlResizeEvent.
	EventTypeMap at: SdlEvents sdlVideoExpose put: SdlExposeEvent.
	EventTypeMap at: SdlEvents sdlUserEvent put: SdlUserEvent.
    ]

    SdlEvent class >> lookupEventType: aTypeNumber [
	^EventTypeMap at: aTypeNumber ifAbsent: [SdlEvent]
    ]

    becomeCorrectClass [
	<category: 'dispatch'>
	| correctClass |
	correctClass := SdlEvent lookupEventType: self type value asInteger.
	self changeClassTo: correctClass.
	^ self
    ]

    dispatchTo: handler [
	<category: 'dispatch'>
	Transcript << 'Unhandled event, ' << self; nl.
    ]
].

SdlActiveEvent extend [
    SdlActiveEvent class >> eventMask [
        <category: 'dispatch'>
	^SdlEvents sdlActiveEventMask
    ]

    dispatchTo: handler [
	<category: 'dispatch'>
	self gain value asInteger == 0
	    ifTrue: [ handler handleFocusLoss ]
	    ifFalse: [ handler handleFocusGain ]
    ]
].

SdlMouseMotionEvent extend [
    SdlMouseMotionEvent class >> eventMask [
        <category: 'dispatch'>
	^SdlEvents sdlMouseMotionMask
    ]

    dispatchTo: handler [
	<category: 'dispatch'>
	handler handleMouseMotion: self which value asInteger
		state: self state value asInteger
		at: self x value @ self y value
		rel: self xRel value @ self yRel value
    ]
].

SdlMouseButtonEvent extend [
    SdlMouseButtonEvent class >> eventMask [
        <category: 'dispatch'>
	^SdlEvents sdlMouseButtonDownMask bitOr: SdlEvents sdlMouseButtonUpMask
    ]

    dispatchTo: handler [
	<category: 'dispatch'>
	handler handleMouseButton: self which value asInteger
		button: self button value asInteger
		state: self state value asInteger ~= 0
		at: self x value @ self y value
    ]
].

SdlExposeEvent extend [
    SdlExposeEvent class >> eventMask [
        <category: 'dispatch'>
	^SdlEvents sdlVideoExposeMask
    ]

    dispatchTo: handler [
	<category: 'dispatch'>
	handler handleExpose
    ]
].

SdlResizeEvent extend [
    SdlResizeEvent class >> eventMask [
        <category: 'dispatch'>
	^SdlEvents sdlVideoResizeMask
    ]

    dispatchTo: handler [
	<category: 'dispatch'>
	handler handleResize: self w value @ self h value
    ]
].

SdlKeyBoardEvent extend [
    SdlKeyBoardEvent class >> eventMask [
        <category: 'dispatch'>
	^SdlEvents sdlKeyDownMask bitOr: SdlEvents sdlKeyUpMask
    ]
    keyboardModifiers [
	| v r |
	v := self mod value.
	v = 0 ifTrue: [ ^#() ].
	r := Set new.
	(v bitAnd: SdlKeySym kmodLshift) ~= 0 ifTrue: [ r add: #lshift. r add: #shift ].
	(v bitAnd: SdlKeySym kmodRshift) ~= 0 ifTrue: [ r add: #rshift. r add: #shift ].
	(v bitAnd: SdlKeySym kmodLctrl) ~= 0 ifTrue: [ r add: #lctrl. r add: #ctrl ].
	(v bitAnd: SdlKeySym kmodRctrl) ~= 0 ifTrue: [ r add: #rctrl. r add: #ctrl ].
	(v bitAnd: SdlKeySym kmodLalt) ~= 0 ifTrue: [ r add: #lalt. r add: #alt ].
	(v bitAnd: SdlKeySym kmodRalt) ~= 0 ifTrue: [ r add: #ralt. r add: #alt ].
	(v bitAnd: SdlKeySym kmodLmeta) ~= 0 ifTrue: [ r add: #lmeta. r add: #meta ].
	(v bitAnd: SdlKeySym kmodRmeta) ~= 0 ifTrue: [ r add: #rmeta. r add: #meta ].
	(v bitAnd: SdlKeySym kmodNum) ~= 0 ifTrue: [ r add: #num ].
	(v bitAnd: SdlKeySym kmodCaps) ~= 0 ifTrue: [ r add: #caps ].
	(v bitAnd: SdlKeySym kmodMode) ~= 0 ifTrue: [ r add: #mode ].
	^ r
    ]

    keySym [
	| s |
	s := self sym value.
	^ (s > 127)
	    ifTrue: [s]
	    ifFalse: [Character value: s]
    ]

    dispatchTo: handler [
	<category: 'dispatch'>
	handler handleKey: self which value asInteger
		state: self state value asInteger ~= 0
		scanCode: self scanCode value asInteger
		sym: self keySym
		mod: self keyboardModifiers
		unicode: (Character codePoint: self unicode value)
    ]
].

SdlJoyAxisEvent extend [
    SdlJoyAxisEvent class >> eventMask [
        <category: 'dispatch'>
	^SdlEvents sdlJoyAxisMask
    ]
]

SdlJoyBallEvent extend [
    SdlJoyBallEvent class >> eventMask [
        <category: 'dispatch'>
	^SdlEvents sdlJoyBallMask
    ]
]

SdlJoyHatEvent extend [
    SdlJoyHatEvent class >> eventMask [
        <category: 'dispatch'>
	^SdlEvents sdlJoyHatMask
    ]
]

SdlJoyButtonEvent extend [
    SdlJoyButtonEvent class >> eventMask [
        <category: 'dispatch'>
	^SdlEvents sdlJoyButtonDownMask bitOr: SdlEvents sdlJoyButtonUpMask
    ]
]

SdlSysWmEvent extend [
    SdlSysWmEvent class >> eventMask [
        <category: 'dispatch'>
	^SdlEvents sdlSysWMEventMask
    ]
]

SdlUserEvent extend [
    SdlUserEvent class >> eventMask [
        <category: 'dispatch'>
	^SdlEvents sdlUserMask
    ]
]

SdlQuitEvent extend [
    SdlQuitEvent class >> eventMask [
        <category: 'dispatch'>
	^SdlEvents sdlQuitMask
    ]

    dispatchTo: handler [
	<category: 'dispatch'>
	handler handleQuit
    ]
].

Object subclass: SdlEventSource [
    <category: 'LibSDL-Wrappers'>

    | handler pollDelay eventMask |

    SdlEventSource class >> new [
	"Create a new event source.  This is private, because an event source
	 is only created from an SdlDisplay."
	^ super new initialize
    ]

    handler [
	"Return the SdlEventHandler that will manage events for the display."

	<category: 'accessing'>
	^ handler
    ]

    handler: aHandler [
	"Set the SdlEventHandler that will manage events for the display."

	<category: 'accessing'>
	handler := aHandler.
	eventMask := handler eventMask
	     inject: 0 into: [:mask :assoc | mask bitOr: assoc value eventMask]
    ]

    initialize [
	<category: 'private-initialize'>
	pollDelay := Delay forMilliseconds: self defaultPollDelayMilliseconds.
	eventMask := 0.
    ]

    defaultPollDelayMilliseconds [
	<category: 'accessing'>
	^ 30 "which gives about 33 polls per second"
    ]

    waitEvent: anSdlEvent [
	<category: 'private-dispatch'>
	| peepResult |
	[
	    SdlEvents sdlPumpEvents.
	    peepResult := SdlEvents sdlPeepEvents: anSdlEvent
				    numEvents: 1
				    action: SdlEvents sdlGetEvent
				    mask: SdlEvents sdlAllEvents.
	    peepResult == -1 ifTrue: [ ^self error: 'SDL_PeepEvents error' ].
	    peepResult == 1 ifTrue: [ ^true ].
	    peepResult == 0 ifFalse: [ ^self error: 'Unexpected result from SDL_PeepEvents' ].
	    "0 - no event yet. Sleep and retry."
	    pollDelay wait.
	] repeat.
    ]

    waitEvent [
	<category: 'private-dispatch'>
	| e |
	[e := SdlGenericEvent new.
	self waitEvent: e.
	e becomeCorrectClass.
	e class eventMask anyMask: eventMask] whileFalse.
	^ e
    ]

    dispatchEvent: e [
	<category: 'private-dispatch'>
	handler ifNil: [^self].
	[e dispatchTo: handler]
	    on: Error
	    do: [ :ex |
		ex printNl.
		thisContext parentContext backtrace.
		ex return.
	    ].
    ]

    eventLoop [
	<category: 'private-dispatch'>
	Sdl sdlStartEventLoop: [
	    | e |
	    [
		[e := self waitEvent.
	        self dispatchEvent: e]
		    repeat
	    ] on: SdlEventLoopStop do: [ :ex |
		Sdl sdlStopEventLoop.
		ex return ].
	]
    ]

    startEventLoop [
	SdlKeyboard sdlEnableUnicode: 1.
	[ self eventLoop ] fork name: 'SdlEventSource eventLoop'.
    ]

    interruptEventLoop [
	SdlEventLoopStop signal
    ]
].

Eval [
    SdlEvent initialize.
    SdlEventSource initialize
]
