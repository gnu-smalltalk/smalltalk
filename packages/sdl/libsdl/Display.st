"======================================================================
|
|   SdlDisplay wrapper class for libsdl
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2008 Free Software Foundation, Inc.
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


Object subclass: SdlDisplayFormat [
    | caption iconCaption extent resizable fullScreen |

    flags [
	<category: 'private'>
	self fullScreen ifTrue: [ ^SdlVideo sdlFullScreen ].
	self resizable ifTrue: [ ^SdlVideo sdlResizable ].
	^0
    ]

    caption [
        "Answer the caption of the window when it is not minimized."

	<category: 'accessing'>
	caption ifNil: [ caption := 'GNU Smalltalk' ].
	^caption
    ]

    caption: aString [
        "Set the caption of the window when it is not minimized."

	<category: 'accessing'>
	caption := aString.
    ]

    iconCaption [
        "Answer the caption of the window when it is minimized."

	<category: 'accessing'>
	^iconCaption ifNil: [ caption ].
    ]

    iconCaption: aString [
        "Set the caption of the window when it is minimized.  A value of nil
	 means the caption will not change when the window is minimized."

	<category: 'accessing'>
	iconCaption := aString
    ]

    extent [
	"Return the size of the window."

	<category: 'accessing'>
	extent ifNil: [ extent := 640 @ 480 ].
	^extent
    ]

    extent: aPoint [
	"Set the size of the window."

	<category: 'accessing'>
	extent := aPoint
    ]

    fullScreen [
	"Answer whether the SDL surface will be full-screen."

	<category: 'accessing'>
	fullScreen ifNil: [ fullScreen := false ].
	^fullScreen
    ]

    fullScreen: aBoolean [
	"Set whether the SDL surface will be full-screen."

	<category: 'accessing'>
	fullScreen := aBoolean
    ]

    resizable [
	"Answer whether the SDL surface will be resizable.  If it is, the
	 program will have to send the #resize: method to the display when
	 it gets a resize event (the default SdlEventHandler does this)."

	<category: 'accessing'>
	resizable ifNil: [ resizable := false ].
	^resizable
    ]

    resizable: aBoolean [
	"Set whether the SDL surface will be resizable.  If it is, the
	 program will have to send the #resize: method to the display when
	 it gets a resize event (the default SdlEventHandler does this)."

	<category: 'accessing'>
	resizable := aBoolean
    ]
]

Object subclass: SdlDisplay [
    <category: 'LibSDL-Wrapper'>
    <comment: 'I provide an object-oriented wrapper for some SDL_video
functions.  A Display can be connected to an EventSource and be used
as the destination for a Cairo surface.'>

    | surface flags extent caption iconCaption eventSource |

    CurrentDisplay := nil.
    DefaultFormat := nil.
    SdlDisplay class >> current [
	"Return the default display, creating one if none exists."

	<category: 'accessing'>
	"Creating the display will set CurrentDisplay too."
	CurrentDisplay isNil ifTrue: [ ^self new ].
	^CurrentDisplay
    ]

    SdlDisplay class >> current: aDisplay [
	"Set the default display."

	<category: 'accessing'>
	CurrentDisplay := aDisplay
    ]

    SdlDisplay class >> initialize [
        "Initialize the class, and initialize SDL when the library is loaded."

        <category: 'initialization'>
        ObjectMemory addDependent: self.
        self sdlInit.
    ]

    SdlDisplay class >> update: aspect [
        "Tie the event loop to image quit and restart."

        <category: 'initialization'>
        aspect == #returnFromSnapshot ifTrue: [ self sdlInit ].
	self changed: aspect
    ]

    SdlDisplay class >> sdlInit [
        "Initialize the SDL video subsystem, which is needed to get events."
        Sdl sdlInit: (Sdl sdlInitVideo bitOr: Sdl sdlInitNoParachute).
    ]

    SdlDisplay class >> defaultFormat [
	"Return the default format of the display, which is also the
	 format used when #current is called and there is no default
	 display."

	<category: 'accessing'>
	DefaultFormat isNil ifTrue: [ DefaultFormat := SdlDisplayFormat new ].
	^ DefaultFormat
    ]

    SdlDisplay class >> defaultSize [
	"Return the default size of the display, which is also the
	 size used when #current is called and there is no default
	 display."

	<category: 'accessing'>
	 ^ self defaultFormat extent
    ]

    SdlDisplay class >> defaultFormat: aDisplayFormat [
	"Set the default format of the display."

	<category: 'accessing'>
	DefaultFormat := aDisplayFormat
    ]

    SdlDisplay class >> defaultSize: aPoint [
	"Set the default size of the display."

	<category: 'accessing'>
	self defaultFormat extent: aPoint
    ]

    SdlDisplay class >> format: aSdlDisplayFormat [
	"Return an SdlDisplay with the given format."

	<category: 'instance creation'>
	^self basicNew initialize: aSdlDisplayFormat
    ]

    SdlDisplay class >> extent: aPoint [
	"Return an SdlDisplay with the given width and height."

	<category: 'instance creation'>
	^self format: (self defaultFormat copy extent: aPoint; yourself)
    ]

    SdlDisplay class >> new [
	"Return an SdlDisplay with the default width and height."

	<category: 'instance creation'>
	^self format: self defaultFormat
    ]

    sdlSurface [
	<category: 'private - accessing'>
	^surface
    ]

    sdlSurface: anSdlSurface [
	<category: 'private - accessing'>
	surface := anSdlSurface
    ]

    mapRed: r green: g blue: b [
	"Return an SDL color index for the given red/green/blue triplet."

	<category: 'drawing-SDL'>
	^ SdlVideo sdlMapRGB: surface format value r: r g: g b: b
    ]

    fillRect: aRect color: aColorNumber [
	"Fill a rectangle in the display with the color whose index is in
	 aColorNumber."

	<category: 'drawing-SDL'>
	| r |
	r := SDL.SdlRect gcNew.
	r x value: aRect left.
	r y value: aRect top.
	r w value: aRect width.
	r h value: aRect height.
	SdlVideo sdlFillRect: surface dstRect: r color: aColorNumber
    ]

    critical: aBlock [
	"Execute aBlock while the surface is locked.  This must be
	 called while drawing on the surface directly (e.g. via Cairo)"

	<category: 'drawing-direct'>
	(SdlVideo sdlLockSurface: surface) == 0 ifFalse: [
	    self error: 'Could not lock surface ', surface].
	^ aBlock ensure: [SdlVideo sdlUnlockSurface: surface]
    ]

    extent [
	"Return the size of the display."
	^ extent
    ]

    initialize: aFormat [
	"Initialize the display by hooking it up to the SdlEventSource."

	<category: 'initialization'>
	caption := aFormat caption.
	iconCaption := aFormat iconCaption.
	extent := aFormat extent.
	flags := aFormat flags.

	self class addDependent: self.

	"It's our first run - simulate returning from a saved image in
	order to set up the display window etc."
	CurrentDisplay isNil ifTrue: [ self class current: self ].
	self create
    ]

    update: aspect [
        "Tie the event loop to image quit and restart."

        <category: 'initialization'>
        aspect == #returnFromSnapshot ifTrue: [
	    self create.
            self eventSource handler isNil ifFalse: [ self eventSource startEventLoop ].
            self changed: #returnFromSnapshot.
            ^self].
        aspect == #aboutToQuit ifTrue: [
	    self shutdown.
            self eventSource interruptEventLoop.
            ^self].
    ]

    shutdown [
	self sdlSurface: nil.
    ]

    eventSource [
	"Return the EventSource associated to this display."
	eventSource isNil ifTrue: [ eventSource := SdlEventSource new ].
	^eventSource
    ]

    caption [
	"Return the caption of the window when it is not minimized."

	<category: 'accessing'>
	^caption
    ]

    iconCaption [
	"Return the caption of the window when it is minimized."

	<category: 'accessing'>
	^iconCaption
    ]

    caption: aString [
	"Set the caption of the window when it is not minimized."

	<category: 'accessing'>
	caption := aString.
	self setCaptions.
    ]

    iconCaption: aString [
	"Set the caption of the window when it is minimized."

	<category: 'accessing'>
	iconCaption := aString.
	self setCaptions.
    ]

    caption: aCaptionString iconCaption: anIconCaptionString [
	"Set up the window to use aCaptionString as its caption when it is
	 not minimized, and anIconCaptionString when it is."

	<category: 'accessing'>
	caption := aCaptionString.
	iconCaption := anIconCaptionString.
	self setCaptions.
    ]

    create [
	"Private - Actually create the display.

	TODO: add more accessors to match SDL flags (e.g. fullscreen, double
	buffer, resizable, h/w surfaces)."

	<category: 'initialization'>
	| flags screen |
	screen := SdlVideo sdlSetVideoMode: extent x height: extent y bpp: 32 flags: self flags.
	self sdlSurface: screen.
	self setCaptions.
    ]

    resize: newSize [
	"Change the extent of the display to newSize."

	<category: 'resize'>
	self shutdown.
	extent := newSize.
	self create.
	self changed: #resize
    ]

    flags [
	"Private - Return the SDL_SetVideoMode flags."

	<category: 'private'>
	^flags " bitOr: SdlVideo sdlFullScreen."
    ]

    setCaptions [
	"Private - sets captions from my instance variables."

	<category: 'private'>
	SdlVideo sdlWMSetCaption: self caption icon: self iconCaption.
    ]
	
    flip [
	"Move the contents of the surface to the screen.  Optimized for
	 double-buffered surfaces, but always works."

	<category: 'drawing'>
	SdlVideo sdlFlip: self sdlSurface.
    ]

    isGLDisplay [
	"Return true if this is an OpenGL display and graphics should be
	 performed using OpenGL calls."

	<category: 'testing'>
	^false
    ]

    updateRectangle: aRect [
	"Move the contents of the given rectangle from the surface to the
	 screen."

	<category: 'drawing'>
	| x y |
        SdlVideo sdlUpdateRect: self sdlSurface
                 x: (x := aRect left floor)
                 y: (y := aRect top floor)
                 w: aRect right ceiling - x
                 h: aRect height ceiling - y.
    ]

    updateRectangles: upTo rects: sdlrects [
	"Private - Move the contents of the given SdlRect objects from the
	 surface to the screen."

	<category: 'drawing-SDL'>
	SdlVideo sdlUpdateRects: self sdlSurface
		 numRects: upTo
		 rects: sdlrects.
    ]
].

Eval [
    SdlDisplay initialize
]
