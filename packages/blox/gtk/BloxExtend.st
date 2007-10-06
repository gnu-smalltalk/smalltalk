"======================================================================
|
|   Smalltalk Tk-based GUI building blocks, extended widgets.
|   This is 100% Smalltalk!
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999, 2000, 2001, 2002 Free Software Foundation, Inc.
| Free Software Foundation, Inc.
| Written by Paolo Bonzini.
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



BExtended subclass: BProgress [
    | value filled label1 label2 |
    
    <comment: 'I show how much of a task has been completed.'>
    <category: 'Graphics-Examples'>

    backgroundColor [
	"Answer the background color of the widget.  This is used for
	 the background of the non-filled part, as well as for the
	 foreground of the filled part."

	<category: 'accessing'>
	^label1 backgroundColor
    ]

    backgroundColor: aColor [
	"Set the background color of the widget.  This is used for
	 the background of the non-filled part, as well as for the
	 foreground of the filled part."

	<category: 'accessing'>
	label1 backgroundColor: aColor.
	label2 foregroundColor: aColor
    ]

    filledColor [
	"Answer the background color of the widget's filled part."

	<category: 'accessing'>
	^label2 backgroundColor
    ]

    filledColor: aColor [
	"Set the background color of the widget's filled part."

	<category: 'accessing'>
	label2 backgroundColor: aColor
    ]

    foregroundColor [
	"Set the foreground color of the widget.  This is used for
	 the non-filled part, while the background color also works
	 as the foreground of the filled part."

	<category: 'accessing'>
	^label1 foregroundColor
    ]

    foregroundColor: aColor [
	"Set the foreground color of the widget.  This is used for
	 the non-filled part, while the background color also works
	 as the foreground of the filled part."

	<category: 'accessing'>
	label1 foregroundColor: aColor
    ]

    value [
	"Answer the filled percentage of the receiver (0..1)"

	<category: 'accessing'>
	^value
    ]

    value: newValue [
	"Set the filled percentage of the receiver and update the appearance.
	 newValue must be between 0 and 1."

	<category: 'accessing'>
	value := newValue.
	filled width: self value * self primitive widthAbsolute.
	label1 label: (value * 100) rounded printString , '%'.
	label2 label: (value * 100) rounded printString , '%'
    ]

    create [
	"Private - Create the widget"

	<category: 'private - gui'>
	| hgt |
	super create.
	self primitive onResizeSend: #resize: to: self.
	label1 := BLabel new: self primitive.
	filled := BForm new: self primitive.
	label2 := BLabel new: filled.
	hgt := self primitive height.
	label1
	    alignment: #center;
	    width: self primitive width height: hgt.
	label2
	    alignment: #center;
	    width: 0 height: hgt.
	self
	    backgroundColor: 'white';
	    foregroundColor: 'black';
	    filledColor: 'blue';
	    resize: nil;
	    value: 0
    ]

    newPrimitive [
	"Private - Create the BForm in which the receiver is drawn"

	<category: 'private - gui'>
	^BForm new: self parent
    ]

    resize: newSize [
	<category: 'private - gui'>
	label2 widthOffset: self primitive widthAbsolute
    ]
]



BExtended subclass: BButtonLike [
    | callback down |
    
    <comment: 'I am an object whose 3-D appearance resembles that of buttons.'>
    <category: 'Graphics-Examples'>

    callback [
	"Answer a DirectedMessage that is sent when the receiver is clicked,
	 or nil if none has been set up."

	<category: 'accessing'>
	^callback
    ]

    callback: aReceiver message: aSymbol [
	"Set up so that aReceiver is sent the aSymbol message (the name of
	 a zero- or one-argument selector) when the receiver is clicked.
	 If the method accepts an argument, the receiver is passed."

	<category: 'accessing'>
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

    pressed [
	"This is the default callback for the widget; it does
	 nothing if you don't override it. Of course if a subclass
	 overriddes this you (user of the class) might desire to
	 call this method from your own callback."

	<category: 'accessing'>
	
    ]

    invokeCallback [
	"Generate a synthetic callback"

	<category: 'accessing'>
	self callback isNil ifFalse: [self callback send]
    ]

    down: point [
	"Private - Make the widget go down when the left button is
	 pressed inside it."

	<category: 'private - events'>
	down := true.
	self enter
    ]

    enter [
	"Private - Make the widget go down when the mouse enters with
	 the left button pressed."

	<category: 'private - events'>
	down ifTrue: [self primitive effect: #sunken]
    ]

    leave [
	"Private - Make the widget go up when the mouse leaves"

	<category: 'private - events'>
	down ifTrue: [self primitive effect: #raised]
    ]

    up: point [
	"Private - Make the widget go up when the left button is released
	 after being pressed inside it, and trigger the callback if the
	 button was released inside the widget."

	<category: 'private - events'>
	| inside |
	inside := self primitive effect == #sunken.
	inside ifTrue: [self leave].
	down := false.
	inside ifTrue: [self invokeCallback]
    ]

    create [
	"Ask myself to create the primitive widget and set up its
	 event handlers."

	<category: 'private'>
	super create.
	(self primitive)
	    borderWidth: 2;
	    effect: #raised;
	    onMouseEnterEventSend: #enter to: self;
	    onMouseLeaveEventSend: #leave to: self;
	    onMouseDownEvent: 1
		send: #down:
		to: self;
	    onMouseUpEvent: 1
		send: #up:
		to: self.
	down := false.
	callback := DirectedMessage 
		    selector: #pressed
		    arguments: #()
		    receiver: self
    ]
]



BButtonLike subclass: BColorButton [
    
    <comment: 'I am a button that shows a color and that, unless a different callback is
used, lets you choose a color when it is clicked.'>
    <category: 'Graphics-Examples'>

    color [
	"Set the color that the receiver is painted in."

	<category: 'accessing'>
	^self primitive backgroundColor
    ]

    color: aString [
	"Set the color that the receiver is painted in."

	<category: 'accessing'>
	self primitive backgroundColor: aString
    ]

    pressed [
	"This is the default callback; it brings up a `choose-a-color'
	 window and, if `Ok' is pressed in the window, sets the receiver
	 to be painted in the chosen color."

	<category: 'accessing'>
	| newColor |
	newColor := BDialog 
		    chooseColor: self window
		    label: 'Choose a color'
		    default: self color.
	newColor isNil ifFalse: [self color: newColor]
    ]

    newPrimitive [
	"Private - A BColorButton is implemented through a BLabel. (!)"

	"Make it big enough if no width is specified."

	<category: 'private - gui'>
	^BLabel new: self parent label: '        '
    ]
]



BEventSet subclass: BBalloon [
    | text |
    
    <comment: 'This event set allows a widget to show explanatory information when
the mouse lingers over it for a while.'>
    <category: 'Graphics-Examples'>

    BalloonDelayTime := nil.
    Popup := nil.
    Owner := nil.
    MyProcess := nil.

    BBalloon class >> balloonDelayTime [
	"Answer the time after which the balloon is shown (default is
	 half a second)."

	<category: 'accessing'>
	BalloonDelayTime isNil ifTrue: [BalloonDelayTime := 500].
	^BalloonDelayTime
    ]

    BBalloon class >> balloonDelayTime: milliseconds [
	"Set the time after which the balloon is shown."

	<category: 'accessing'>
	BalloonDelayTime := milliseconds
    ]

    BBalloon class >> shown [
	"Answer whether a balloon is displayed"

	<category: 'accessing'>
	^Popup notNil
    ]

    shown [
	"Answer whether the receiver's balloon is displayed"

	<category: 'accessing'>
	^self class shown and: [Owner == self]
    ]

    text [
	"Answer the text displayed in the balloon"

	<category: 'accessing'>
	^text
    ]

    text: aString [
	"Set the text displayed in the balloon to aString"

	<category: 'accessing'>
	text := aString
    ]

    initialize: aBWidget [
	"Initialize the event sets for the receiver"

	<category: 'initializing'>
	super initialize: aBWidget.
	self text: '<not set>'.
	self
	    onMouseEnterEventSend: #queue to: self;
	    onMouseLeaveEventSend: #unqueue to: self;
	    onMouseDownEventSend: #unqueue:button: to: self
    ]

    popup [
	"Private - Create the popup window showing the balloon."

	<category: 'private'>
	Popup := BLabel popup: 
			[:widget | 
			widget
			    label: self text;
			    backgroundColor: '#FFFFAA';
			    x: self widget yRoot + (self widget widthAbsolute // 2)
				y: self widget yRoot + self widget heightAbsolute + 4].

	"Set the owner *now*. Otherwise, the mouse-leave event generated
	 by mapping the new popup window will destroy the popup window
	 itself (see #unqueue)."
	Owner := self
    ]

    queue [
	"Private - Queue a balloon to be shown in BalloonDelayTime milliseconds"

	<category: 'private'>
	self shown ifTrue: [^self].
	MyProcess isNil 
	    ifTrue: 
		[MyProcess := 
			[(Delay forMilliseconds: self class balloonDelayTime) wait.
			MyProcess := nil.
			self popup] 
				fork]
    ]

    unqueue [
	"Private - Prevent the balloon from being displayed if we were waiting
	 for it to appear, or delete it if it was already there."

	<category: 'private'>
	MyProcess isNil 
	    ifFalse: 
		[MyProcess terminate.
		MyProcess := nil].
	self shown 
	    ifTrue: 
		[Popup window destroy.
		Owner := Popup := nil]
    ]

    unqueue: point button: button [
	"Private - Same as #unqueue: but the event handler for mouse-down
	 events needs two parameters."

	<category: 'private'>
	self unqueue
    ]
]



BExtended subclass: BDropDown [
    | list button widget callback |
    
    <comment: 'This class is an abstract superclass for widgets offering the ability
to pick items from a pre-built list.  The list is usually hidden, but
a button on the right of this widgets makes it pop up.  This widget
is thus composed of three parts: an unspecified text widget (shown on
the left of the button and always visible), the button widget (shown
on the right, it depicts a down arrow, and is always visible), and
the pop-up list widget.'>
    <category: 'Graphics-Examples'>

    backgroundColor [
	"Answer the value of the backgroundColor for the widget, which
	 in this class is only set for the list widget (that is, the
	 pop-up widget). Subclasses should override this method so that
	 the color is set properly for the text widget as well.
	 
	 Specifies the normal background color to use when displaying the widget."

	<category: 'accessing'>
	^list backgroundColor
    ]

    backgroundColor: aColor [
	"Set the value of the backgroundColor for the widget, which
	 in this class is only set for the list widget (that is, the
	 pop-up widget). Subclasses should override this method so that
	 the color is set properly for the text widget as well.
	 
	 Specifies the normal background color to use when displaying the widget."

	<category: 'accessing'>
	list backgroundColor: aColor
    ]

    droppedRows [
	"Answer the number of items that are visible at any time in
	 the listbox."

	<category: 'accessing'>
	^(list height - 8) / self itemHeight
    ]

    droppedRows: anInteger [
	"Set the number of items that are visible at any time in
	 the listbox."

	<category: 'accessing'>
	list height: anInteger * self itemHeight + 8
    ]

    font [
	"Answer the value of the font option for the widget, which
	 in this class is only set for the list widget (that is, the
	 pop-up widget). Subclasses should override this method so that
	 the color is set properly for the text widget as well.
	 
	 Specifies the font to use when drawing text inside the widget. The font
	 can be given as either an X font name or a Blox font description string.
	 
	 X font names are given as many fields, each led by a minus, and each of
	 which can be replaced by an * to indicate a default value is ok:
	 foundry, family, weight, slant, setwidth, addstyle, pixel size, point size
	 (the same as pixel size for historical reasons), horizontal resolution,
	 vertical resolution, spacing, width, charset and character encoding.
	 
	 Blox font description strings have three fields, which must be separated by
	 a space and of which only the first is mandatory: the font family, the font
	 size in points (or in pixels if a negative value is supplied), and a number
	 of styles separated by a space (valid styles are normal, bold, italic,
	 underline and overstrike). Examples of valid fonts are ``Helvetica 10 Bold'',
	 ``Times -14'', ``Futura Bold Underline''.  You must enclose the font family
	 in braces if it is made of two or more words."

	<category: 'accessing'>
	^list font
    ]

    font: value [
	"Set the value of the font option for the widget, which
	 in this class is only set for the list widget (that is, the
	 pop-up widget). Subclasses should override this method so that
	 the color is set properly for the text widget as well.
	 
	 Specifies the font to use when drawing text inside the widget. The font
	 can be given as either an X font name or a Blox font description string.
	 
	 X font names are given as many fields, each led by a minus, and each of
	 which can be replaced by an * to indicate a default value is ok:
	 foundry, family, weight, slant, setwidth, addstyle, pixel size, point size
	 (the same as pixel size for historical reasons), horizontal resolution,
	 vertical resolution, spacing, width, charset and character encoding.
	 
	 Blox font description strings have three fields, which must be separated by
	 a space and of which only the first is mandatory: the font family, the font
	 size in points (or in pixels if a negative value is supplied), and a number
	 of styles separated by a space (valid styles are normal, bold, italic,
	 underline and overstrike). Examples of valid fonts are ``Helvetica 10 Bold'',
	 ``Times -14'', ``Futura Bold Underline''.  You must enclose the font family
	 in braces if it is made of two or more words."

	<category: 'accessing'>
	list font: value
    ]

    foregroundColor [
	"Answer the value of the foregroundColor for the widget, which
	 in this class is only set for the list widget (that is, the
	 pop-up widget). Subclasses should override this method so that
	 the color is set properly for the text widget as well.
	 
	 Specifies the normal foreground color to use when displaying the widget."

	<category: 'accessing'>
	^list foregroundColor
    ]

    foregroundColor: aColor [
	"Set the value of the foregroundColor for the widget, which
	 in this class is only set for the list widget (that is, the
	 pop-up widget). Subclasses should override this method so that
	 the color is set properly for the text widget as well.
	 
	 Specifies the normal foreground color to use when displaying the widget."

	<category: 'accessing'>
	list foregroundColor: aColor
    ]

    highlightBackground [
	"Answer the value of the highlightBackground option for the widget.
	 
	 Specifies the background color to use when displaying selected items
	 in the list widget."

	<category: 'accessing'>
	^list highlightBackground
    ]

    highlightBackground: aColor [
	"Set the value of the highlightBackground option for the widget.
	 
	 Specifies the background color to use when displaying selected items
	 in the list widget."

	<category: 'accessing'>
	list highlightBackground: aColor
    ]

    highlightForeground [
	"Answer the value of the highlightForeground option for the widget.
	 
	 Specifies the foreground color to use when displaying selected items
	 in the list widget."

	<category: 'accessing'>
	^list highlightForeground
    ]

    highlightForeground: aColor [
	"Set the value of the highlightForeground option for the widget.
	 
	 Specifies the foreground color to use when displaying selected items
	 in the list widget."

	<category: 'accessing'>
	list highlightForeground: aColor
    ]

    callback [
	"Answer a DirectedMessage that is sent when the receiver is clicked,
	 or nil if none has been set up."

	<category: 'callbacks'>
	^callback
    ]

    callback: aReceiver message: aSymbol [
	"Set up so that aReceiver is sent the aSymbol message (the name of
	 a zero- or one-argument selector) when the receiver is clicked.
	 If the method accepts an argument, the receiver is passed."

	<category: 'callbacks'>
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

    invokeCallback [
	"Generate a synthetic callback"

	<category: 'callbacks'>
	self callback isNil ifFalse: [self callback send]
    ]

    createList [
	"Create the popup widget to be used for the
	 `drop-down list'.  It is a BList by default, but you can
	 use any other widget, overriding the `list box accessing'
	 methods if necessary."

	<category: 'flexibility'>
	^BList new
    ]

    createTextWidget [
	"Create the widget that will hold the string chosen from
	 the list box and answer it. The widget must be a child of `self
	 primitive'."

	<category: 'flexibility'>
	self subclassResponsibility
    ]

    itemHeight [
	"Answer the height of an item in the drop-down list. The
	 default implementation assumes that the receiver understands
	 #font, but you can modify it if you want."

	<category: 'flexibility'>
	^1 + (self fontHeight: 'M')
    ]

    listCallback [
	"Called when an item of the listbox is highlighted. Do
	 nothing by default"

	<category: 'flexibility'>
	
    ]

    listSelectAt: aPoint [
	"Select the item lying at the given position in the list
	 box. The default implementation assumes that list is a BList, but
	 you can modify it if you want."

	<category: 'flexibility'>
	| newIndex |
	(list drawingArea containsPoint: aPoint) ifFalse: [^self].
	newIndex := list indexAt: aPoint.
	newIndex = list index ifTrue: [^self].
	self index: newIndex
    ]

    listText [
	"Answer the text currently chosen in the list box. The
	 default implementation assumes that list is a BList, but you can
	 modify it if you want."

	<category: 'flexibility'>
	^list labelAt: list index
    ]

    text [
	"Answer the text that the user has picked from the widget and/or
	 typed in the control (the exact way the text is entered will be
	 established by subclasses, since this is an abstract method)."

	<category: 'flexibility'>
	self subclassResponsibility
    ]

    text: aString [
	"Set the text widget to aString"

	<category: 'flexibility'>
	self subclassResponsibility
    ]

    create [
	<category: 'private - initialization'>
	super create.
	list := self createList.
	(self primitive)
	    defaultHeight: (self itemHeight + 6 max: 20);
	    effect: #sunken;
	    borderWidth: 2;
	    backgroundColor: 'white'.
	list borderWidth: 0.
	(widget := self createTextWidget)
	    inset: 1;
	    borderWidth: 0;
	    backgroundColor: 'white';
	    tabStop: true;
	    stretch: true.
	(button := BImage new: self primitive data: BImage downArrow)
	    effect: #raised;
	    borderWidth: 2.
	self droppedRows: 8.
	self setEvents
    ]

    newPrimitive [
	<category: 'private - initialization'>
	^(BContainer new: self parent)
	    setVerticalLayout: false;
	    yourself
    ]

    setEvents [
	<category: 'private - initialization'>
	self primitive onDestroySend: #destroy to: list.
	button 
	    onMouseDownEvent: 1
	    send: #value:
	    to: [:pnt | self toggle].
	list 
	    onKeyEvent: 'Tab'
	    send: #value
	    to: 
		[self unmapList.
		widget activateNext].
	list 
	    onKeyEvent: 'Shift-Tab'
	    send: #value
	    to: 
		[self unmapList.
		widget activatePrevious].
	list 
	    onKeyEvent: 'Return'
	    send: #unmapList
	    to: self.
	list 
	    onKeyEvent: 'Escape'
	    send: #unmapList
	    to: self.
	list 
	    onMouseUpEvent: 1
	    send: #value:
	    to: [:pnt | self unmapList].
	list onMouseMoveEventSend: #listSelectAt: to: self.
	list onFocusLeaveEventSend: #unmapList to: self.
	list callback: self message: #listCallback
    ]

    setInitialSize [
	<category: 'private - initialization'>
	self primitive x: 0 y: 0
    ]

    add: anObject afterIndex: index [
	"Add an element with the given value after another element whose
	 index is contained in the index parameter.  The label displayed
	 in the widget is anObject's displayString.  Answer anObject."

	<category: 'list box accessing'>
	^list add: anObject afterIndex: index
    ]

    add: aString element: anObject afterIndex: index [
	"Add an element with the aString label after another element whose
	 index is contained in the index parameter.  This method allows
	 the client to decide autonomously the label that the widget will
	 display.
	 
	 If anObject is nil, then string is used as the element as well.
	 If aString is nil, then the element's displayString is used as
	 the label.
	 
	 Answer anObject or, if it is nil, aString."

	<category: 'list box accessing'>
	^list 
	    add: aString
	    element: anObject
	    afterIndex: index
    ]

    addLast: anObject [
	"Add an element with the given value at the end of the listbox.
	 The label displayed in the widget is anObject's displayString.
	 Answer anObject."

	<category: 'list box accessing'>
	^list addLast: anObject
    ]

    addLast: aString element: anObject [
	"Add an element with the given value at the end of the listbox.
	 This method allows the client to decide autonomously the label
	 that the widget will display.
	 
	 If anObject is nil, then string is used as the element as well.
	 If aString is nil, then the element's displayString is used as
	 the label.
	 
	 Answer anObject or, if it is nil, aString."

	<category: 'list box accessing'>
	^list addLast: aString element: anObject
    ]

    associationAt: anIndex [
	"Answer an association whose key is the item at the given position
	 in the listbox and whose value is the label used to display that
	 item."

	<category: 'list box accessing'>
	^list associationAt: anIndex
    ]

    at: anIndex [
	"Answer the element displayed at the given position in the list
	 box."

	<category: 'list box accessing'>
	^list at: anIndex
    ]

    contents: stringCollection [
	"Set the elements displayed in the listbox, and set the labels
	 to be their displayStrings."

	<category: 'list box accessing'>
	list contents: stringCollection
    ]

    contents: stringCollection elements: elementList [
	"Set the elements displayed in the listbox to be those in elementList,
	 and set the labels to be the corresponding elements in stringCollection.
	 The two collections must have the same size."

	<category: 'list box accessing'>
	list contents: stringCollection elements: elementList
    ]

    do: aBlock [
	"Iterate over each element of the listbox and pass it to aBlock."

	<category: 'list box accessing'>
	list do: aBlock
    ]

    elements: elementList [
	"Set the elements displayed in the listbox, and set the labels
	 to be their displayStrings."

	<category: 'list box accessing'>
	list elements: elementList
    ]

    index: newIndex [
	"Highlight the item at the given position in the listbox, and
	 transfer the text in the list box to the text widget."

	<category: 'list box accessing'>
	list highlight: newIndex.
	self text: self listText.
	self isDropdownVisible ifFalse: [self invokeCallback]
    ]

    labelAt: anIndex [
	"Answer the label displayed at the given position in the list
	 box."

	<category: 'list box accessing'>
	^list labelAt: anIndex
    ]

    labelsDo: aBlock [
	"Iterate over the labels in the list widget and pass each of
	 them to aBlock."

	<category: 'list box accessing'>
	list labelsDo: aBlock
    ]

    numberOfStrings [
	"Answer the number of items in the list box"

	<category: 'list box accessing'>
	^list numberOfStrings
    ]

    removeAtIndex: index [
	"Remove the item at the given index in the list box, answering
	 the object associated to the element (i.e. the value that #at:
	 would have returned for the given index)"

	<category: 'list box accessing'>
	^list removeAtIndex: index
    ]

    size [
	"Answer the number of items in the list box"

	<category: 'list box accessing'>
	^list size
    ]

    dropdown [
	"Force the pop-up list widget to be visible."

	"Always reset the geometry -- it is harmless and *may*
	 actually get better appearance in some weird case."

	<category: 'widget protocol'>
	list window boundingBox: self dropRectangle.
	self isDropdownVisible ifTrue: [^self].
	list window map
    ]

    dropRectangle [
	"Answer the rectangle in which the list widget will pop-up.
	 If possible, this is situated below the drop-down widget's
	 bottom side, but if the screen space there is not enough
	 it could be above the drop-down widget's above side.  If
	 there is no screen space above as well, we pick the side
	 where we can offer the greatest number of lines in the
	 pop-up widget."

	<category: 'widget protocol'>
	| screen rectangle spaceBelow |
	screen := Rectangle origin: Blox screenOrigin extent: Blox screenSize.
	rectangle := Rectangle 
		    origin: self xRoot @ (self yRoot + self heightAbsolute)
		    extent: self widthAbsolute @ list height.
	spaceBelow := screen bottom - rectangle top.
	rectangle bottom > screen bottom ifFalse: [^rectangle].

	"Fine. Pop it up above the entry widget instead of below."
	rectangle moveTo: self xRoot @ self yRoot - rectangle extent.
	rectangle top < screen top ifFalse: [^rectangle].

	"How annoying, it doesn't fit in the screen.  Now we'll try
	 to be real clever and either pop it up or down, depending
	 on which way gives us the biggest list."
	spaceBelow < (rectangle bottom - screen top) 
	    ifTrue: [rectangle top: 0]
	    ifFalse: 
		[rectangle
		    moveTo: self xRoot @ (self yRoot + self heightAbsolute);
		    bottom: screen bottom].
	^rectangle
    ]

    isDropdownVisible [
	"Answer whether the pop-up widget is visible"

	<category: 'widget protocol'>
	^list window isMapped
    ]

    unmapList [
	"Unmap the pop-up widget from the screen, transfer its selected
	 item to the always visible text widget, and generate a callback."

	<category: 'widget protocol'>
	list window unmap.
	self text: self listText.
	self invokeCallback
    ]

    toggle [
	"Toggle the visibility of the pop-up widget."

	<category: 'widget protocol'>
	widget activate.
	self isDropdownVisible ifTrue: [self unmapList] ifFalse: [self dropdown]
    ]
]



BDropDown subclass: BDropDownList [
    | callback |
    
    <comment: 'This class resembles a list box widget, but its actual list shows up
only when you click the arrow button beside the currently selected item.'>
    <category: 'Graphics-Examples'>

    backgroundColor: aColor [
	"Set the value of the backgroundColor for the widget, which
	 in this class is set for the list widget and, when the focus is
	 outside the control, for the text widget as well.
	 
	 Specifies the normal background color to use when displaying the widget."

	<category: 'accessing'>
	super backgroundColor: aColor.
	self highlight
    ]

    font: aString [
	"Set the value of the font option for the widget.
	 
	 Specifies the font to use when drawing text inside the widget. The font
	 can be given as either an X font name or a Blox font description string.
	 
	 X font names are given as many fields, each led by a minus, and each of
	 which can be replaced by an * to indicate a default value is ok:
	 foundry, family, weight, slant, setwidth, addstyle, pixel size, point size
	 (the same as pixel size for historical reasons), horizontal resolution,
	 vertical resolution, spacing, width, charset and character encoding.
	 
	 Blox font description strings have three fields, which must be separated by
	 a space and of which only the first is mandatory: the font family, the font
	 size in points (or in pixels if a negative value is supplied), and a number
	 of styles separated by a space (valid styles are normal, bold, italic,
	 underline and overstrike). Examples of valid fonts are ``Helvetica 10 Bold'',
	 ``Times -14'', ``Futura Bold Underline''.  You must enclose the font family
	 in braces if it is made of two or more words."

	<category: 'accessing'>
	widget font: aString.
	super font: aString
    ]

    foregroundColor: aColor [
	"Set the value of the foregroundColor for the widget, which
	 in this class is set for the list widget and, when the focus is
	 outside the control, for the text widget as well.
	 
	 Specifies the normal foreground color to use when displaying the widget."

	<category: 'accessing'>
	super foregroundColor: aColor.
	self highlight
    ]

    highlightBackground: aColor [
	"Answer the value of the highlightBackground option for the widget.
	 
	 Specifies the background color to use when displaying selected items
	 in the list widget and, when the focus is inside the control, for the
	 text widget as well."

	<category: 'accessing'>
	super highlightBackground: aColor.
	self highlight
    ]

    highlightForeground: aColor [
	"Answer the value of the highlightForeground option for the widget.
	 
	 Specifies the foreground color to use when displaying selected items
	 in the list widget and, when the focus is inside the control, for the
	 text widget as well."

	<category: 'accessing'>
	super highlightForeground: aColor.
	self highlight
    ]

    text [
	"Answer the text that the user has picked from the widget and/or
	 typed in the control (the exact way the text is entered will be
	 established by subclasses, since this is an abstract method)."

	<category: 'accessing'>
	^widget label
    ]

    callback: aReceiver message: aSymbol [
	"Set up so that aReceiver is sent the aSymbol message (the name of
	 a selector with at most two arguemtnts) when the active item in
	 the receiver changegs.  If the method accepts two arguments, the
	 receiver is  passed as the first parameter.  If the method accepts
	 one or two arguments, the selected index is passed as the last
	 parameter."

	<category: 'callbacks'>
	| arguments selector numArgs |
	selector := aSymbol asSymbol.
	numArgs := selector numArgs.
	arguments := #().
	numArgs = 1 ifTrue: [arguments := {nil}].
	numArgs = 2 
	    ifTrue: 
		[arguments := 
			{self.
			nil}].
	callback := DirectedMessage 
		    selector: selector
		    arguments: arguments
		    receiver: aReceiver
    ]

    invokeCallback [
	"Generate a synthetic callback."

	<category: 'callbacks'>
	self callback isNil ifTrue: [^self].
	self callback arguments isEmpty 
	    ifFalse: 
		[self callback arguments at: self callback arguments size put: self index].
	self callback send
    ]

    index [
	"Answer the value of the index option for the widget.  Since it is
	 not possible to modify an item once it has been picked from the
	 list widget, this is always defined for BDropDownList widgets."

	<category: 'list box accessing'>
	^list index
    ]

    highlight [
	<category: 'private'>
	| bg fg |
	widget isActive 
	    ifTrue: 
		[bg := list highlightBackground.
		fg := list highlightForeground]
	    ifFalse: 
		[bg := list backgroundColor.
		fg := list foregroundColor].
	widget
	    backgroundColor: bg;
	    foregroundColor: fg
    ]

    createTextWidget [
	<category: 'private-overrides'>
	^BLabel new: self primitive
    ]

    listCallback [
	<category: 'private-overrides'>
	self text: self listText
    ]

    text: aString [
	<category: 'private-overrides'>
	widget label: aString
    ]

    setEvents [
	<category: 'private-overrides'>
	super setEvents.

	"If we did not test whether the list box is focus, we would toggle
	 twice (once in the widget's mouseDownEvent, once in the list's
	 focusLeaveEvent)"
	widget 
	    onMouseDownEvent: 1
	    send: #value:
	    to: 
		[:pnt | 
		"list isActive ifFalse: ["

		self toggle	"]"].
	widget onFocusEnterEventSend: #highlight to: self.
	widget onFocusLeaveEventSend: #highlight to: self.
	widget 
	    onKeyEvent: 'Down'
	    send: #dropdown
	    to: self
    ]
]



BDropDown subclass: BDropDownEdit [
    
    <comment: 'This class resembles an edit widget, but it has an arrow button that 
allows the user to pick an item from a pre-built list.'>
    <category: 'Graphics-Examples'>

    backgroundColor: aColor [
	"Set the value of the backgroundColor option for the widget.
	 
	 Specifies the normal background color to use when displaying the widget."

	<category: 'accessing'>
	super backgroundColor: aColor.
	widget backgroundColor: aColor
    ]

    font: aString [
	"Set the value of the font option for the widget.
	 
	 Specifies the font to use when drawing text inside the widget. The font
	 can be given as either an X font name or a Blox font description string.
	 
	 X font names are given as many fields, each led by a minus, and each of
	 which can be replaced by an * to indicate a default value is ok:
	 foundry, family, weight, slant, setwidth, addstyle, pixel size, point size
	 (the same as pixel size for historical reasons), horizontal resolution,
	 vertical resolution, spacing, width, charset and character encoding.
	 
	 Blox font description strings have three fields, which must be separated by
	 a space and of which only the first is mandatory: the font family, the font
	 size in points (or in pixels if a negative value is supplied), and a number
	 of styles separated by a space (valid styles are normal, bold, italic,
	 underline and overstrike). Examples of valid fonts are ``Helvetica 10 Bold'',
	 ``Times -14'', ``Futura Bold Underline''.  You must enclose the font family
	 in braces if it is made of two or more words."

	<category: 'accessing'>
	widget font: aString.
	super font: aString
    ]

    foregroundColor: aColor [
	"Set the value of the foregroundColor option for the widget.
	 
	 Specifies the normal foreground color to use when displaying the widget."

	<category: 'accessing'>
	super foregroundColor: aColor.
	widget foregroundColor: aColor
    ]

    highlightBackground: aColor [
	"Set the value of the highlightBackground option for the widget.
	 
	 Specifies the background color to use when displaying selected items
	 in the list widget and the selection in the text widget."

	<category: 'accessing'>
	super highlightBackground: aColor.
	widget selectBackground: aColor
    ]

    highlightForeground: aColor [
	"Set the value of the highlightBackground option for the widget.
	 
	 Specifies the background color to use when displaying selected items
	 in the list widget and the selection in the text widget."

	<category: 'accessing'>
	super highlightForeground: aColor.
	widget selectForeground: aColor
    ]

    text [
	"Answer the text shown in the widget"

	<category: 'accessing-overrides'>
	^widget contents
    ]

    editCallback [
	<category: 'private'>
	self isDropdownVisible ifFalse: [self invokeCallback]
    ]

    createTextWidget [
	<category: 'private-overrides'>
	^(BEdit new: self primitive) callback: self message: #editCallback
    ]

    insertAtEnd: aString [
	"Clear the selection and append aString at the end of the
	 text widget."

	<category: 'text accessing'>
	widget insertAtEnd: aString
    ]

    replaceSelection: aString [
	"Insert aString in the text widget at the current insertion point,
	 replacing the currently selected text (if any), and leaving
	 the text selected."

	<category: 'text accessing'>
	widget replaceSelection: aString
    ]

    selectAll [
	"Select the whole contents of the text widget"

	<category: 'text accessing'>
	widget selectAll
    ]

    selectFrom: first to: last [
	"Sets the selection of the text widget to include the characters
	 starting with the one indexed by first (the very first character in
	 the widget having index 1) and ending with the one just before
	 last.  If last refers to the same character as first or an earlier
	 one, then the text widget's selection is cleared."

	<category: 'text accessing'>
	widget selectFrom: first to: last
    ]

    selection [
	"Answer an empty string if the text widget has no selection, else answer
	 the currently selected text"

	<category: 'text accessing'>
	^widget selection
    ]

    selectionRange [
	"Answer nil if the text widget has no selection, else answer
	 an Interval object whose first item is the index of the
	 first character in the selection, and whose last item is the
	 index of the character just after the last one in the
	 selection."

	<category: 'text accessing'>
	^widget selectionRange
    ]

    text: aString [
	"Set the contents of the text widget and select them."

	<category: 'text accessing'>
	widget
	    contents: aString;
	    selectAll
    ]
]



"-------------------------- BProgress class -----------------------------"



"-------------------------- BButtonLike class -----------------------------"



"-------------------------- BColorButton class -----------------------------"



"-------------------------- BBalloon class -----------------------------"



"-------------------------- BDropDown class -----------------------------"



"-------------------------- BDropDownList class -----------------------------"



"-------------------------- BDropDownEdit class -----------------------------"

