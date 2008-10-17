"======================================================================
|
|   Smalltalk GTK-based GUI building blocks (abstract classes).
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999, 2000, 2001, 2002, 2008 Free Software Foundation, Inc.
| Written by Paolo Bonzini and Robert Collins.
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
| along with the GNU Smalltalk class library; see the file COPYING.LESSER.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"



Object subclass: Gui [
    | blox |
    
    <category: 'Graphics-Windows'>
    <comment: 'I am a small class which serves as a base for complex objects which
expose an individual protocol but internally use a Blox widget for
creating their user interface.'>

    blox [
	"Return instance of blox subclass which implements window"

	<category: 'accessing'>
	^blox
    ]

    blox: aBlox [
	"Set instance of blox subclass which implements window"

	<category: 'accessing'>
	blox := aBlox
    ]
]



Object subclass: BEventTarget [
    | eventReceivers |
    
    <category: 'Graphics-Windows'>
    <comment: 'I track all the event handling procedures that you apply to an object.'>

    addEventSet: aBEventSetSublass [
	"Add to the receiver the event handlers implemented by an instance of
	 aBEventSetSubclass. Answer the new instance of aBEventSetSublass."

	<category: 'intercepting events'>
	^self registerEventReceiver: (aBEventSetSublass new: self)
    ]

    onAsciiKeyEventSend: aSelector to: anObject [
	"When an ASCII key is pressed and the receiver has the focus, send
	 the 1-argument message identified by aSelector to anObject,
	 passing to it a Character."

	<category: 'intercepting events'>
	aSelector numArgs = 1 ifFalse: [^self invalidArgsError: '1'].
	self registerEventReceiver: anObject.
	^self 
	    bind: '<KeyPress>'
	    to: #sendKeyEvent:oop:selector:
	    of: self
	    parameters: '*%A* ' , anObject asOop printString , ' ' 
		    , aSelector asTkString
    ]

    onDestroySend: aSelector to: anObject [
	"When the receiver is destroyed, send the unary message identified
	 by aSelector to anObject."

	<category: 'intercepting events'>
	aSelector numArgs = 0 ifFalse: [^self invalidArgsError: '0'].
	self 
	    connectSignal: 'destroy'
	    to: 
		[:widget :data | 
		data key perform: data value.
		false]
	    selector: #value:value:
	    userData: anObject -> aSelector asSymbol
    ]

    onFocusEnterEventSend: aSelector to: anObject [
	"When the focus enters the receiver, send the unary message identified
	 by aSelector to anObject."

	<category: 'intercepting events'>
	aSelector numArgs = 0 ifFalse: [^self invalidArgsError: '0'].
	self 
	    connectSignal: 'focus-in-event'
	    to: 
		[:widget :ev :data | 
		data key perform: data value.
		false]
	    selector: #value:value:value:
	    userData: anObject -> aSelector asSymbol
    ]

    onFocusLeaveEventSend: aSelector to: anObject [
	"When the focus leaves the receiver, send the unary message identified
	 by aSelector to anObject."

	<category: 'intercepting events'>
	aSelector numArgs = 0 ifFalse: [^self invalidArgsError: '0'].
	self 
	    connectSignal: 'focus-out-event'
	    to: 
		[:widget :ev :data | 
		data key perform: data value.
		false]
	    selector: #value:value:value:
	    userData: anObject -> aSelector asSymbol
    ]

    onKeyEvent: key send: aSelector to: anObject [
	"When the given key is pressed and the receiver has the focus,
	 send the unary message identified by aSelector to anObject.
	 Examples for key are:  'Ctrl-1', 'Alt-X', 'Meta-plus', 'enter'.
	 The last two cases include example of special key identifiers;
	 these include: 'backslash', 'exclam', 'quotedbl', 'dollar',
	 'asterisk', 'less', 'greater', 'asciicircum' (caret), 'question',
	 'equal', 'parenleft', 'parenright', 'colon', 'semicolon', 'bar' (pipe
	 sign), 'underscore', 'percent', 'minus', 'plus', 'BackSpace', 'Delete',
	 'Insert', 'Return', 'End', 'Home', 'Prior' (Pgup), 'Next' (Pgdn),
	 'F1'..'F24', 'Caps_Lock', 'Num_Lock', 'Tab', 'Left', 'Right', 'Up',
	 'Down'.  There are in addition four special identifiers which map
	 to platform-specific keys: '<Cut>', '<Copy>', '<Paste>', '<Clear>'
	 (all with the angular brackets!)."

	<category: 'intercepting events'>
	| block |
	aSelector numArgs = 0 ifFalse: [^self invalidArgsError: '0'].
	'onKeyEvent TODO implement own collection and check in that..' printNl.
	block := 
		[:widget :event :userData | 
		"anObject perform: aSelector asSymbol."

		false].
	self 
	    connectSignal: 'key-press-event'
	    to: block
	    selector: #value:value:value:
	    userData: nil

	"(self getKeyPressEventNames: key) do: [ :each |
	 self
	 bind: each
	 to: aSelector
	 of: anObject
	 parameters: ''
	 ]"
    ]

    onKeyEventSend: aSelector to: anObject [
	"When a key is pressed and the receiver has the focus, send the
	 1-argument message identified by aSelector to anObject. The pressed
	 key will be passed as a String parameter; some of the keys will
	 send special key identifiers such as those explained in the
	 documentation for #onKeyEvent:send:to: Look at the #eventTest
	 test program in the BloxTestSuite to find out the parameters
	 passed to such an event procedure"

	<category: 'intercepting events'>
	aSelector numArgs = 1 ifFalse: [^self invalidArgsError: '1'].
	^self 
	    bind: '<KeyPress>'
	    to: aSelector
	    of: anObject
	    parameters: '%K'
    ]

    onKeyUpEventSend: aSelector to: anObject [
	"When a key has been released and the receiver has the focus, send
	 the 1-argument message identified by aSelector to anObject. The
	 released key will be passed as a String parameter; some of the keys
	 will send special key identifiers such as those explained in the
	 documentation for #onKeyEvent:send:to: Look at the #eventTest
	 test program in the BloxTestSuite to find out the parameters
	 passed to such an event procedure"

	<category: 'intercepting events'>
	| block |
	aSelector numArgs = 1 ifFalse: [^self invalidArgsError: '1'].
	'key up TODO implement Tk''s %K and pass it' printNl.
	block := 
		[:widget :event :userData | 
		userData key perform: userData value with: nil.
		false].
	self 
	    connectSignal: 'key-release-event'
	    to: block
	    selector: #value:value:value:
	    userData: anObject -> aSelector asSymbol
    ]

    onMouseDoubleEvent: button send: aSelector to: anObject [
	"When the given button is double-clicked on the mouse, send the
	 1-argument message identified by aSelector to anObject. The
	 mouse position will be passed as a Point."

	<category: 'intercepting events'>
	| block |
	aSelector numArgs = 1 ifFalse: [^self invalidArgsError: '1'].
	self registerEventReceiver: anObject.
	block := 
		[:widget :event :userData | 
		| buttonEv |
		buttonEv := event castTo: GTK.GdkEventButton type.
		(buttonEv button value = button 
		    and: [buttonEv type value = GTK.Gdk gdk2buttonPress]) 
			ifTrue: 
			    [userData key perform: userData value
				with: buttonEv x value @ buttonEv y value].
		false].
	self 
	    connectSignal: 'button-press-event'
	    to: block
	    selector: #value:value:value:
	    userData: anObject -> aSelector asSymbol
    ]

    onMouseDoubleEventSend: aSelector to: anObject [
	"When a button is double-clicked on the mouse, send the 2-argument
	 message identified by aSelector to anObject. The mouse
	 position will be passed as a Point in the first parameter,
	 the button number will be passed as an Integer in the second
	 parameter."

	<category: 'intercepting events'>
	| block |
	aSelector numArgs = 2 ifFalse: [^self invalidArgsError: '1'].
	self registerEventReceiver: anObject.
	block := 
		[:widget :event :userData | 
		| buttonEv |
		buttonEv := event castTo: GTK.GdkEventButton type.
		buttonEv type value = GTK.Gdk gdk2buttonPress 
		    ifTrue: 
			[userData key 
			    perform: userData value
			    with: buttonEv x value @ buttonEv y value
			    with: buttonEv button value].
		false].
	self 
	    connectSignal: 'button-press-event'
	    to: block
	    selector: #value:value:value:
	    userData: anObject -> aSelector asSymbol
    ]

    onMouseDownEvent: button send: aSelector to: anObject [
	"When the given button is pressed on the mouse, send the
	 1-argument message identified by aSelector to anObject. The
	 mouse position will be passed as a Point."

	<category: 'intercepting events'>
	| block |
	aSelector numArgs = 1 ifFalse: [^self invalidArgsError: '1'].
	self registerEventReceiver: anObject.
	block := 
		[:widget :event :userData | 
		| buttonEv |
		buttonEv := event castTo: GTK.GdkEventButton type.
		(buttonEv button value = button 
		    and: [buttonEv type value = GTK.Gdk gdkButtonPress]) 
			ifTrue: 
			    [userData key perform: userData value
				with: buttonEv x value @ buttonEv y value].
		false].
	self 
	    connectSignal: 'button-press-event'
	    to: block
	    selector: #value:value:value:
	    userData: anObject -> aSelector asSymbol
    ]

    onMouseDownEventSend: aSelector to: anObject [
	"When a button is pressed on the mouse, send the 2-argument
	 message identified by aSelector to anObject. The mouse
	 position will be passed as a Point in the first parameter,
	 the button number will be passed as an Integer in the second
	 parameter."

	<category: 'intercepting events'>
	| block |
	aSelector numArgs = 2 ifFalse: [^self invalidArgsError: '2'].
	self registerEventReceiver: anObject.
	block := 
		[:widget :event :userData | 
		| buttonEv |
		buttonEv := event castTo: GTK.GdkEventButton type.
		buttonEv type value = GTK.Gdk gdkButtonPress 
		    ifTrue: 
			[userData key 
			    perform: userData value
			    with: buttonEv x value @ buttonEv y value
			    with: buttonEv button value].
		false].
	self 
	    connectSignal: 'button-press-event'
	    to: block
	    selector: #value:value:value:
	    userData: anObject -> aSelector asSymbol
    ]

    onMouseEnterEventSend: aSelector to: anObject [
	"When the mouse enters the widget, send the unary message
	 identified by aSelector to anObject."

	<category: 'intercepting events'>
	aSelector numArgs = 0 ifFalse: [^self invalidArgsError: '0'].
	self 
	    connectSignal: 'enter-notify-event'
	    to: 
		[:widget :ev :data | 
		data key perform: data value.
		false]
	    selector: #value:value:value:
	    userData: anObject -> aSelector asSymbol
    ]

    onMouseLeaveEventSend: aSelector to: anObject [
	"When the mouse leaves the widget, send the unary message
	 identified by aSelector to anObject."

	<category: 'intercepting events'>
	aSelector numArgs = 0 ifFalse: [^self invalidArgsError: '0'].
	self 
	    connectSignal: 'leave-notify-event'
	    to: 
		[:widget :ev :data | 
		data key perform: data value.
		false]
	    selector: #value:value:value:
	    userData: anObject -> aSelector asSymbol
    ]

    onMouseMoveEvent: button send: aSelector to: anObject [
	"When the mouse is moved while the given button is pressed
	 on the mouse, send the 1-argument message identified by aSelector
	 to anObject. The mouse position will be passed as a Point."

	<category: 'intercepting events'>
	| modMask block |
	aSelector numArgs = 1 ifFalse: [^self invalidArgsError: '1'].
	self registerEventReceiver: anObject.
	modMask := GTK.Gdk gdkButton1Mask bitShift: button - 1.
	block := 
		[:widget :event :userData | 
		| motionEv |
		motionEv := event castTo: GTK.GdkEventMotion type.
		(motionEv state value anyMask: modMask) 
		    ifTrue: 
			[userData key perform: userData value
			    with: motionEv x value @ motionEv y value].
		false].
	self 
	    connectSignal: 'motion-notify-event'
	    to: block
	    selector: #value:value:value:
	    userData: anObject -> aSelector asSymbol
    ]

    onMouseMoveEventSend: aSelector to: anObject [
	"When the mouse is moved, send the 1-argument message identified
	 by aSelector to anObject. The mouse position will be passed as a Point."

	<category: 'intercepting events'>
	| block |
	aSelector numArgs = 1 ifFalse: [^self invalidArgsError: '1'].
	self registerEventReceiver: anObject.
	block := 
		[:widget :event :userData | 
		| motionEv |
		motionEv := event castTo: GTK.GdkEventMotion type.
		userData key perform: userData value
		    with: motionEv x value @ motionEv y value.
		false].
	self 
	    connectSignal: 'motion-notify-event'
	    to: block
	    selector: #value:value:value:
	    userData: anObject -> aSelector asSymbol
    ]

    onMouseTripleEvent: button send: aSelector to: anObject [
	"When the given button is triple-clicked on the mouse, send the
	 1-argument message identified by aSelector to anObject. The
	 mouse position will be passed as a Point."

	<category: 'intercepting events'>
	| block |
	aSelector numArgs = 1 ifFalse: [^self invalidArgsError: '1'].
	self registerEventReceiver: anObject.
	block := 
		[:widget :event :userData | 
		| buttonEv |
		buttonEv := event castTo: GTK.GdkEventButton type.
		(buttonEv button value = button 
		    and: [buttonEv type value = GTK.Gdk gdk3buttonPress]) 
			ifTrue: 
			    [userData key perform: userData value
				with: buttonEv x value @ buttonEv y value].
		false].
	self 
	    connectSignal: 'button-press-event'
	    to: block
	    selector: #value:value:value:
	    userData: anObject -> aSelector asSymbol
    ]

    onMouseTripleEventSend: aSelector to: anObject [
	"When a button is triple-clicked on the mouse, send the 2-argument
	 message identified by aSelector to anObject. The mouse
	 position will be passed as a Point in the first parameter,
	 the button number will be passed as an Integer in the second
	 parameter."

	<category: 'intercepting events'>
	| block |
	aSelector numArgs = 2 ifFalse: [^self invalidArgsError: '1'].
	self registerEventReceiver: anObject.
	block := 
		[:widget :event :userData | 
		| buttonEv |
		buttonEv := event castTo: GTK.GdkEventButton type.
		buttonEv type value = GTK.Gdk gdk3buttonPress 
		    ifTrue: 
			[userData key 
			    perform: userData value
			    with: buttonEv x value @ buttonEv y value
			    with: buttonEv button value].
		false].
	self 
	    connectSignal: 'button-press-event'
	    to: block
	    selector: #value:value:value:
	    userData: anObject -> aSelector asSymbol
    ]

    onMouseUpEvent: button send: aSelector to: anObject [
	"When the given button is released on the mouse, send the
	 1-argument message identified by aSelector to anObject. The
	 mouse position will be passed as a Point."

	<category: 'intercepting events'>
	| block |
	aSelector numArgs = 1 ifFalse: [^self invalidArgsError: '1'].
	self registerEventReceiver: anObject.
	block := 
		[:widget :event :userData | 
		| buttonEv |
		buttonEv := event castTo: GTK.GdkEventButton type.
		buttonEv button value = button 
		    ifTrue: 
			[userData key perform: userData value
			    with: buttonEv x value @ buttonEv y value].
		false].
	self 
	    connectSignal: 'button-release-event'
	    to: block
	    selector: #value:value:value:
	    userData: anObject -> aSelector asSymbol
    ]

    onMouseUpEventSend: aSelector to: anObject [
	"When a button is released on the mouse, send the 2-argument
	 message identified by aSelector to anObject. The mouse
	 position will be passed as a Point in the first parameter,
	 the button number will be passed as an Integer in the second
	 parameter."

	<category: 'intercepting events'>
	| block |
	aSelector numArgs = 2 ifFalse: [^self invalidArgsError: '2'].
	self registerEventReceiver: anObject.
	block := 
		[:widget :event :userData | 
		| buttonEv |
		buttonEv := event castTo: GTK.GdkEventButton type.
		userData key 
		    perform: userData value
		    with: buttonEv x value @ buttonEv y value
		    with: buttonEv button value.
		false].
	self 
	    connectSignal: 'button-release-event'
	    to: block
	    selector: #value:value:value:
	    userData: anObject -> aSelector asSymbol
    ]

    onResizeSend: aSelector to: anObject [
	"When the receiver is resized, send the 1-argument message
	 identified by aSelector to anObject. The new size will be
	 passed as a Point."

	<category: 'intercepting events'>
	| block |
	aSelector numArgs = 1 ifFalse: [^self invalidArgsError: '2'].
	self registerEventReceiver: anObject.
	block := 
		[:widget :event :userData | 
		| configEv |
		configEv := event castTo: GTK.GdkEventConfigure type.
		userData key perform: userData value
		    with: configEv x value @ configEv y value.
		false].
	self 
	    connectSignal: 'configure-event'
	    to: block
	    selector: #value:value:value:
	    userData: anObject -> aSelector asSymbol
    ]

    connectSignal: aString to: anObject selector: aSymbol userData: userData [
	<category: 'private'>
	self subclassResponsibility
    ]

    getKeyPressEventNames: key [
	"Private - Given the key passed to a key event installer method,
	 answer the KeyPress event name as required by Tcl."

	<category: 'private'>
	| platform mod keySym |
	keySym := key isCharacter ifTrue: [String with: key] ifFalse: [key].
	(keySym at: 1) = $< ifTrue: [^{'<' , keySym , '>'}].
	mod := ''.
	(keySym includes: $-) 
	    ifTrue: 
		[mod := (ReadStream on: key) next: (key findLast: [:each | each = $-]) - 1.
		keySym := key copyFrom: mod size + 2 to: key size.
		platform := Blox platform.
		mod := (mod substrings: $-) inject: ''
			    into: [:old :each | old , (self translateModifier: each platform: platform) , '-']].
	^(keySym size = 1 and: [keySym first isLetter]) 
	    ifTrue: 
		["Use both the lowercase and uppercase variants"

		
		{'<%1KeyPress-%2>' % 
			{mod.
			keySym asLowercase}.
		'<%1KeyPress-%2>' % 
			{mod.
			keySym asUppercase}}]
	    ifFalse: [{'<%1KeyPress-%2>' % 
			{mod.
			keySym}}]
    ]

    translateModifier: mod platform: platform [
	<category: 'private'>
	| name |
	name := mod.
	name = 'Meta' ifTrue: [name := 'Alt'].
	name = 'Alt' & (platform == #macintosh) ifTrue: [name := 'Option'].
	name = 'Control' & (platform == #macintosh) ifTrue: [name := 'Cmd'].
	^name
    ]

    invalidArgsError: expected [
	"Private - Raise an error (as one could expect...) What is not
	 so expected is that the expected argument is a string."

	<category: 'private'>
	^self error: 'invalid number of arguments, expected ' , expected
    ]

    primBind: event to: aSymbol of: anObject parameters: params [
	"Private - Register the given event, to be passed to anObject
	 via the aSymbol selector with the given parameters"

	<category: 'private'>
	self subclassResponsibility
    ]

    registerEventReceiver: anObject [
	"Private - Avoid that anObject is garbage collected as long as
	 the receiver exists."

	<category: 'private'>
	eventReceivers isNil ifTrue: [eventReceivers := IdentitySet new].
	^eventReceivers add: anObject
    ]

    sendKeyEvent: key oop: oop selector: sel [
	"Private - Filter ASCII events from Tcl to Smalltalk. We receive
	 either *{}* for a non-ASCII char or *A* for an ASCII char, where
	 A is the character. In the first case the event is eaten, in the
	 second it is passed to a Smalltalk method"

	"key printNl.
	 oop asInteger asObject printNl.
	 '---' printNl."

	<category: 'private'>
	key size = 3 
	    ifTrue: [oop asInteger asObject perform: sel asSymbol with: (key at: 2)]
    ]

    sendPointEvent: x y: y oop: oop selector: sel [
	"Private - Filter mouse events from Tcl to Smalltalk. We receive two
	 strings, we convert them to a Point and then pass them to a Smalltalk
	 method"

	"oop printNl.
	 oop asInteger asObject printNl.
	 '---' printNl."

	<category: 'private'>
	oop asInteger asObject perform: sel asSymbol
	    with: x asInteger @ y asInteger
    ]
]



BEventTarget subclass: BEventSet [
    | widget |
    
    <category: 'Graphics-Windows'>
    <comment: 'I combine event handlers and let you apply them to many objects.
Basically, you derive a class from me, override the #initialize:
method to establish the handlers, then use the #addEventSet: method
understood by every Blox class to add the event handlers specified
by the receiver to the object.'>

    BEventSet class >> new [
	<category: 'initializing'>
	self shouldNotImplement
    ]

    BEventSet class >> new: widget [
	"Private - Create a new event set object that will
	 attach to the given widget. Answer the object. Note: this
	 method should be called by #addEventSet:, not directly"

	<category: 'initializing'>
	^(self basicNew)
	    initialize: widget;
	    yourself
    ]

    widget [
	"Answer the widget to which the receiver is attached."

	<category: 'accessing'>
	^widget
    ]

    initialize: aBWidget [
	"Initialize the receiver's event handlers to attach to aBWidget.
	 You can override this of course, but don't forget to call the
	 superclass implementation first."

	<category: 'initializing'>
	widget := aBWidget
    ]

    connectSignal: aString to: anObject selector: aSymbol userData: userData [
	"Private - Register the given event, to be passed to anObject
	 via the aSymbol selector with the given parameters; this method
	 is simply forwarded to the attached widget"

	<category: 'private'>
	self widget 
	    connectSignal: aString
	    to: anObject
	    selector: aSymbol
	    userData: userData
    ]
]



BEventTarget subclass: Blox [
    | properties parent children |
    
    <category: 'Graphics-Windows'>
    <comment: 'I am the superclass for every visible user interface object (excluding
canvas items, which are pretty different). I provide common methods and
I expose class methods that do many interesting event-handling things.'>

    Platform := nil.
    ClipStatus := nil.
    DoDispatchEvents := nil.

    Blox class >> dispatchEvents [
	"If this is the outermost dispatching loop that is started,
	 dispatch events until the number of calls to #terminateMainLoop
	 balances the number of calls to #dispatchEvents; return
	 instantly if this is not the outermost dispatching loop that
	 is started."

	<category: 'event dispatching'>
	| clipboard sem |
	DoDispatchEvents := DoDispatchEvents + 1.
	DoDispatchEvents = 1 ifFalse: [^self].

	"If we're outside the event loop, Tk for Windows is unable to
	 render the clipboard and locks up the clipboard viewer app.
	 So, we save the contents for the next time we'll start a
	 message loop.  If the clipboard was temporarily saved to ClipStatus,
	 restore it.
	 
	 ClipStatus is:
	 - true if we own the clipboard
	 - false if we don't
	 - nil if we don't and we are outside a message loop
	 - a String if we do and we are outside a message loop"
	clipboard := ClipStatus.
	ClipStatus := ClipStatus notNil and: [ClipStatus notEmpty].
	ClipStatus ifTrue: [self clipboard: clipboard].
	GTK.Gtk main.

	"Save the contents of the clipboard if we own it."
	ClipStatus := ClipStatus ifTrue: [self clearClipboard] ifFalse: [nil]
    ]

    Blox class >> dispatchEvents: mainWindow [
	"Dispatch some events; return instantly if this is not the outermost
	 dispatching loop that is started, else loop until the number of calls
	 to #dispatchEvents balance the number of calls to #terminateMainLoop.
	 
	 In addition, set up an event handler that will call #terminateMainLoop
	 upon destruction of the `mainWindow' widget (which can be any kind of
	 BWidget, but will be typically a BWindow)."

	<category: 'event dispatching'>
	| sem |
	sem := Semaphore new.
	mainWindow onDestroySend: #signal to: sem.
	Blox dispatchEvents.
	sem wait.
	Blox terminateMainLoop
    ]

    Blox class >> terminateMainLoop [
	"Terminate the event dispatching loop if this call to #terminateMainLoop
	 balances the number of calls to #dispatchEvents. Answer whether the
	 calls are balanced."

	<category: 'event dispatching'>
	DoDispatchEvents := DoDispatchEvents - 1.
	DoDispatchEvents = 0 ifTrue: [GTK.Gtk mainQuit]
    ]

    Blox class >> update: aspect [
	"Initialize the Tcl and Blox environments; executed automatically
	 on startup."

	<category: 'event dispatching'>
	| initResult |
	aspect == #returnFromSnapshot ifFalse: [^self].
	GTK.Gtk gstGtkInit.
	DoDispatchEvents := 0.
	ClipStatus := nil.
	Blox withAllSubclassesDo: 
		[:each | 
		(each class includesSelector: #initializeOnStartup) 
		    ifTrue: [each initializeOnStartup]]
    ]

    Blox class >> new [
	<category: 'instance creation'>
	self shouldNotImplement
    ]

    Blox class >> new: parent [
	"Create a new widget of the type identified by the receiver, inside
	 the given parent widget. Answer the new widget"

	<category: 'instance creation'>
	^self basicNew initialize: parent
    ]

    Blox class >> cursorNames [
	<category: 'private'>
	^#(#X_cursor #arrow #based_arrow_down #based_arrow_up #boat #bogosity #bottom_left_corner #bottom_right_corner #bottom_side #bottom_tee #box_spiral #center_ptr #circle #clock #coffee_mug #cross #cross_reverse #crosshair #diamond_cross #dot #dotbox #double_arrow #draft_large #draft_small #draped_box #exchange #fleur #gobbler #gumby #hand1 #hand2 #heart #icon #iron_cross #left_ptr #left_side #left_tee #leftbutton #ll_angle #lr_angle #man #middlebutton #mouse #pencil #pirate #plus #question_arrow #right_ptr #right_side #right_tee #rightbutton #rtl_logo #sailboat #sb_down_arrow #sb_h_double_arrow #sb_left_arrow #sb_right_arrow #sb_up_arrow #sb_v_double_arrow #shuttle #sizing #spider #spraycan #star #target #tcross #top_left_arrow #top_left_corner #top_right_corner #top_side #top_tee #trek #ul_angle #umbrella #ur_angle #watch #xterm)
    ]

    Blox class >> cursorNameForType: type [
	<category: 'private'>
	^self cursorNames at: type // 2 + 1
    ]

    Blox class >> cursorTypeForName: name [
	<category: 'private'>
	^##(| names |
	names := IdentityDictionary new.
	Blox cursorNames with: (0 to: 152 by: 2)
	    do: [:name :type | names at: name put: type].
	names) at: name
    ]

    Blox class >> tclEval: tclCode [
	"Private - Evaluate the given Tcl code; if it raises an exception,
	 raise it as a Smalltalk error"

	<category: 'private - Tcl'>
	self notYetImplemented
    ]

    Blox class >> tclEval: tclCode with: arg1 [
	"Private - Evaluate the given Tcl code, replacing %1 with arg1; if
	 it raises an exception, raise it as a Smalltalk error"

	<category: 'private - Tcl'>
	self notYetImplemented
    ]

    Blox class >> tclEval: tclCode with: arg1 with: arg2 [
	"Private - Evaluate the given Tcl code, replacing %1 with arg1
	 and %2 with arg2; if it raises an exception, raise it as a
	 Smalltalk error"

	<category: 'private - Tcl'>
	self notYetImplemented
    ]

    Blox class >> tclEval: tclCode with: arg1 with: arg2 with: arg3 [
	"Private - Evaluate the given Tcl code, replacing %1 with arg1,
	 %2 with arg2 and %3 with arg3; if it raises an exception, raise
	 it as a Smalltalk error"

	<category: 'private - Tcl'>
	self notYetImplemented
    ]

    Blox class >> tclEval: tclCode with: arg1 with: arg2 with: arg3 with: arg4 [
	"Private - Evaluate the given Tcl code, replacing %1 with arg1,
	 %2 with arg2, and so on; if it raises an exception, raise
	 it as a Smalltalk error"

	<category: 'private - Tcl'>
	self notYetImplemented
    ]

    Blox class >> tclEval: tclCode withArguments: anArray [
	"Private - Evaluate the given Tcl code, replacing %n with the
	 n-th element of anArray; if it raises an exception, raise
	 it as a Smalltalk error"

	<category: 'private - Tcl'>
	self notYetImplemented
    ]

    Blox class >> tclResult [
	"Private - Return the result code for Tcl, as a Smalltalk String."

	<category: 'private - Tcl'>
	self notYetImplemented
    ]

    Blox class >> active [
	"Answer the currently active Blox, or nil if the focus does not
	 belong to a Smalltalk window."

	<category: 'utility'>
	self tclEval: 'focus'.
	^self fromString: self tclResult
    ]

    Blox class >> at: aPoint [
	"Answer the Blox containing the given point on the screen, or
	 nil if no Blox contains the given point (either because
	 no Smalltalk window is there or because it is covered by
	 another window)."

	<category: 'utility'>
	self 
	    tclEval: 'winfo containing %1 %2'
	    with: aPoint x printString
	    with: aPoint y printString.
	^self fromString: self tclResult
    ]

    Blox class >> atMouse [
	"Answer the Blox under the mouse cursor's hot spot, or nil
	 if no Blox contains the given point (either because no
	 Smalltalk window is there or because it is covered by
	 another window)."

	<category: 'utility'>
	self tclEval: 'eval winfo containing [winfo pointerxy .]'.
	^self fromString: self tclResult
    ]

    Blox class >> beep [
	"Produce a bell"

	<category: 'utility'>
	GTK.Gdk beep
    ]

    Blox class >> clearClipboard [
	"Clear the clipboard, answer its old contents."

	<category: 'utility'>
	| contents |
	contents := self clipboard.
	self tclEval: 'clipboard clear'.
	ClipStatus isString ifTrue: [ClipStatus := nil].
	ClipStatus == true ifTrue: [ClipStatus := false].
	^contents
    ]

    Blox class >> clipboard [
	"Retrieve the text in the clipboard."

	<category: 'utility'>
	self 
	    tclEval: '
	if { [catch { selection get -selection CLIPBOARD } clipboard] } {
	  return ""
	} else {
	  return $clipboard
	}'.
	^self tclResult
    ]

    Blox class >> clipboard: aString [
	"Set the contents of the clipboard to aString (or empty the clipboard
	 if aString is nil)."

	<category: 'utility'>
	self clearClipboard.
	(aString isNil or: [aString isEmpty]) ifTrue: [^self].
	ClipStatus isNil 
	    ifTrue: 
		[ClipStatus := aString.
		^self].
	self tclEval: 'clipboard append -- ' , aString asTkString.
	ClipStatus := true
    ]

    Blox class >> createColor: red green: green blue: blue [
	"Answer a color that can be passed to methods such as `backgroundColor:'.
	 The color will have the given RGB components (range is 0~65535)."

	"The answer is actually a String with an X color name, like
	 '#FFFFC000C000' for pink"

	<category: 'utility'>
	^(String new: 13)
	    at: 1 put: $#;
	    at: 2 put: (Character digitValue: ((red bitShift: -12) bitAnd: 15));
	    at: 3 put: (Character digitValue: ((red bitShift: -8) bitAnd: 15));
	    at: 4 put: (Character digitValue: ((red bitShift: -4) bitAnd: 15));
	    at: 5 put: (Character digitValue: (red bitAnd: 15));
	    at: 6 put: (Character digitValue: ((green bitShift: -12) bitAnd: 15));
	    at: 7 put: (Character digitValue: ((green bitShift: -8) bitAnd: 15));
	    at: 8 put: (Character digitValue: ((green bitShift: -4) bitAnd: 15));
	    at: 9 put: (Character digitValue: (green bitAnd: 15));
	    at: 10 put: (Character digitValue: ((blue bitShift: -12) bitAnd: 15));
	    at: 11 put: (Character digitValue: ((blue bitShift: -8) bitAnd: 15));
	    at: 12 put: (Character digitValue: ((blue bitShift: -4) bitAnd: 15));
	    at: 13 put: (Character digitValue: (blue bitAnd: 15));
	    yourself
    ]

    Blox class >> createColor: cyan magenta: magenta yellow: yellow [
	"Answer a color that can be passed to methods such as `backgroundColor:'.
	 The color will have the given CMY components (range is 0~65535)."

	<category: 'utility'>
	^self 
	    createColor: 65535 - cyan
	    green: 65535 - magenta
	    blue: 65535 - yellow
    ]

    Blox class >> createColor: cyan magenta: magenta yellow: yellow black: black [
	"Answer a color that can be passed to methods such as `backgroundColor:'.
	 The color will have the given CMYK components (range is 0~65535)."

	<category: 'utility'>
	| base |
	base := 65535 - black.
	^self 
	    createColor: (base - cyan max: 0)
	    green: (base - magenta max: 0)
	    blue: (base - yellow max: 0)
    ]

    Blox class >> createColor: hue saturation: sat value: value [
	"Answer a color that can be passed to methods such as `backgroundColor:'.
	 The color will have the given HSV components (range is 0~65535)."

	<category: 'utility'>
	| hue6 f val index components |
	hue6 := hue \\ 1 * 6.
	index := hue6 integerPart + 1.	"Which of the six slices of the hue circle"
	f := hue6 fractionPart.	"Where in the slice of the hue circle"
	val := 65535 * value.
	components := Array 
		    with: val
		    with: val * (1 - sat)
		    with: val * (1 - (sat * f))
		    with: val * (1 - (sat * (1 - f))).	"v"	"p"	"q"	"t"
	^self 
	    createColor: (components at: (#(1 3 2 2 4 1) at: index)) floor
	    green: (components at: (#(4 1 1 3 2 2) at: index)) floor
	    blue: (components at: (#(2 2 4 1 1 3) at: index)) floor
    ]

    Blox class >> fonts [
	"Answer the names of the font families in the system. Additionally,
	 `Times', `Courier' and `Helvetica' are always made available."

	<category: 'utility'>
	| stream result font ch |
	self tclEval: 'lsort [font families]'.
	stream := ReadStream on: self tclResult.
	result := WriteStream on: (Array new: stream size // 10).
	[stream atEnd] whileFalse: 
		[(ch := stream next) isSeparator 
		    ifFalse: 
			[ch = ${ 
			    ifTrue: [font := stream upTo: $}]
			    ifFalse: [font := ch asString , (stream upTo: $ )].
			result nextPut: font]].
	^result contents
    ]

    Blox class >> mousePointer [
	"If the mouse pointer is on the same screen as the application's windows,
	 returns a Point containing the pointer's x and y coordinates measured
	 in pixels in the screen's root window (under X, if a virtual root window
	 is in use on the screen, the position is computed in the whole desktop,
	 not relative to the top-left corner of the currently shown portion).
	 If the mouse pointer isn't on the same screen as window then answer nil."

	<category: 'utility'>
	| x y |
	x := CIntType gcNew.
	y := CIntType gcNew.
	GdkDisplay getDefault 
	    getPointer: nil
	    x: x
	    y: y
	    mask: nil.
	^x value @ y value.
    ]

    Blox class >> platform [
	"Answer the platform on which Blox is running; it can be either
	 #unix, #macintosh or #windows."

	<category: 'utility'>
	(Features includes: #WIN32) ifTrue: [^#windows].
	^#unix
    ]

    Blox class >> screenOrigin [
	"Answer a Point indicating the coordinates of the upper left point of the
	 screen in the virtual root window on which the application's windows are
	 drawn (under Windows and the Macintosh, that's always 0 @ 0)"

	<category: 'utility'>
	| x y |
	x := CIntType gcNew.
	y := CIntType gcNew.
	Gdk getDefaultRootWindow getOrigin: x y: y.
	^x value negated @ y value negated.
    ]

    Blox class >> screenResolution [
	"Answer a Point containing the resolution in dots per inch of the screen,
	 in the x and y directions."

	<category: 'utility'>
	| screen |
	screen := GdkScreen getDefault.
	^(screen getWidth * 25.4 / screen getWidthMm) 
	    @ (screen getHeight * 25.4 / screen getHeightMm)
    ]

    Blox class >> screenSize [
	"Answer a Point containing the size of the virtual root window on which the
	 application's windows are drawn (under Windows and the Macintosh, that's
	 the size of the screen)"

	<category: 'utility'>
	| height width |
	width := CIntType gcNew.
	height := CIntType gcNew.
	Gdk getDefaultRootWindow getSize: width height: height.
	^width value @ height value
    ]

    state [
	"Answer the value of the state option for the widget.
	 
	 Specifies one of three states for the button: normal, active, or disabled.
	 In normal state the button is displayed using the foreground and background
	 options. The active state is typically used when the pointer is over the
	 button. In active state the button is displayed using the activeForeground
	 and activeBackground options. Disabled state means that the button should
	 be insensitive: the application will refuse to activate the widget and
	 will ignore mouse button presses."

	<category: 'accessing'>
	| state |
	state := self connected getState.
	state = Gtk gtkStateActive ifTrue: [^#active].
	state = Gtk gtkStateInsensitive ifTrue: [^#disabled].
	state = Gtk gtkStateSelected ifTrue: [^#active].
	state = Gtk gtkStatePrelight ifTrue: [^#normal].
	^#normal
    ]

    state: value [
	"Set the value of the state option for the widget.
	 
	 Specifies one of three states for the button: normal, active, or disabled.
	 In normal state the button is displayed using the foreground and background
	 options. The active state is typically used when the pointer is over the
	 button. In active state the button is displayed using the activeForeground
	 and activeBackground options. Disabled state means that the button should
	 be insensitive: the application will refuse to activate the widget and
	 will ignore mouse button presses."

	<category: 'accessing'>
	| state |
	self state = value ifTrue: [^self].
	value = #disabled 
	    ifTrue: [self connected setSensitive: false]
	    ifFalse: 
		[value = #active 
		    ifTrue: [self connected setState: Gtk gtkStateActive]
		    ifFalse: 
			[value = #normal 
			    ifTrue: [self connected setState: Gtk gtkStateNormal]
			    ifFalse: [self error: 'invalid state value']]]
    ]

    deepCopy [
	"It does not make sense to make a copy, because it would
	 make data inconsistent across different objects; so answer
	 the receiver"

	<category: 'basic'>
	^self
    ]

    release [
	"Destroy the receiver if it still exists, then perform the
	 usual task of removing the dependency links"

	<category: 'basic'>
	self connected destroy.
	super release
    ]

    shallowCopy [
	"It does not make sense to make a copy, because it would
	 make data inconsistent across different objects; so answer
	 the receiver"

	<category: 'basic'>
	^self
    ]

    make: array [
	"Create children of the receiver. Answer a Dictionary of the children.
	 Each element of array is an Array including: a string which becomes
	 the Dictionary's key, a binding like #{Blox.BWindow} identifying the
	 class name, an array with the parameters to be set (for example
	 #(#width: 50 #height: 30 #backgroundColor: 'blue')), and afterwards
	 the children of the widget, described as arrays with this same format."

	<category: 'creating children'>
	^self make: array on: LookupTable new
    ]

    make: array on: result [
	"Private - Create children of the receiver, adding them to result;
	 answer result. array has the format described in the comment to #make:"

	<category: 'creating children'>
	array do: [:each | self makeChild: each on: result].
	^result
    ]

    makeChild: each on: result [
	"Private - Create a child of the receiver, adding them to result;
	 each is a single element of the array described in the comment to #make:"

	<category: 'creating children'>
	| current selector |
	current := result at: (each at: 1) put: ((each at: 2) value new: self).
	each at: 3
	    do: 
		[:param | 
		selector isNil 
		    ifTrue: [selector := param]
		    ifFalse: 
			[current perform: selector with: param.
			selector := nil]].
	each size > 3 ifFalse: [^result].
	each 
	    from: 4
	    to: each size
	    do: [:child | current makeChild: child on: result]
    ]

    addChild: child [
	"The widget identified by child has been added to the receiver.
	 This method is public not because you can call it, but because
	 it can be useful to override it to perform some initialization
	 on the children as they are added. Answer the new child."

	<category: 'customization'>
	
    ]

    basicAddChild: child [
	"The widget identified by child has been added to the receiver.
	 Add it to the children collection and answer the new child.
	 This method does nothing but is present for compatibility
	 with Tk."

	<category: 'customization'>
	
    ]

    primAddChild: child [
	"The widget identified by child has been added to the receiver.
	 Add it to the children collection and answer the new child."

	<category: 'customization'>
	^children addLast: child
    ]

    connected [
	"Private - Answer the name of Tk widget for the connected widget.
	 This widget is used for most options and for event binding."

	<category: 'private'>
	^self asPrimitiveWidget connected
    ]

    container [
	"Private - Answer the name of Tk widget for the container widget.
	 This widget is used for geometry management."

	<category: 'private'>
	^self asPrimitiveWidget connected
    ]

    destroyed [
	"Private - The receiver has been destroyed, clear the instance
	 variables to release some memory."

	<category: 'private'>
	children := parent := nil
    ]

    initialize: parentWidget [
	"This is called by #new: to initialize the widget (as the name
	 says...). The default implementation initializes the receiver's
	 instance variables. This method is public not because you can
	 call it, but because it might be useful to override it. Always
	 answer the receiver."

	<category: 'private'>
	parent := parentWidget.
	properties := IdentityDictionary new.
	children := OrderedCollection new.
	self parent isNil ifFalse: [self parent primAddChild: self]
    ]

    connectSignal: aString to: anObject selector: aSymbol userData: userData [
	<category: 'private'>
	self asPrimitiveWidget connected 
	    connectSignal: aString
	    to: anObject
	    selector: aSymbol
	    userData: userData
    ]

    properties [
	"Private - Answer the properties dictionary"

	<category: 'private'>
	^properties
    ]

    tclEval: tclCode [
	"Private - Evaluate the given Tcl code; if it raises an exception,
	 raise it as a Smalltalk error"

	<category: 'private - Tcl'>
	stdout
	    nextPutAll: tclCode;
	    nl;
	    flush.
	self notYetImplemented
    ]

    tclEval: tclCode with: arg1 [
	"Private - Evaluate the given Tcl code, replacing %1 with arg1; if
	 it raises an exception, raise it as a Smalltalk error"

	<category: 'private - Tcl'>
	self notYetImplemented
    ]

    tclEval: tclCode with: arg1 with: arg2 [
	"Private - Evaluate the given Tcl code, replacing %1 with arg1
	 and %2 with arg2; if it raises an exception, raise it as a
	 Smalltalk error"

	<category: 'private - Tcl'>
	self notYetImplemented
    ]

    tclEval: tclCode with: arg1 with: arg2 with: arg3 [
	"Private - Evaluate the given Tcl code, replacing %1 with arg1,
	 %2 with arg2 and %3 with arg3; if it raises an exception, raise
	 it as a Smalltalk error"

	<category: 'private - Tcl'>
	self notYetImplemented
    ]

    tclEval: tclCode with: arg1 with: arg2 with: arg3 with: arg4 [
	"Private - Evaluate the given Tcl code, replacing %1 with arg1,
	 %2 with arg2, and so on; if it raises an exception, raise
	 it as a Smalltalk error"

	<category: 'private - Tcl'>
	self notYetImplemented
    ]

    tclEval: tclCode withArguments: anArray [
	"Private - Evaluate the given Tcl code, replacing %n with the
	 n-th element of anArray; if it raises an exception, raise
	 it as a Smalltalk error"

	<category: 'private - Tcl'>
	self notYetImplemented
    ]

    tclResult [
	"Private - Return the result code for Tcl, as a Smalltalk String."

	<category: 'private - Tcl'>
	self notYetImplemented
    ]

    asPrimitiveWidget [
	"Answer the primitive widget that implements the receiver."

	<category: 'widget protocol'>
	self subclassResponsibility
    ]

    childrenCount [
	"Answer how many children the receiver has"

	<category: 'widget protocol'>
	^children size
    ]

    childrenDo: aBlock [
	"Evaluate aBlock once for each of the receiver's child widgets, passing
	 the widget to aBlock as a parameter"

	<category: 'widget protocol'>
	children do: aBlock
    ]

    destroy [
	"Destroy the receiver"

	<category: 'widget protocol'>
	self container destroy
    ]

    drawingArea [
	"Answer a Rectangle identifying the receiver's drawing area.  The
	 rectangle's corners specify the upper-left and lower-right corners
	 of the client area.  Because coordinates are relative to the
	 upper-left corner of a window's drawing area, the coordinates of
	 the rectangle's corner are (0,0)."

	<category: 'widget protocol'>
	^0 @ 0 corner: self widthAbsolute @ self heightAbsolute
    ]

    enabled [
	"Answer whether the receiver is enabled to input. Although defined
	 here, this method is only used for widgets that define a
	 #state method"

	<category: 'widget protocol'>
	^self state ~= #disabled
    ]

    enabled: enabled [
	"Set whether the receiver is enabled to input (enabled is a boolean).
	 Although defined here, this method is only used for widgets that
	 define a #state: method"

	<category: 'widget protocol'>
	self state: (enabled ifTrue: [#normal] ifFalse: [#disabled])
    ]

    exists [
	"Answer whether the receiver has been destroyed or not (answer false
	 in the former case, true in the latter)."

	<category: 'widget protocol'>
	^self asPrimitiveWidget exists
    ]

    fontHeight: aString [
	"Answer the height of aString in pixels, when displayed in the same
	 font as the receiver.  Although defined here, this method is only
	 used for widgets that define a #font method"

	<category: 'widget protocol'>
	self tclEval: 'font metrics %1 -linespace' with: self font asTkString.
	^((aString occurrencesOf: Character nl) + 1) * self tclResult asNumber
    ]

    fontWidth: aString [
	"Answer the width of aString in pixels, when displayed in the same
	 font as the receiver.  Although defined here, this method is only
	 used for widgets that define a #font method"

	<category: 'widget protocol'>
	self 
	    tclEval: 'font measure %1 %2'
	    with: self font asTkString
	    with: aString asTkString.
	^self tclResult asNumber
    ]

    isWindow [
	"Answer whether the receiver represents a window on the screen."

	<category: 'widget protocol'>
	^false
    ]

    parent [
	"Answer the receiver's parent (or nil for a top-level window)."

	<category: 'widget protocol'>
	^parent
    ]

    toplevel [
	"Answer the top-level object (typically a BWindow or BPopupWindow)
	 connected to the receiver."

	<category: 'widget protocol'>
	self parent isNil ifTrue: [^self].
	^self parent toplevel
    ]

    window [
	"Answer the window in which the receiver stays. Note that while
	 #toplevel won't answer a BTransientWindow, this method will."

	<category: 'widget protocol'>
	^self parent window
    ]

    withChildrenDo: aBlock [
	"Evaluate aBlock passing the receiver, and then once for each of the
	 receiver's child widgets."

	<category: 'widget protocol'>
	self value: aBlock.
	self childrenDo: aBlock
    ]
]



Blox subclass: BWidget [
    | connected |
    
    <category: 'Graphics-Windows'>
    <comment: 'I am the superclass for every widget except those related to
menus. I provide more common methods and geometry management'>

    BWidget class >> new [
	"Create an instance of the receiver inside a BPopupWindow; do
	 not map the window, answer the new widget.  The created widget
	 will become a child of the window and be completely attached
	 to it (e.g. the geometry methods will modify the window's geometry).
	 Note that while the widget *seems* to be directly painted on
	 the root window, it actually belongs to the BPopupWindow; so
	 don't send #destroy to the widget to remove it, but rather
	 to the window."

	<category: 'popups'>
	^self new: BPopupWindow new
    ]

    BWidget class >> popup: initializationBlock [
	"Create an instance of the receiver inside a BPopupWindow; before
	 returning, pass the widget to the supplied initializationBlock,
	 then map the window.  Answer the new widget.  The created widget
	 will become a child of the window and be completely attached
	 to it (e.g. the geometry methods will modify the window's geometry).
	 Note that while the widget *seems* to be directly painted on
	 the root window, it actually belongs to the BPopupWindow; so
	 don't send #destroy to the widget to remove it, but rather
	 to the window."

	<category: 'popups'>
	| widget window |
	window := BPopupWindow new.
	widget := self new: window.
	initializationBlock value: widget.
	window map.
	^widget
    ]

    borderWidth [
	"Answer the value of the borderWidth option for the widget.
	 
	 Specifies a non-negative value indicating the width of the 3-D border to
	 draw around the outside of the widget (if such a border is being drawn; the
	 effect option typically determines this). The value may also be used when
	 drawing 3-D effects in the interior of the widget. The value is measured in
	 pixels."

	<category: 'accessing'>
	self properties at: #border ifPresent: [:value | ^value].
	self 
	    tclEval: '%2 cget -borderwidth'
	    with: self connected
	    with: self container.
	^self properties at: #border put: self tclResult asInteger
    ]

    borderWidth: value [
	"Set the value of the borderWidth option for the widget.
	 
	 Specifies a non-negative value indicating the width of the 3-D border to
	 draw around the outside of the widget (if such a border is being drawn; the
	 effect option typically determines this). The value may also be used when
	 drawing 3-D effects in the interior of the widget. The value is measured in
	 pixels."

	<category: 'accessing'>
	self 
	    tclEval: '%2 configure -borderwidth %3'
	    with: self connected
	    with: self container
	    with: value printString asTkString.
	self properties at: #border put: value
    ]

    cursor [
	"Answer the value of the cursor option for the widget.
	 
	 Specifies the mouse cursor to be used for the widget. The value of the
	 option is given by the standard X cursor cursor, i.e., any of
	 the names defined in cursorcursor.h, without the leading XC_."

	<category: 'accessing'>
	self properties at: #cursor ifPresent: [:value | ^value].
	self 
	    tclEval: '%1 cget -cursor'
	    with: self connected
	    with: self container.
	^self properties at: #cursor put: self tclResult asSymbol
    ]

    cursor: value [
	"Set the value of the cursor option for the widget.
	 
	 Specifies the mouse cursor to be used for the widget. The value of the
	 option is given by the standard X cursor cursor, i.e., any of
	 the names defined in cursorcursor.h, without the leading XC_."

	<category: 'accessing'>
	self 
	    tclEval: '%1 configure -cursor %3'
	    with: self connected
	    with: self container
	    with: value asTkString.
	self properties at: #cursor put: value
    ]

    effect [
	"Answer the value of the effect option for the widget.
	 
	 Specifies the effect desired for the widget's border. Acceptable values are
	 raised, sunken, flat, ridge, solid, and groove. The value indicates how the
	 interior of the widget should appear relative to its exterior; for example,
	 raised means the interior of the widget should appear to protrude from the
	 screen, relative to the exterior of the widget. Raised and sunken give the
	 traditional 3-D appearance (for example, that of Xaw3D), while ridge and groove
	 give a ``chiseled'' appearance like that of Swing or GTK+'s Metal theme. Flat
	 and solid are not 3-D."

	<category: 'accessing'>
	self properties at: #effect ifPresent: [:value | ^value].
	self 
	    tclEval: '%2 cget -relief'
	    with: self connected
	    with: self container.
	^self properties at: #effect put: self tclResult asSymbol
    ]

    effect: value [
	"Set the value of the effect option for the widget.
	 
	 Specifies the effect desired for the widget's border. Acceptable values are
	 raised, sunken, flat, ridge, solid, and groove. The value indicates how the
	 interior of the widget should appear relative to its exterior; for example,
	 raised means the interior of the widget should appear to protrude from the
	 screen, relative to the exterior of the widget. Raised and sunken give the
	 traditional 3-D appearance (for example, that of Xaw3D), while ridge and groove
	 give a ``chiseled'' appearance like that of Swing or GTK+'s Metal theme. Flat
	 and solid are not 3-D."

	<category: 'accessing'>
	self 
	    tclEval: '%2 configure -relief %3'
	    with: self connected
	    with: self container
	    with: value asTkString.
	self properties at: #effect put: value
    ]

    tabStop [
	"Answer the value of the tabStop option for the widget.
	 
	 Determines whether the window accepts the focus during keyboard traversal
	 (e.g., Tab and Shift-Tab). Before setting the focus to a window, Blox
	 consults the value of the tabStop option. A value of false
	 means that the window should be skipped entirely during keyboard traversal.
	 true means that the window should receive the input focus as long as it is
	 viewable (it and all of its ancestors are mapped). If you do not set this
	 option, Blox makes the decision about whether or
	 not to focus on the window: the current algorithm is to skip the window if
	 it is disabled, it has no key bindings, or if it is not viewable. Of the
	 standard widgets, BForm, BContainer, BLabel and BImage have no key bindings
	 by default."

	<category: 'accessing'>
	self properties at: #takefocus ifPresent: [:value | ^value].
	self 
	    tclEval: '%1 cget -takefocus'
	    with: self connected
	    with: self container.
	^self properties at: #takefocus put: self tclResult == '1'
    ]

    tabStop: value [
	"Set the value of the tabStop option for the widget.
	 
	 Determines whether the window accepts the focus during keyboard traversal
	 (e.g., Tab and Shift-Tab). Before setting the focus to a window, Blox
	 consults the value of the tabStop option. A value of false
	 means that the window should be skipped entirely during keyboard traversal.
	 true means that the window should receive the input focus as long as it is
	 viewable (it and all of its ancestors are mapped). If you do not set this
	 option, Blox makes the decision about whether or
	 not to focus on the window: the current algorithm is to skip the window if
	 it is disabled, it has no key bindings, or if it is not viewable. Of the
	 standard widgets, BForm, BContainer, BLabel and BImage have no key bindings
	 by default."

	<category: 'accessing'>
	self 
	    tclEval: '%1 configure -takefocus %3'
	    with: self connected
	    with: self container
	    with: value asCBooleanValue printString asTkString.
	self properties at: #takefocus put: value
    ]

    create [
	"Make the receiver able to respond to its widget protocol.
	 This method is public not because you can call it, but because
	 it can be useful to override it, not forgetting the call to
	 super, to perform some initialization on the primitive
	 widget just created; for an example of this, see the
	 implementation of BButtonLike."

	<category: 'customization'>
	self subclassResponsibility
    ]

    onDestroy: object data: data [
	<category: 'customization'>
	self destroyed
    ]

    setInitialSize [
	"This is called by #createWidget to set the widget's initial size.
	 The whole area is occupied by default. This method is public
	 not because you can call it, but because it can be useful to
	 override it."

	<category: 'customization'>
	
    ]

    container [
	"The outermost object implementing this widget is the same as the innermost
	 object, by default (the exception being mostly BViewport and subclasses)."

	<category: 'customization'>
	^self connected
    ]

    activate [
	"At any given time, one window on each display is designated
	 as the focus window; any key press or key release events for
	 the display are sent to that window. This method allows one
	 to choose which window will have the focus in the receiver's
	 display
	 
	 If the application currently has the input focus on the receiver's
	 display, this method resets the input focus for the receiver's
	 display to the receiver. If the application doesn't currently have the
	 input focus on the receiver's display, Blox will remember the receiver
	 as the focus for its top-level; the next time the focus arrives at the
	 top-level, it will be redirected to the receiver (this is because
	 most window managers will set the focus only to top-level windows,
	 leaving it up to the application to redirect the focus among the
	 children of the top-level)."

	<category: 'widget protocol'>
	self connected grabFocus
    ]

    activateNext [
	"Activate the next widget in the focus `tabbing' order.  The focus
	 order depends on the widget creation order; you can set which widgets
	 are in the order with the #tabStop: method."

	<category: 'widget protocol'>
	self tclEval: 'focus [ tk_focusNext %1 ]' with: self connected
    ]

    activatePrevious [
	"Activate the previous widget in the focus `tabbing' order.  The focus
	 order depends on the widget creation order; you can set which widgets
	 are in the order with the #tabStop: method."

	<category: 'widget protocol'>
	self tclEval: 'focus [ tk_focusPrev %1 ]' with: self connected
    ]

    bringToTop [
	"Raise the receiver so that it is above all of its siblings in the
	 widgets' z-order; the receiver will not be obscured by any siblings and
	 will obscure any siblings that overlap it."

	<category: 'widget protocol'>
	| w |
	w := self connected getWindow.
	w isNil ifTrue: [w := self container getWindow].
	w isNil ifFalse: [^w raise]
    ]

    sendToBack [
	"Lower the receiver so that it is below all of its siblings in the
	 widgets' z-order; the receiver will be obscured by any siblings that
	 overlap it and will not obscure any siblings."

	<category: 'widget protocol'>
	| w |
	w := self connected getWindow.
	w isNil ifTrue: [w := self container getWindow].
	w isNil ifFalse: [^w lower]
    ]

    isActive [
	"Return whether the receiver is the window that currently owns the focus
	 on its display."

	<category: 'widget protocol'>
	^(self connected flags bitAnd: Gtk gtkHasFocus) > 0
    ]

    boundingBox [
	"Answer a Rectangle containing the bounding box of the receiver"

	<category: 'geometry management'>
	^self x @ self y extent: self width @ self height
    ]

    boundingBox: rect [
	"Set the bounding box of the receiver to rect (a Rectangle)."

	<category: 'geometry management'>
	self 
	    left: rect left
	    top: rect top
	    right: rect right
	    bottom: rect bottom
    ]

    extent [
	"Answer a Point containing the receiver's size"

	<category: 'geometry management'>
	^self width @ self height
    ]

    extent: extent [
	"Set the receiver's size to the width and height contained in extent
	 (a Point)."

	<category: 'geometry management'>
	self width: extent x height: extent y
    ]

    height [
	"Answer the `variable' part of the receiver's height within the parent
	 widget. The value returned does not include any fixed amount of
	 pixels indicated by #heightOffset: and must be interpreted in a relative
	 fashion: the ratio of the returned value to the current size of the
	 parent will be preserved upon resize. This apparently complicated
	 method is known as `rubber sheet' geometry management.  Behavior
	 if the left or right edges are not within the client area of the
	 parent is not defined -- the window might be clamped or might be
	 positioned according to the specification."

	<category: 'geometry management'>
	^self parent heightChild: self
    ]

    height: value [
	"Set to `value' the height of the widget within the parent widget. The
	 value is specified in a relative fashion as an integer, so that the
	 ratio of `value' to the current size of the parent will be
	 preserved upon resize. This apparently complicated method is known
	 as `rubber sheet' geometry management."

	<category: 'geometry management'>
	self parent child: self height: value
    ]

    heightAbsolute [
	"Force a recalculation of the layout of widgets in the receiver's
	 parent, then answer the current height of the receiver in pixels."

	<category: 'geometry management'>
	| h |
	h := self container getAllocation height.
	^h = -1 ifTrue: [self height] ifFalse: [h]
    ]

    heightOffset [
	"Private - Answer the pixels to be added or subtracted to the height
	 of the receiver, with respect to the value set in a relative fashion
	 through the #height: method."

	<category: 'geometry management'>
	^self properties at: #heightGeomOfs ifAbsent: [0]
    ]

    heightOffset: value [
	"Add or subtract to the height of the receiver a fixed amount of `value'
	 pixels, with respect to the value set in a relative fashion through
	 the #height: method.  Usage of this method is deprecated; use #inset:
	 and BContainers instead."

	<category: 'geometry management'>
	self properties at: #heightGeomOfs put: value.
	self parent child: self heightOffset: value
    ]

    heightPixels: value [
	"Set the current height of the receiver to `value' pixels. Note that,
	 after calling this method, #height will answer 0, which is logical
	 considering that there is no `variable' part of the size (refer
	 to #height and #height: for more explanations)."

	<category: 'geometry management'>
	self
	    height: 0;
	    heightOffset: value
    ]

    inset: pixels [
	"Inset the receiver's bounding box by the specified amount."

	<category: 'geometry management'>
	self parent child: self inset: pixels
    ]

    left: left top: top right: right bottom: bottom [
	"Set the bounding box of the receiver through its components."

	<category: 'geometry management'>
	self 
	    x: left
	    y: top
	    width: right - left + 1
	    height: bottom - top + 1
    ]

    pos: position [
	"Set the receiver's origin to the width and height contained in position
	 (a Point)."

	<category: 'geometry management'>
	self x: position x y: position y
    ]

    posHoriz: aBlox [
	"Position the receiver immediately to the right of aBlox."

	<category: 'geometry management'>
	| x width |
	width := aBlox width.
	self x: width + aBlox x y: aBlox y.
	width = 0 
	    ifTrue: 
		[width := aBlox widthAbsolute.
		self xOffset: width.
		self width > 0 ifTrue: [self widthOffset: self widthOffset - width]]
    ]

    posVert: aBlox [
	"Position the receiver just below aBlox."

	<category: 'geometry management'>
	| y height |
	height := aBlox height.
	self x: aBlox x y: height + aBlox y.
	height = 0 
	    ifTrue: 
		[height := aBlox heightAbsolute.
		self yOffset: height.
		self height > 0 ifTrue: [self heightOffset: self heightOffset - height]]
    ]

    stretch: aBoolean [
	"This method is only considered when on the path from the receiver
	 to its toplevel there is a BContainer.  It decides whether we are
	 among the widgets that are stretched to fill the entire width of
	 the BContainer."

	<category: 'geometry management'>
	self parent child: self stretch: aBoolean.
	self properties at: #stretch put: aBoolean
    ]

    width [
	"Answer the `variable' part of the receiver's width within the parent
	 widget. The value returned does not include any fixed amount of
	 pixels indicated by #widthOffset: and must be interpreted in a relative
	 fashion: the ratio of the returned value to the current size of the
	 parent will be preserved upon resize. This apparently complicated
	 method is known as `rubber sheet' geometry management.  Behavior
	 if the left or right edges are not within the client area of the
	 parent is not defined -- the window might be clamped or might be
	 positioned according to the specification."

	<category: 'geometry management'>
	^self parent widthChild: self
    ]

    width: value [
	"Set to `value' the width of the widget within the parent widget. The
	 value is specified in a relative fashion as an integer, so that the
	 ratio of `value' to the current size of the parent will be
	 preserved upon resize. This apparently complicated method is known
	 as `rubber sheet' geometry management."

	<category: 'geometry management'>
	self parent child: self width: value
    ]

    width: width height: height [
	"change my dimensions"

	<category: 'geometry management'>
	self
	    width: width;
	    height: height
    ]

    widthAbsolute [
	"Force a recalculation of the layout of widgets in the receiver's
	 parent, then answer the current width of the receiver in pixels."

	<category: 'geometry management'>
	| w |
	w := self container getAllocation width.
	^w = -1 ifTrue: [self width] ifFalse: [w]
    ]

    widthOffset [
	"Private - Answer the pixels to be added or subtracted to the width
	 of the receiver, with respect to the value set in a relative fashion
	 through the #width: method."

	<category: 'geometry management'>
	^self properties at: #widthGeomOfs ifAbsent: [0]
    ]

    widthOffset: value [
	"Add or subtract to the width of the receiver a fixed amount of `value'
	 pixels, with respect to the value set in a relative fashion through
	 the #width: method.  Usage of this method is deprecated; use #inset:
	 and BContainers instead."

	<category: 'geometry management'>
	self properties at: #widthGeomOfs put: value.
	self parent child: self widthOffset: value
    ]

    widthPixels: value [
	"Set the current width of the receiver to `value' pixels. Note that,
	 after calling this method, #width will answer 0, which is logical
	 considering that there is no `variable' part of the size (refer
	 to #width and #width: for more explanations)."

	<category: 'geometry management'>
	self
	    width: 0;
	    widthOffset: value
    ]

    x [
	"Answer the `variable' part of the receiver's x within the parent
	 widget. The value returned does not include any fixed amount of
	 pixels indicated by #xOffset: and must be interpreted in a relative
	 fashion: the ratio of the returned value to the current size of the
	 parent will be preserved upon resize. This apparently complicated
	 method is known as `rubber sheet' geometry management.  Behavior
	 if the left or right edges are not within the client area of the
	 parent is not defined -- the window might be clamped or might be
	 positioned according to the specification."

	<category: 'geometry management'>
	^self parent xChild: self
    ]

    x: value [
	"Set to `value' the x of the widget within the parent widget. The
	 value is specified in a relative fashion as an integer, so that the
	 ratio of `value' to the current size of the parent will be
	 preserved upon resize. This apparently complicated method is known
	 as `rubber sheet' geometry management."

	<category: 'geometry management'>
	self parent child: self x: value
    ]

    x: xPos y: yPos [
	"Set the origin of the receiver through its components xPos and yPos."

	<category: 'geometry management'>
	self
	    x: xPos;
	    y: yPos
    ]

    x: xPos y: yPos width: xSize height: ySize [
	"Set the bounding box of the receiver through its origin and
	 size."

	<category: 'geometry management'>
	self
	    x: xPos y: yPos;
	    width: xSize height: ySize
    ]

    xAbsolute [
	"Force a recalculation of the layout of widgets in the receiver's
	 parent, then answer the current x of the receiver in pixels."

	<category: 'geometry management'>
	| x |
	x := self container getAllocation left.
	^x = -1 ifTrue: [self left] ifFalse: [x]
    ]

    xOffset [
	"Private - Answer the pixels to be added or subtracted to the x
	 of the receiver, with respect to the value set in a relative fashion
	 through the #x: method."

	<category: 'geometry management'>
	^self properties at: #xGeomOfs ifAbsent: [0]
    ]

    xOffset: value [
	"Add or subtract to the x of the receiver a fixed amount of `value'
	 pixels, with respect to the value set in a relative fashion through
	 the #x: method.  Usage of this method is deprecated; use #inset:
	 and BContainers instead."

	<category: 'geometry management'>
	self properties at: #xGeomOfs put: value.
	self parent child: self xOffset: value
    ]

    xPixels: value [
	"Set the current x of the receiver to `value' pixels. Note that,
	 after calling this method, #x will answer 0, which is logical
	 considering that there is no `variable' part of the size (refer
	 to #x and #x: for more explanations)."

	<category: 'geometry management'>
	self
	    x: 0;
	    xOffset: value
    ]

    xRoot [
	"Answer the x position of the receiver with respect to the
	 top-left corner of the desktop (including the offset of the
	 virtual root window under X)."

	<category: 'geometry management'>
	self tclEval: 'expr [winfo rootx %1] + [winfo vrootx %1]'
	    with: self container.
	^self tclResult asInteger
    ]

    y [
	"Answer the `variable' part of the receiver's y within the parent
	 widget. The value returned does not include any fixed amount of
	 pixels indicated by #yOffset: and must be interpreted in a relative
	 fashion: the ratio of the returned value to the current size of the
	 parent will be preserved upon resize. This apparently complicated
	 method is known as `rubber sheet' geometry management.  Behavior
	 if the left or right edges are not within the client area of the
	 parent is not defined -- the window might be clamped or might be
	 positioned according to the specification."

	<category: 'geometry management'>
	^self parent yChild: self
    ]

    y: value [
	"Set to `value' the y of the widget within the parent widget. The
	 value is specified in a relative fashion as an integer, so that the
	 ratio of `value' to the current size of the parent will be
	 preserved upon resize. This apparently complicated method is known
	 as `rubber sheet' geometry management."

	<category: 'geometry management'>
	self parent child: self y: value
    ]

    yAbsolute [
	"Force a recalculation of the layout of widgets in the receiver's
	 parent, then answer the current y of the receiver in pixels."

	<category: 'geometry management'>
	| y |
	y := self container getAllocation top.
	^y = -1 ifTrue: [self top] ifFalse: [y]
    ]

    yOffset [
	"Private - Answer the pixels to be added or subtracted to the y
	 of the receiver, with respect to the value set in a relative fashion
	 through the #y: method."

	<category: 'geometry management'>
	^self properties at: #yGeomOfs ifAbsent: [0]
    ]

    yOffset: value [
	"Add or subtract to the y of the receiver a fixed amount of `value'
	 pixels, with respect to the value set in a relative fashion through
	 the #y: method.  Usage of this method is deprecated; use #inset:
	 and BContainers instead."

	<category: 'geometry management'>
	self properties at: #yGeomOfs put: value.
	self parent child: self yOffset: value
    ]

    yPixels: value [
	"Set the current y of the receiver to `value' pixels. Note that,
	 after calling this method, #y will answer 0, which is logical
	 considering that there is no `variable' part of the size (refer
	 to #y and #y: for more explanations)."

	<category: 'geometry management'>
	self
	    y: 0;
	    yOffset: value
    ]

    yRoot [
	"Answer the y position of the receiver with respect to the
	 top-left corner of the desktop (including the offset of the
	 virtual root window under X)."

	<category: 'geometry management'>
	self tclEval: 'expr [winfo rooty %1] + [winfo vrooty %1]'
	    with: self container.
	^self tclResult asInteger
    ]
]



BWidget subclass: BPrimitive [
    
    <category: 'Graphics-Windows'>
    <comment: '
I am the superclass for every widget (except menus) directly
provided by the underlying GUI system.'>

    asPrimitiveWidget [
	"Answer the primitive widget that implements the receiver."

	<category: 'accessing'>
	^self
    ]

    exists [
	"Answer whether the receiver has been destroyed or not (answer false
	 in the former case, true in the latter)."

	<category: 'accessing'>
	^connected notNil
    ]

    destroyed [
	"Private - The receiver has been destroyed, clear the instance
	 variables to release some memory."

	<category: 'private'>
	super destroyed.
	connected := nil
    ]

    connected [
	"answer the gtk native object that is used for geometry mgmt & layout"

	<category: 'private'>
	connected isNil ifTrue: [self createWidget].
	^connected
    ]

    connected: anObject [
	"set the current gtk native object"

	<category: 'private'>
	connected := anObject
    ]

    createWidget [
	<category: 'private'>
	self create.
	self show.
	self setInitialSize.
	self parent notNil ifTrue: [self parent addChild: self]
    ]

    show [
	<category: 'private'>
	(self connected)
	    connectSignal: 'destroy'
		to: self
		selector: #onDestroy:data:
		userData: nil;
	    show
    ]
]



BWidget subclass: BExtended [
    | primitive |
    
    <category: 'Graphics-Windows'>
    <comment: 'Just like Gui, I serve as a base for complex objects which expose
an individual protocol but internally use a Blox widget for
creating their user interface. Unlike Gui, however, the
instances of my subclasses understand the standard widget protocol.
Just override my newPrimitive method to return another widget,
and you''ll get a class which interacts with the user like that
widget (a list box, a text box, or even a label) but exposes a
different protocol.'>

    asPrimitiveWidget [
	"Answer the primitive widget that implements the receiver."

	<category: 'accessing'>
	^primitive asPrimitiveWidget
    ]

    create [
	"After this method is called (the call is made automatically)
	 the receiver will be attached to a `primitive' widget (which
	 can be in turn another extended widget).
	 This method is public not because you can call it, but because
	 it can be useful to override it, not forgetting the call to
	 super (which only calls #newPrimitive and saves the result),
	 to perform some initialization on the primitive widget
	 just created; overriding #create is in fact more generic than
	 overriding #newPrimitive. For an example of this, see the
	 implementation of BButtonLike."

	<category: 'customization'>
	primitive := self newPrimitive
    ]

    newPrimitive [
	"Create and answer a new widget on which the implementation of the
	 receiver will be based. You should not call this method directly;
	 instead you must override it in BExtended's subclasses."

	<category: 'customization'>
	self subclassResponsibility
    ]
]



BPrimitive subclass: BViewport [
    | container horizontal vertical |
    
    <category: 'Graphics-Windows'>
    <comment: 'I represent an interface which is common to widgets that can be
scrolled, like list boxes or text widgets.'>

    container [
	"answer the gtk scrolled window"

	<category: 'accessing'>
	container isNil ifTrue: [self createWidget].
	^container
    ]

    container: aGtkWidget [
	<category: 'accessing'>
	container := aGtkWidget
    ]

    show [
	<category: 'creation'>
	self container: (GTK.GtkScrolledWindow new: nil vadjustment: nil).
	self container setPolicy: GTK.Gtk gtkPolicyAutomatic
	    vscrollbarPolicy: GTK.Gtk gtkPolicyAutomatic.
	horizontal := vertical := true.
	self needsViewport 
	    ifTrue: [self container addWithViewport: self connected]
	    ifFalse: [self container add: self connected].
	super show.
	self container show
    ]

    pickPolicy [
	<category: 'creation'>
	| hpolicy vpolicy |
	hpolicy := horizontal 
		    ifTrue: [GTK.Gtk gtkPolicyAutomatic]
		    ifFalse: [GTK.Gtk gtkPolicyNever].
	vpolicy := vertical 
		    ifTrue: [GTK.Gtk gtkPolicyAutomatic]
		    ifFalse: [GTK.Gtk gtkPolicyNever].
	self container setPolicy: hpolicy vscrollbarPolicy: vpolicy
    ]

    needsViewport [
	<category: 'creation'>
	^true
    ]

    horizontal [
	"Answer whether an horizontal scrollbar is drawn in the widget
	 if needed."

	<category: 'scrollbars'>
	^horizontal
    ]

    horizontal: aBoolean [
	"Set whether an horizontal scrollbar is drawn in the widget if
	 needed."

	<category: 'scrollbars'>
	horizontal := aBoolean.
	self pickPolicy
    ]

    horizontalNeeded [
	"Answer whether an horizontal scrollbar is needed to show all the
	 information in the widget."

	<category: 'scrollbars'>
	self 
	    tclEval: 'expr [lindex [%1 xview] 0] > 0 || [lindex [%1 xview] 1] < 1'
	    with: self connected.
	^self tclResult = '1'
    ]

    horizontalShown [
	"Answer whether an horizontal scrollbar is drawn in the widget."

	<category: 'scrollbars'>
	^self horizontal and: [self horizontalNeeded]
    ]

    vertical [
	"Answer whether a vertical scrollbar is drawn in the widget
	 if needed."

	<category: 'scrollbars'>
	^vertical
    ]

    vertical: aBoolean [
	"Set whether a vertical scrollbar is drawn in the widget if
	 needed."

	<category: 'scrollbars'>
	vertical := aBoolean.
	self pickPolicy
    ]

    verticalNeeded [
	"Answer whether a vertical scrollbar is needed to show all the
	 information in the widget."

	<category: 'scrollbars'>
	self 
	    tclEval: 'expr [lindex [%1 yview] 0] > 0 || [lindex [%1 yview] 1] < 1'
	    with: self connected.
	^self tclResult = '1'
    ]

    verticalShown [
	"Answer whether a vertical scrollbar is drawn in the widget."

	<category: 'scrollbars'>
	^self vertical and: [self verticalNeeded]
    ]
]



Blox subclass: BMenuObject [
    | childrensUnderline callback |
    
    <category: 'Graphics-Windows'>
    <comment: 'I am an abstract superclass for widgets which make up a menu structure.'>

    activeBackground [
	"Answer the value of the activeBackground option for the widget.
	 
	 Specifies background color to use when drawing active elements. An element
	 (a widget or portion of a widget) is active if the mouse cursor is positioned
	 over the element and pressing a mouse button will cause some action
	 to occur. For some elements on Windows and Macintosh systems, the active
	 color will only be used while mouse button 1 is pressed over the element."

	<category: 'accessing'>
	self properties at: #activebackground ifPresent: [:value | ^value].
	self 
	    tclEval: '%1 cget -activebackground'
	    with: self connected
	    with: self container.
	^self properties at: #activebackground put: self tclResult
    ]

    activeBackground: value [
	"Set the value of the activeBackground option for the widget.
	 
	 Specifies background color to use when drawing active elements. An element
	 (a widget or portion of a widget) is active if the mouse cursor is positioned
	 over the element and pressing a mouse button will cause some action
	 to occur. For some elements on Windows and Macintosh systems, the active
	 color will only be used while mouse button 1 is pressed over the element."

	<category: 'accessing'>
	self 
	    tclEval: '%1 configure -activebackground %3'
	    with: self connected
	    with: self container
	    with: value asTkString.
	self properties at: #activebackground put: value
    ]

    activeForeground [
	"Answer the value of the activeForeground option for the widget.
	 
	 Specifies foreground color to use when drawing active elements. See above
	 for definition of active elements."

	<category: 'accessing'>
	self properties at: #activeforeground ifPresent: [:value | ^value].
	self 
	    tclEval: '%1 cget -activeforeground'
	    with: self connected
	    with: self container.
	^self properties at: #activeforeground put: self tclResult
    ]

    activeForeground: value [
	"Set the value of the activeForeground option for the widget.
	 
	 Specifies foreground color to use when drawing active elements. See above
	 for definition of active elements."

	<category: 'accessing'>
	self 
	    tclEval: '%1 configure -activeforeground %3'
	    with: self connected
	    with: self container
	    with: value asTkString.
	self properties at: #activeforeground put: value
    ]

    asPrimitiveWidget [
	"Answer the primitive widget that implements the receiver."

	<category: 'accessing'>
	^self
    ]

    backgroundColor [
	"Answer the value of the backgroundColor option for the widget.
	 
	 Specifies the normal background color to use when displaying the widget."

	<category: 'accessing'>
	self properties at: #background ifPresent: [:value | ^value].
	self 
	    tclEval: '%1 cget -background'
	    with: self connected
	    with: self container.
	^self properties at: #background put: self tclResult
    ]

    backgroundColor: value [
	"Set the value of the backgroundColor option for the widget.
	 
	 Specifies the normal background color to use when displaying the widget."

	<category: 'accessing'>
	self 
	    tclEval: '%1 configure -background %3'
	    with: self connected
	    with: self container
	    with: value asTkString.
	self properties at: #background put: value
    ]

    foregroundColor [
	"Answer the value of the foregroundColor option for the widget.
	 
	 Specifies the normal foreground color to use when displaying the widget."

	<category: 'accessing'>
	self properties at: #foreground ifPresent: [:value | ^value].
	self 
	    tclEval: '%1 cget -foreground'
	    with: self connected
	    with: self container.
	^self properties at: #foreground put: self tclResult
    ]

    foregroundColor: value [
	"Set the value of the foregroundColor option for the widget.
	 
	 Specifies the normal foreground color to use when displaying the widget."

	<category: 'accessing'>
	self 
	    tclEval: '%1 configure -foreground %3'
	    with: self connected
	    with: self container
	    with: value asTkString.
	self properties at: #foreground put: value
    ]

    callback [
	"Answer a DirectedMessage that is sent when the receiver is modified,
	 or nil if none has been set up."

	<category: 'callback'>
	^callback
    ]

    callback: aReceiver message: aSymbol [
	"Set up so that aReceiver is sent the aSymbol message (the name of
	 a zero- or one-argument selector) when the receiver is clicked.
	 If the method accepts an argument, the receiver is passed."

	<category: 'callback'>
	| arguments selector numArgs |
	selector := aSymbol asSymbol.
	numArgs := selector numArgs.
	arguments := #().
	numArgs = 1 ifTrue: [arguments := Array with: self].
	callback := DirectedMessage 
		    selector: selector
		    arguments: arguments
		    receiver: aReceiver
    ]

    callback: aReceiver message: aSymbol argument: anObject [
	"Set up so that aReceiver is sent the aSymbol message (the name of
	 a one- or two-argument selector) when the receiver is clicked.
	 If the method accepts two argument, the receiver is passed
	 together with anObject; if it accepts a single one, instead,
	 only anObject is passed."

	<category: 'callback'>
	| arguments selector numArgs |
	selector := aSymbol asSymbol.
	numArgs := selector numArgs.
	numArgs = 2 
	    ifTrue: 
		[arguments := 
			{self.
			anObject}]
	    ifFalse: [arguments := {anObject}].
	callback := DirectedMessage 
		    selector: selector
		    arguments: arguments
		    receiver: aReceiver
    ]

    invokeCallback [
	"Generate a synthetic callback"

	<category: 'callback'>
	self callback isNil ifFalse: [self callback send]
    ]

    connected [
	<category: 'private'>
	^self uiManager getWidget: self path
    ]

    uiManager [
	<category: 'private'>
	self subclassResponsibility
    ]

    path [
	<category: 'private'>
	self subclassResponsibility
    ]

    underline: label [
	<category: 'private - underlining'>
	childrensUnderline isNil 
	    ifTrue: [childrensUnderline := ByteArray new: 256].
	label doWithIndex: 
		[:each :index | 
		| ascii |
		ascii := each asUppercase value + 1.
		(childrensUnderline at: ascii) = 0 
		    ifTrue: 
			[childrensUnderline at: ascii put: 1.
			^index - 1]].
	^0
    ]
]



"-------------------------- Gui class -----------------------------"



"-------------------------- BEventTarget class -----------------------------"



"-------------------------- BEventSet class -----------------------------"



"-------------------------- Blox class -----------------------------"



"-------------------------- BWidget class -----------------------------"



"-------------------------- BPrimitive class -----------------------------"



"-------------------------- BExtended class -----------------------------"



"-------------------------- BViewport class -----------------------------"



"-------------------------- BMenuObject class -----------------------------"



String extend [

    asTkString [
	"Private, Blox - Answer a copy of the receiver enclosed in
	 double-quotes and in which all the characters that Tk cannot read
	 are escaped through a backslash"

	<category: 'private - Tk interface'>
	self notYetImplemented
    ]

    asTkImageString [
	"Private, Blox - Look for GIF images; for those, since Base-64 data does
	 not contain { and }, is better to use the {} syntax."

	<category: 'private - Tk interface'>
	self notYetImplemented
    ]

]

